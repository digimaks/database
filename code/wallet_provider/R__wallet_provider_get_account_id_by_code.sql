-- SPDX-License-Identifier: EUPL-1.2
-- TODO jācaurskata, pēc loģikas un identifikatoriem, piem PNOLV

CREATE OR REPLACE FUNCTION wallet_provider.get_account_id_by_code(
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

    SELECT account_id
      INTO v_result
      FROM wallet_provider.user_identifiers
     WHERE identifier_type = 'person_code' --  iespējams jāatstāj 'person_code' bet jāuztaisa general tabula, kur mapojas PNOLV uz person_code, jo PNO vienmēr pēc etsi būs personas kods (identifikators)
       AND value = pi_value
       AND active
     ORDER BY date_created DESC
     LIMIT 1;

    RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION wallet_provider.get_account_id_by_code(varchar) TO digimaks;
REVOKE ALL ON FUNCTION wallet_provider.get_account_id_by_code(varchar) FROM PUBLIC;

COMMENT ON FUNCTION wallet_provider.get_account_id_by_code(varchar)
    IS 'Finds a wallet account by personal code identifier.';
