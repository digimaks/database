CREATE OR REPLACE FUNCTION util.to_timestamp(
	pi_date character varying)
    RETURNS timestamp without time zone
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY INVOKER PARALLEL SAFE
AS $BODY$
BEGIN
  SET datestyle = dmy;

  IF pi_date IS NULL OR pi_date = '' THEN
    RETURN NULL;
  END IF;

  RETURN pi_date::timestamp without time zone;
END;
$BODY$;

ALTER FUNCTION util.to_timestamp(character varying) OWNER TO lx;
COMMENT ON FUNCTION util.to_timestamp(character varying) IS 'String datuma konvertēšana uz timestamp without time zone';
