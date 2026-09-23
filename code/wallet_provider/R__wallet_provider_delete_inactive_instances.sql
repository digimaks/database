-- SPDX-License-Identifier: EUPL-1.2
-- vai šādas vispār mums jaunajā risinājumā ir pieejamas? TODO pārbaudīt

CREATE OR REPLACE PROCEDURE wallet_provider.delete_inactive_instances(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg         text;
    v_payload           jsonb;
    v_older_than_in_min integer;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);
    v_older_than_in_min := coalesce(nullif((v_payload ->> 'OlderThanInMin')::integer, 0), 60);

    UPDATE wallet_provider.instances
       SET active        = false,
           revoked_at    = coalesce(revoked_at, now()),
           date_modified = now()
     WHERE account_id is null
       AND date_created < (now() - (v_older_than_in_min * interval '1 minute'))
       AND active;

    po_data := result_success(NULL::json);
exception
    WHEN others THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := result_error('err:internal:db', v_error_msg);
        RETURN;
END;
$$;

GRANT EXECUTE ON PROCEDURE wallet_provider.delete_inactive_instances(jsonb, jsonb) TO digimaks;
REVOKE ALL ON PROCEDURE wallet_provider.delete_inactive_instances(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet_provider.delete_inactive_instances(jsonb, jsonb)
    IS 'Soft-deletes anonymous wallet instances older than the configured threshold.';