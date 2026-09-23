-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE wallet_provider.relink_instance_account(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg      text;
    v_payload        jsonb;
    v_tag            varchar;
    v_account        jsonb;
    v_account_code   varchar;
    v_instance_id    varchar;
    v_current_account_id varchar;
    v_resolved_account_id varchar;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);
    v_tag := nullif(trim((v_payload ->> 'hardwareKeyTag')), '');
    v_account := v_payload -> 'account';
    v_account_code := nullif(trim((v_account ->> 'code')), '');

    IF v_tag IS NULL THEN
        po_data := result_error('err:instance:hardwareKeyTagRequired', 'Hardware key tag is required');
        RETURN;
    END IF;

    IF v_account IS NULL OR v_account_code IS NULL THEN
        po_data := result_error('err:account:required', 'Account data is required');
        RETURN;
    END IF;

    SELECT id, account_id
      INTO v_instance_id, v_current_account_id
      FROM wallet_provider.instances
     WHERE hardware_key_tag = v_tag
       AND active
     LIMIT 1;

    IF v_instance_id IS NULL THEN
        po_data := result_error('err:instance:not_found', 'Wallet instance not found');
        RETURN;
    END IF;

    CALL wallet_provider.save_account(v_account, po_data);
    IF po_data IS NULL OR (po_data ->> 'success')::boolean IS NOT true THEN
        RETURN;
    END IF;

    v_resolved_account_id := ((po_data -> 'data') ->> 'id');

    IF v_current_account_id IS DISTINCT FROM v_resolved_account_id THEN
        UPDATE wallet_provider.instances
           SET account_id    = v_resolved_account_id,
               date_modified = now()
         WHERE id = v_instance_id;
    END IF;

    po_data := result_success((wallet_provider.get_instance_data(v_tag)
        || jsonb_build_object('account', wallet_provider.get_account_data(v_resolved_account_id)))::json);
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := result_error('err:internal:db', v_error_msg);
        RETURN;
END;
$$;

GRANT EXECUTE ON PROCEDURE wallet_provider.relink_instance_account(jsonb, jsonb) TO digimaks;
REVOKE ALL ON PROCEDURE wallet_provider.relink_instance_account(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet_provider.relink_instance_account(jsonb, jsonb)
    IS 'Ensures a wallet instance is linked to the account matching the current authenticated identity, creating/updating the account and relinking the instance if it changed.';
