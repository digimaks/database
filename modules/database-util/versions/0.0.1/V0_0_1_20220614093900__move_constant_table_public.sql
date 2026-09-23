DROP TABLE IF EXISTS util.global_constants;

CREATE TABLE IF NOT EXISTS public.global_constants
(
    id serial NOT NULL,
    "key" varchar NOT NULL,
    "value" varchar NOT NULL,
    CONSTRAINT global_constants_pkey PRIMARY KEY (id)
        USING INDEX TABLESPACE lx_index
);

ALTER TABLE IF EXISTS public.global_constants
    OWNER to lx;

COMMENT ON TABLE public.global_constants
    IS 'Globāli izmantojamas konstantes';

COMMENT ON COLUMN public.global_constants.id
    IS 'Ieraksta identifikators';

COMMENT ON COLUMN public.global_constants.key
    IS 'Konstantes nosaukums';

COMMENT ON COLUMN public.global_constants.value
    IS 'Konstantes vērtība';

CREATE UNIQUE INDEX IF NOT EXISTS public_constants_key_uniq
    ON public.global_constants USING btree
    (key COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE lx_index;

-- Also move functions to public schema
DROP FUNCTION IF EXISTS util.get_global_constant;
DROP FUNCTION IF EXISTS util.result_success;
DROP FUNCTION IF EXISTS util.result_error;