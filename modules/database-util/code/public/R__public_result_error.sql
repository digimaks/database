CREATE OR REPLACE FUNCTION public.result_error(pi_code text, pi_error text)
    RETURNS json
    LANGUAGE 'plpgsql'
    COST 100
    IMMUTABLE PARALLEL SAFE
AS $BODY$
BEGIN
  RETURN json_build_object('code', pi_code, 'error', pi_error);
END;
$BODY$;

ALTER FUNCTION public.result_error(text, text) OWNER TO lx;

COMMENT ON FUNCTION public.result_error(text, text)
    IS 'Sagatavo standarta formata klūdainas operācijas atbildi';
