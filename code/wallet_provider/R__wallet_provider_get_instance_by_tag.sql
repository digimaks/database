-- SPDX-License-Identifier: EUPL-1.2
-- neizmanto iekšēji patreiz. Checked

CREATE OR REPLACE PROCEDURE wallet_provider.get_instance_by_tag(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg   text;
    v_payload     jsonb;
    v_tag         varchar;
    v_instance_id varchar;
    v_instance    jsonb;
    v_account_id  varchar;
    v_account     jsonb;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);
    v_tag := nullif(trim((v_payload ->> 'hardwareKeyTag')), '');

    IF v_tag IS NULL THEN
        po_data := json_build_object('code', 'err:instance:not_found', 'error', 'Wallet instance not found');
        RETURN;
    END IF;

        SELECT id, account_id
            INTO v_instance_id, v_account_id
            FROM wallet_provider.instances
         WHERE hardware_key_tag = v_tag
             AND active
         LIMIT 1;

        IF v_instance_id IS NULL THEN
        po_data := json_build_object('code', 'err:instance:not_found', 'error', 'Wallet instance not found');
        RETURN;
    END IF;

        v_instance := wallet_provider.get_instance_data(v_tag);

    IF v_account_id IS NOT NULL THEN
        v_account := wallet_provider.get_account_data(v_account_id);
    END IF;

    po_data := jsonb_build_object('success', true, 'data', coalesce(v_instance, '{}'::jsonb) || jsonb_build_object('account', v_account));
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := result_error('err:internal:db', v_error_msg);
        RETURN;
END;
$$;

ALTER PROCEDURE wallet_provider.get_instance_by_tag(jsonb, jsonb) OWNER TO digimaks;
REVOKE ALL ON PROCEDURE wallet_provider.get_instance_by_tag(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet_provider.get_instance_by_tag(jsonb, jsonb)
    IS 'Returns wallet instance metadata with optional account profile by hardware key tag.';
