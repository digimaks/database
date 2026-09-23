-- SPDX-License-Identifier: EUPL-1.2
-- Tiek izsaukta ārēji. Checked
-- Atkarīga no wallet_provider.get_account_id_by_code un wallet_provider.get_account_id_by_guid

CREATE OR REPLACE PROCEDURE wallet_provider.get_instance_list(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg   text;
    v_payload     jsonb;
    v_account_code varchar;
    v_account_guid varchar;
    v_account_id   varchar;
    v_result       json;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);

    v_account_code := nullif(trim((v_payload ->> 'code')), '');
    v_account_guid := nullif(trim((v_payload ->> 'id')), '');

    v_account_id := coalesce(
        wallet_provider.get_account_id_by_code(v_account_code),
        wallet_provider.get_account_id_by_guid(v_account_guid));

    IF v_account_id IS NULL THEN
        po_data := json_build_object('code', 'err:instances:not_found', 'error', 'Instance owner not found');
        RETURN;
    END IF;

    SELECT json_agg(rec)
      INTO v_result
      FROM (
            SELECT i.id                     AS "id",
                   i.hardware_key_tag       AS "hardwareKeyTag",
                   i.public_key             AS "publicKey",
                   i.fid                    AS "fid",
                   i.device_label           AS "deviceLabel",
                   i.hardware_identifiers   AS "hardwareIdentifiers",
                   i.wscd_anchor_hash       AS "wscdAnchorHash",
                   i.wscd_type              AS "wscdType",
                   i.active                 AS "active",
                   i.revoked_at             AS "revokedAt"
              FROM wallet_provider.instances i
             WHERE i.account_id = v_account_id
               AND i.active
           ) rec;

    po_data := result_success(coalesce(v_result, '[]'::json));
EXCEPTION
    WHEN OTHERS THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := result_error('err:internal:db', v_error_msg);
        RETURN;
END;
$$;

GRANT EXECUTE ON PROCEDURE wallet_provider.get_instance_list(jsonb, jsonb) TO digimaks;
REVOKE ALL ON PROCEDURE wallet_provider.get_instance_list(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet_provider.get_instance_list(jsonb, jsonb)
    IS 'Returns active wallet instances for the specified account.';
