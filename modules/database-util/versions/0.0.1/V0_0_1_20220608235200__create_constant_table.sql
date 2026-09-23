CREATE TABLE IF NOT EXISTS util.global_constants
(
    id serial NOT NULL,
    "key" varchar NOT NULL,
    "value" varchar NOT NULL,
    CONSTRAINT global_constants_pkey PRIMARY KEY (id)
        USING INDEX TABLESPACE lx_index
);

ALTER TABLE IF EXISTS util.global_constants
    OWNER to lx;

COMMENT ON TABLE util.global_constants
    IS 'Globāli izmantojamas konstantes';

COMMENT ON COLUMN util.global_constants.id
    IS 'Ieraksta identifikators';

COMMENT ON COLUMN util.global_constants.key
    IS 'Konstantes nosaukums';

COMMENT ON COLUMN util.global_constants.value
    IS 'Konstantes vērtība';

CREATE UNIQUE INDEX IF NOT EXISTS util_constants_key_uniq
    ON util.global_constants USING btree
    (key COLLATE pg_catalog."default" ASC NULLS LAST)
    TABLESPACE lx_index;
