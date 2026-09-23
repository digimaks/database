-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE audit.insert_failure_event(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg text;
    v_payload   jsonb;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);

    INSERT INTO audit.failure_events(
        occurred_at, service, endpoint, error_message, status_code, app_instance_id)
    VALUES (
        coalesce((v_payload ->> 'occurred_at')::timestamptz, CURRENT_TIMESTAMP),
        nullif(trim((v_payload ->> 'service')), ''),
        nullif(trim((v_payload ->> 'endpoint')), ''),
        nullif((v_payload ->> 'error_message'), ''),
        (v_payload ->> 'status_code')::integer,
        nullif(trim((v_payload ->> 'app_instance_id')), ''));

    po_data := jsonb_build_object('success', true);

EXCEPTION
    WHEN others THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := jsonb_build_object('success', false, 'code', 'err:internal:db', 'error', v_error_msg);
        RETURN;
END;
$$;

ALTER PROCEDURE audit.insert_failure_event(jsonb, jsonb) OWNER TO digimaks;
REVOKE ALL ON PROCEDURE audit.insert_failure_event(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE audit.insert_failure_event(jsonb, jsonb)
    IS 'Saglabā kļūdas atbildes audita ierakstu (service, endpoint, error, status, app instance)';
