CREATE OR REPLACE FUNCTION audit.get_legal_entity_prefix(number_length integer)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 10
    VOLATILE SECURITY DEFINER
AS $BODY$
DECLARE
    v_const_name character varying;
begin
    IF (number_length <= 9) THEN
        v_const_name := 'legal_entity_short_number_prefix';
    ELSE
        v_const_name := 'legal_entity_long_number_prefix';
    END IF;
  return get_global_constant(v_const_name);
end;
$BODY$;

ALTER FUNCTION audit.get_legal_entity_prefix(integer)
    OWNER TO lx;

REVOKE ALL ON FUNCTION audit.get_legal_entity_prefix(integer) FROM PUBLIC;

COMMENT ON FUNCTION audit.get_legal_entity_prefix(integer)
    IS 'Juridiskās personas koda prefikss';
