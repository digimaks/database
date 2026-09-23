CREATE OR REPLACE FUNCTION public.result_success(pi_data json)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL SAFE
AS $BODY$
BEGIN
  RETURN json_build_object('success', true, 'data', pi_data);
END;
$BODY$;

ALTER FUNCTION public.result_success(json) OWNER TO lx;

COMMENT ON FUNCTION public.result_success(json)
    IS 'Sagatavo standarta formata veiksmīgas operācijas atbildi';
