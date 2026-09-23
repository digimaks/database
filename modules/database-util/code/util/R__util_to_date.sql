CREATE OR REPLACE FUNCTION util.to_date(
	pi_date character varying)
    RETURNS date
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE SECURITY INVOKER PARALLEL SAFE
AS $BODY$
BEGIN
  SET datestyle = dmy;

  IF pi_date IS NULL OR pi_date = '' THEN
    RETURN NULL;
  END IF;

  RETURN pi_date::date;
END;
$BODY$;

ALTER FUNCTION util.to_date(character varying) OWNER TO lx;
COMMENT ON FUNCTION util.to_date(character varying) IS 'String datuma konvertēšana uz date';
