-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE audit.insert_person_data_request(
    pi_data audit.person_data_requests)
LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $body$
BEGIN
  INSERT INTO audit.person_data_requests(
              req_person_id,
              req_person_code,
              person_code,
              action_code,
              ip_address,
              client_code,
              req_data)
      VALUES (pi_data.req_person_id,
              pi_data.req_person_code,
              pi_data.person_code,
              pi_data.action_code,
              pi_data.ip_address,
              pi_data.client_code,
              pi_data.req_data);
EXCEPTION
    WHEN others THEN
        IF sqlstate = '23514' AND sqlerrm LIKE 'no partition of relation "%" found for row' THEN
            CALL audit.create_audit_partition(current_date);
        ELSE
            RAISE;
        END IF;

        -- Retry after partition created.
        INSERT INTO audit.person_data_requests(
                    req_person_id,
                    req_person_code,
                    person_code,
                    action_code,
                    ip_address,
                    client_code,
                    req_data)
            VALUES (pi_data.req_person_id,
                    pi_data.req_person_code,
                    pi_data.person_code,
                    pi_data.action_code,
                    pi_data.ip_address,
                    pi_data.client_code,
                    pi_data.req_data);
END
$body$;

ALTER PROCEDURE audit.insert_person_data_request(audit.person_data_requests) OWNER TO digimaks;

GRANT EXECUTE ON PROCEDURE audit.insert_person_data_request(audit.person_data_requests) TO digimaks;

REVOKE ALL ON PROCEDURE audit.insert_person_data_request(audit.person_data_requests) FROM PUBLIC;

COMMENT ON PROCEDURE audit.insert_person_data_request(audit.person_data_requests)
    IS 'Saglabā personas datu pieprasījumu';
