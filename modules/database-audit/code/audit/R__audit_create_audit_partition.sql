CREATE OR REPLACE PROCEDURE audit.create_audit_partition(
    IN pi_for_date date)
LANGUAGE 'plpgsql'
    SECURITY DEFINER
AS $BODY$
DECLARE
  v_date_from date;
  v_date_till date;
  v_date_from_tz character varying(2);
  v_date_till_tz character varying(2);
BEGIN
  v_date_from := date_trunc('month', pi_for_date)::date;
  v_date_till := (v_date_from + interval '1 month' - interval '1 day')::date;
  v_date_from_tz := LPAD((EXTRACT(TIMEZONE_HOUR FROM v_date_from::timestamptz))::text, 2, '0');
  v_date_till_tz := LPAD((EXTRACT(TIMEZONE_HOUR FROM (v_date_till + interval '1 day')::timestamptz))::text, 2, '0');
  EXECUTE 'CREATE TABLE IF NOT EXISTS audit.person_data_requests_' || to_char(v_date_from, 'yyyy_mm') ||
    ' PARTITION OF audit.person_data_requests FOR VALUES' ||
    ' FROM (''' || v_date_from::text || ' 00:00:00+' || v_date_from_tz || ''') TO (''' || v_date_till::text || ' 23:59:59.999999+' || v_date_till_tz || ''')';
END;
$BODY$;

ALTER PROCEDURE audit.create_audit_partition(date) OWNER TO lx;

REVOKE ALL ON PROCEDURE audit.create_audit_partition(date) FROM PUBLIC;

GRANT EXECUTE ON PROCEDURE audit.create_audit_partition(date) TO lx_public;

COMMENT ON PROCEDURE audit.create_audit_partition(date)
    IS 'Personas datu audita tabulas nodalījuma izveidošana norādītajam datumam';
