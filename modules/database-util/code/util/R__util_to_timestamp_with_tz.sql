CREATE OR REPLACE FUNCTION util.to_timestamp_with_tz(
	pi_date character varying)
    RETURNS timestamp with time zone
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY INVOKER PARALLEL SAFE
AS $BODY$
BEGIN
  SET datestyle = dmy;

  IF pi_date IS NULL OR pi_date = '' THEN
    RETURN NULL;
  END IF;

  RETURN pi_date::timestamp with time zone;
END;
$BODY$;

ALTER FUNCTION util.to_timestamp_with_tz(character varying) OWNER TO lx;
COMMENT ON FUNCTION util.to_timestamp_with_tz(character varying) IS 'String datuma konvertēšana uz timestamp with time zone';
