-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE FUNCTION session.get_user_data()
    RETURNS record
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY DEFINER PARALLEL UNSAFE
AS $body$
DECLARE
  v_user record;
BEGIN
  SELECT *
    INTO v_user
    FROM session_state;

  IF v_user.user_id IS NULL THEN
    RAISE EXCEPTION 'Session not initialized. Call session.create() first.';
  END IF;

  RETURN v_user;
END;
$body$;

GRANT EXECUTE ON FUNCTION session.get_user_data() TO digimaks;
REVOKE ALL ON FUNCTION session.get_user_data() FROM PUBLIC;

COMMENT ON FUNCTION session.get_user_data()
    IS 'Returns the user data for the current session.';
