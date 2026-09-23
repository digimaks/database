-- SPDX-License-Identifier: EUPL-1.2
-- izmanto iekšēji wallet_provider.create_instance un wallet_provider.get_instance_by_tag. Checked

CREATE OR REPLACE FUNCTION wallet_provider.get_instance_data(
    pi_hardware_key_tag varchar)
    RETURNS jsonb
    LANGUAGE plpgsql
    STABLE SECURITY DEFINER
AS
$$
DECLARE
    v_result jsonb;
BEGIN
    IF pi_hardware_key_tag IS NULL OR btrim(pi_hardware_key_tag) = '' THEN
        RETURN NULL;
    END IF;

    SELECT row_to_json(rec)
      INTO v_result
      FROM (
            SELECT i.id                  AS id,
                   i.account_id          AS "accountId",
                   i.hardware_key_tag    AS "hardwareKeyTag",
                   i.public_key          AS "publicKey",
                   i.fid                 AS "fid",
                   i.wscd_anchor_hash    AS "wscdAnchorHash",
                   i.wscd_type           AS "wscdType",
                   i.device_label        AS "deviceLabel",
                   i.hardware_identifiers AS "hardwareIdentifiers",
                   i.active              AS "active",
                   i.date_created        AS "dateCreated",
                   i.date_modified       AS "dateModified",
                   i.revoked_at          AS "revokedAt"
              FROM wallet_provider.instances i
             WHERE i.hardware_key_tag = pi_hardware_key_tag
               AND i.active
             LIMIT 1
           ) rec;

    RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION wallet_provider.get_instance_data(varchar) TO digimaks;
REVOKE ALL ON FUNCTION wallet_provider.get_instance_data(varchar) FROM PUBLIC;

COMMENT ON FUNCTION wallet_provider.get_instance_data(varchar)
    IS 'Returns wallet instance metadata for the provided hardware key tag.';
