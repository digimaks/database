CREATE OR REPLACE FUNCTION audit.get_physical_person_prefix()
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 10
    STABLE SECURITY DEFINER
AS $BODY$
begin
  return get_global_constant('physical_person_prefix');
end;
$BODY$;

ALTER FUNCTION audit.get_physical_person_prefix()
    OWNER TO lx;

REVOKE ALL ON FUNCTION audit.get_physical_person_prefix() FROM PUBLIC;

COMMENT ON FUNCTION audit.get_physical_person_prefix()
    IS 'Fiziskās personas koda prefikss';
