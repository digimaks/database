-- SPDX-License-Identifier: EUPL-1.2
-- reviewed, iekšēji izmanto wallet_provider.create_instance kad veido anonīmu instanci

CREATE OR REPLACE PROCEDURE wallet_provider.save_account(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg          text;
    v_data               jsonb;
    v_account            wallet_provider.accounts%rowtype;
    v_identifier         wallet_provider.user_identifiers%rowtype;
    v_contact_payload    jsonb;
    v_requester_code     varchar;
    v_existing_id        varchar;
BEGIN
    v_data := coalesce(pi_data, '{}'::jsonb);

    v_account.id := nullif(trim((v_data ->> 'id')), '');
    v_account.given_name := nullif(trim((v_data ->> 'givenName')), '');
    v_account.family_name := nullif(trim((v_data ->> 'familyName')), '');

    v_identifier.identifier_type := coalesce(nullif(trim((v_data ->> 'identifierType')), ''), 'person_code');
    v_identifier.value := nullif(trim((v_data ->> 'code')), '');
    v_requester_code := nullif(trim((v_data ->> 'requesterCode')), '');

    IF v_identifier.value IS NULL THEN
        po_data := json_build_object('code', 'err:account:code_required', 'error', 'Account identifier is required');
        RETURN;
    END IF;

    IF v_requester_code IS NOT NULL AND v_identifier.value <> v_requester_code THEN
        po_data := json_build_object('code', 'err:account:not_found', 'error', 'Account not found');
        RETURN;
    END IF;

    v_existing_id := wallet_provider.get_account_id_by_code(v_identifier.value);
    IF v_existing_id IS NOT NULL THEN
        v_account.id := v_existing_id;
    END IF;

    IF v_account.id IS NULL THEN
        INSERT INTO wallet_provider.accounts(given_name, family_name)
        VALUES (v_account.given_name, v_account.family_name)
        RETURNING id INTO v_account.id;
    ELSE
        UPDATE wallet_provider.accounts
           SET given_name    = v_account.given_name,
               family_name   = v_account.family_name,
               date_modified = now()
         WHERE id = v_account.id
           AND (given_name IS DISTINCT FROM v_account.given_name
             OR family_name IS DISTINCT FROM v_account.family_name);
    END IF;

    -- ensure identifier exists
    IF NOT EXISTS (SELECT 1
                     FROM wallet_provider.user_identifiers ui
                    WHERE ui.account_id = v_account.id
                      AND ui.identifier_type = v_identifier.identifier_type
                      AND ui.value = v_identifier.value
                      AND ui.active) THEN
        INSERT INTO wallet_provider.user_identifiers(account_id, identifier_type, value)
        VALUES (v_account.id, v_identifier.identifier_type, v_identifier.value);
    END IF;

    -- sync contacts
    FOR v_contact_payload IN SELECT jsonb_array_elements(coalesce(v_data -> 'contacts', '[]'::jsonb))
    LOOP
        DECLARE
            v_contact wallet_provider.user_contact_info%rowtype;
        BEGIN
            v_contact.account_id := v_account.id;
            v_contact.contact_type := nullif(trim((v_contact_payload ->> 'type')), '');
            v_contact.value := nullif(trim((v_contact_payload ->> 'value')), '');

            IF v_contact.contact_type IS NULL OR v_contact.value IS NULL THEN
                CONTINUE;
            END IF;

            IF EXISTS (SELECT 1
                        FROM wallet_provider.user_contact_info uci
                       WHERE uci.account_id = v_contact.account_id
                         AND uci.contact_type = v_contact.contact_type
                         AND uci.active) THEN
                UPDATE wallet_provider.user_contact_info
                   SET active        = false,
                       date_modified = now()
                 WHERE account_id = v_contact.account_id
                   AND contact_type = v_contact.contact_type
                   AND value <> v_contact.value
                   AND active;
            END IF;

            IF NOT EXISTS (SELECT 1
                              FROM wallet_provider.user_contact_info uci
                             WHERE uci.account_id = v_contact.account_id
                               AND uci.contact_type = v_contact.contact_type
                               AND uci.value = v_contact.value
                               AND uci.active) THEN
                INSERT INTO wallet_provider.user_contact_info(account_id, contact_type, value)
                VALUES (v_contact.account_id, v_contact.contact_type, v_contact.value);
            END IF;
        END;
    END LOOP;

    po_data := result_success(wallet_provider.get_account_data(v_account.id)::json);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := result_error('err:internal:db', v_error_msg);
        RETURN;
END;
$$;

GRANT EXECUTE ON PROCEDURE wallet_provider.save_account(jsonb, jsonb) TO digimaks;
REVOKE ALL ON PROCEDURE wallet_provider.save_account(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet_provider.save_account(jsonb, jsonb)
    IS 'Creates or updates wallet account profile data.';
