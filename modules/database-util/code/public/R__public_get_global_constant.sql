CREATE OR REPLACE FUNCTION public.get_global_constant(constant_key character varying)
    RETURNS character varying
    LANGUAGE 'plpgsql'
    COST 100
    STABLE PARALLEL SAFE
AS $BODY$
BEGIN
  RETURN (select "value" from global_constants where "key" = constant_key);
END;
$BODY$;

ALTER FUNCTION public.get_global_constant(character varying) OWNER TO lx;

COMMENT ON FUNCTION public.get_global_constant(character varying)
    IS 'Atgriež globāli reģistrētas konstantes vērtību';
