-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE session."create"(
  IN pi_id varchar,
  IN pi_user_id varchar,
  IN pi_user_code varchar,
  IN pi_given_name varchar,
  IN pi_family_name varchar,
  IN pi_role_code varchar,
  IN pi_ip_addr inet)
LANGUAGE 'plpgsql'
SECURITY DEFINER
AS $body$
DECLARE
BEGIN
  CREATE TEMP TABLE IF NOT EXISTS session_state(
    id varchar(26),
    user_id varchar(50),
    user_code varchar(20),
    given_name varchar(100),
    family_name varchar(100),
    role_code varchar(20),
    ip_addr inet
  ) ON COMMIT DELETE ROWS;
  DELETE FROM session_state;
  INSERT INTO session_state (
              id,
              user_id,
              user_code,
              given_name,
              family_name,
              role_code,
              ip_addr)
      VALUES (nullif(pi_id, ''),
              nullif(pi_user_id, ''),
              nullif(replace(pi_user_code, '-', ''), ''),
              nullif(pi_given_name, ''),
              nullif(pi_family_name, ''),
              nullif(pi_role_code, ''),
              pi_ip_addr);
END;
$body$;

GRANT EXECUTE ON PROCEDURE session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet) TO digimaks;
REVOKE ALL ON PROCEDURE session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet) FROM PUBLIC;

COMMENT ON PROCEDURE session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet)
    IS 'Initializes the user session state.';
