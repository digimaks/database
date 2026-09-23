-- SPDX-License-Identifier: EUPL-1.2
-- man liekas ka šī funkcija nav vajadzīga, vai arī jāpārveido, TODO pārbaudīt
-- patreiz šo funkciju izmanto wallet_provider.get_instance_list, bet tur var iebarot arī get_account_id_by_code


CREATE OR REPLACE FUNCTION wallet_provider.get_account_id_by_guid(
    pi_value varchar)
    RETURNS varchar
    LANGUAGE plpgsql
    STABLE SECURITY DEFINER
AS
$$
DECLARE
    v_result varchar;
BEGIN
    IF pi_value IS NULL OR btrim(pi_value) = '' THEN
        RETURN NULL;
    END IF;

    SELECT id
      INTO v_result
      FROM wallet_provider.accounts
     WHERE id = pi_value
       AND active
     LIMIT 1;

    RETURN v_result;
END;
$$;

ALTER FUNCTION wallet_provider.get_account_id_by_guid(varchar) OWNER TO digimaks;
REVOKE ALL ON FUNCTION wallet_provider.get_account_id_by_guid(varchar) FROM PUBLIC;

COMMENT ON FUNCTION wallet_provider.get_account_id_by_guid(varchar)
    IS 'Finds a wallet account by ULID/GUID.';
