-- SPDX-License-Identifier: EUPL-1.2
-- TODO jācaurskata, pēc loģikas un identifikatoriem, piem PNOLV, skatīt komentāru. Gintam tur ir atsevišķa funkcija šim mērķiem.
CREATE OR REPLACE FUNCTION wallet_provider.get_account_data(
    pi_account_id varchar)
    RETURNS jsonb
    LANGUAGE plpgsql
    STABLE SECURITY DEFINER 
    PARALLEL SAFE
AS
$$
DECLARE
    v_result jsonb;
BEGIN
    if pi_account_id is null or btrim(pi_account_id) = '' then
        return null;
    end if;

    SELECT row_to_json(rec)
      INTO v_result
      FROM (
            SELECT a.id                                       AS id,
                   a.given_name                               AS "givenName",
                   a.family_name                              AS "familyName",
                   (SELECT ui.value
                      FROM wallet_provider.user_identifiers ui
                     WHERE ui.account_id = a.id
--                        AND ui.identifier_type = 'PNOLV' --  iespējams jāatstāj 'person_code' bet jāuztaisa general tabula, kur mapojas PNOLV uz person_code, jo PNO vienmēr pēc etsi būs personas kods (identifikators)
                       AND ui.active
                     ORDER BY ui.date_created DESC
                     LIMIT 1)                                 as code,
                     coalesce(
                       json_agg(
                         json_build_object(
                           'type', uci.contact_type,
                           'value', uci.value
                         )
                         ORDER BY uci.date_created
                       ),
                       '[]'::json
                     ) AS contacts
              FROM wallet_provider.accounts a
                   LEFT JOIN wallet_provider.user_contact_info uci
                             ON a.id = uci.account_id AND uci.active
             WHERE a.id = pi_account_id
               AND a.active
             GROUP BY a.id, a.given_name, a.family_name
           ) rec;

    RETURN v_result;
END;
$$;

GRANT EXECUTE ON FUNCTION wallet_provider.get_account_data(varchar) TO digimaks;

REVOKE ALL ON FUNCTION wallet_provider.get_account_data(varchar) FROM PUBLIC;

COMMENT ON FUNCTION wallet_provider.get_account_data(varchar)
    IS 'Returns wallet account profile data with identifiers and contacts.';