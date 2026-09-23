CREATE OR REPLACE PROCEDURE audit.audit_person_data(
  pi_req_person_id character varying,
  pi_req_person_code character varying,
  pi_req_person_first_name character varying,
  pi_req_person_last_name character varying,
  pi_req_org_regnum character varying,
  pi_req_org_title character varying,
  pi_person_code character varying,
  pi_action_code character varying,
  pi_action_id bigint,
  pi_ip_address inet)
LANGUAGE 'plpgsql'
AS $BODY$
DECLARE
  v_audit audit.person_data_requests%rowtype;
BEGIN
  v_audit.req_person_id := nullif(pi_req_person_id, '');
  v_audit.req_person_code := nullif(REPLACE(pi_req_person_code, '-', ''), '');
  v_audit.req_data := '{}'::jsonb;

  IF v_audit.req_person_id IS NULL THEN
    IF v_audit.req_person_code IS NOT NULL THEN
      v_audit.req_person_id := audit.get_physical_person_prefix() || ':' || v_audit.req_person_code;
    END IF;

    IF (nullif(pi_req_org_regnum, '') IS NOT NULL) THEN
      IF (v_audit.req_person_id IS NOT NULL) THEN
        v_audit.req_person_id := v_audit.req_person_id || '-';
      END IF;

      v_audit.req_person_id := COALESCE(v_audit.req_person_id, '') || audit.get_legal_entity_prefix(LENGTH(pi_req_org_regnum)) || ':' || pi_req_org_regnum;
    END IF;
  END IF;

  IF (v_audit.req_person_code IS NULL AND  nullif(pi_req_org_regnum, '') IS NOT NULL) THEN
    IF (LENGTH(pi_req_org_regnum) <= 9) THEN
      v_audit.req_person_code := 'VI' || pi_req_org_regnum;
    ELSE
      v_audit.req_person_code := pi_req_org_regnum;
    END IF;
  END IF;

  IF v_audit.req_person_code IS NULL THEN
    raise exception 'Nav norādīts datu pieprasītāja personas kods vai iestādes reģistrācijas numurs';
  END IF;

  IF (pi_req_person_first_name IS NOT NULL) THEN
    v_audit.req_data := jsonb_set(v_audit.req_data, '{firstName}', to_jsonb(pi_req_person_first_name));
  END IF;
  IF (pi_req_person_last_name IS NOT NULL) THEN
    v_audit.req_data := jsonb_set(v_audit.req_data, '{lastName}', to_jsonb(pi_req_person_last_name));
  END IF;
  IF pi_req_org_title IS NOT NULL THEN
    v_audit.req_data := jsonb_set(v_audit.req_data, '{orgTitle}', to_jsonb(pi_req_org_title));
  END IF;

  INSERT INTO audit.person_data_requests(req_person_id, req_person_code, person_code, action_code, action_id, ip_address, req_data)
       VALUES (v_audit.req_person_id, v_audit.req_person_code, pi_person_code, pi_action_code, pi_action_id, pi_ip_address, v_audit.req_data);
END;
$BODY$;

ALTER PROCEDURE audit.audit_person_data(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint, inet)
  OWNER TO lx;

REVOKE ALL ON PROCEDURE audit.audit_person_data(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint, inet)
  FROM PUBLIC;

COMMENT ON PROCEDURE audit.audit_person_data(character varying, character varying, character varying, character varying, character varying, character varying, character varying, character varying, bigint, inet)
    IS 'Personas datu audita ieraksta izveidošana';
