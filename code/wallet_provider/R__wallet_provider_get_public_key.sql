-- SPDX-License-Identifier: EUPL-1.2
-- Nav iekšējo atkarību, tiek izsaukta ārēji. Checked

CREATE OR REPLACE PROCEDURE wallet_provider.get_public_key(
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
    v_public_key  text;
    v_account_id  varchar;
    v_account     jsonb;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);
    v_tag := nullif(trim((v_payload ->> 'hardwareKeyTag')), '');

    IF v_tag IS NULL THEN
        po_data := json_build_object('code', 'err:public_key:not_found', 'error', 'Public key not found');
        RETURN;
    END IF;

    SELECT account_id, public_key
      INTO v_account_id, v_public_key
      FROM wallet_provider.instances
     WHERE hardware_key_tag = v_tag
       AND active
     LIMIT 1;

    IF v_public_key IS NULL THEN
        po_data := json_build_object('code', 'err:public_key:not_found', 'error', 'Public key not found');
        RETURN;
    END IF;

    IF v_account_id IS NOT NULL THEN
        v_account := wallet_provider.get_account_data(v_account_id);
    END IF;

    po_data := result_success(json_build_object('publicKey', v_public_key, 'account', v_account));
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := result_error('err:internal:db', v_error_msg);
        RETURN;
END;
$$;

GRANT EXECUTE ON PROCEDURE wallet_provider.get_public_key(jsonb, jsonb) TO digimaks;
REVOKE ALL ON PROCEDURE wallet_provider.get_public_key(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet_provider.get_public_key(jsonb, jsonb)
    IS 'Returns the public key and optional account profile for a wallet instance.';
