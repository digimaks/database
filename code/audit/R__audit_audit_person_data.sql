-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE audit.audit_person_data(
    IN pi_data text,
    INOUT po_data text)
LANGUAGE 'plpgsql'
SECURITY DEFINER
AS $body$
DECLARE
  v_data    jsonb;
  v_audit   audit.person_data_requests%rowtype;
  v_session record;
  v_request jsonb := '{}'::jsonb;
BEGIN
  v_data := pi_data::jsonb;

  SELECT id, user_id, user_code, given_name, family_name, role_code, ip_addr
  INTO v_session
  FROM session.get_user_data() AS (
                                   id varchar(26),
                                   user_id varchar(50),
                                   user_code varchar(20),
                                   given_name varchar(100),
                                   family_name varchar(100),
                                   role_code varchar(20),
                                   ip_addr inet
    );

  v_audit.req_person_id := nullif(v_session.user_id, '');
  v_audit.req_person_code := nullif(replace(v_session.user_code, '-', ''), '');
  IF v_audit.req_person_code IS NULL AND v_audit.req_person_id != 'SYSTEM' THEN
    RAISE EXCEPTION 'Nav norādīts datu pieprasītāja personas kods';
  END IF;

  IF v_audit.req_person_id IS NULL THEN
    IF v_audit.req_person_code IS NOT NULL THEN
      v_audit.req_person_id := 'PNOLV-' || v_audit.req_person_code;
    END IF;
  END IF;

  v_audit.person_code := v_data -> 'person' ->> 'identifier';
  v_audit.action_code := v_data ->> 'action';
  v_audit.ip_address := (v_data ->> 'ipAddress')::inet;
  v_audit.client_code := v_data ->> 'clientId';

  -- Store resource, person and other request data as jsonb.
  v_audit.req_data := '{}'::jsonb;
  IF v_data ->> 'person' IS NOT NULL THEN
    v_audit.req_data := jsonb_set(v_audit.req_data, '{person}', v_data -> 'person');
  END IF;
  IF v_data ->> 'resources' IS NOT NULL THEN
    v_audit.req_data := jsonb_set(v_audit.req_data, '{resources}', v_data -> 'resources');
  END IF;

  IF v_data -> 'endpoint' IS NOT NULL THEN
    v_request := jsonb_set(v_request, '{endpoint}', v_data -> 'endpoint');
  END IF;
  IF v_data -> 'requestParameters' IS NOT NULL THEN
    v_request := jsonb_set(v_request, '{parameters}', v_data -> 'requestParameters');
  END IF;
  IF v_data -> 'userAgent' IS NOT NULL THEN
    v_request := jsonb_set(v_request, '{userAgent}', v_data -> 'userAgent');
  END IF;

  v_audit.req_data := jsonb_set(v_audit.req_data, '{request}', v_request);

  CALL audit.insert_person_data_request(v_audit);
  po_data := result_success(NULL::json);
END;
$body$;

ALTER PROCEDURE audit.audit_person_data(text, text) OWNER TO digimaks;

REVOKE ALL ON PROCEDURE audit.audit_person_data(text, text) FROM PUBLIC;

COMMENT ON PROCEDURE audit.audit_person_data(text, text)
    IS 'Personas datu audita ieraksta izveidošana autorizētam lietotājam';
