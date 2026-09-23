CREATE TABLE IF NOT EXISTS audit.person_data_requests
(
    id bigserial NOT NULL,
    "timestamp" timestamp with time zone NOT NULL DEFAULT CURRENT_TIMESTAMP,
    req_person_id character varying(250) COLLATE pg_catalog."default",
    req_person_code character varying(50) COLLATE pg_catalog."default",
    person_code character varying(50) COLLATE pg_catalog."default" NOT NULL,
    action_code character varying(50) COLLATE pg_catalog."default" NOT NULL,
    action_id bigint,
    ip_address inet,
    req_data jsonb,
    CONSTRAINT person_data_requests_pkey PRIMARY KEY (id, "timestamp")
) PARTITION BY RANGE (timestamp);

ALTER TABLE IF EXISTS audit.person_data_requests
    OWNER to lx;

COMMENT ON TABLE audit.person_data_requests
    IS 'Personas datu audits';

COMMENT ON COLUMN audit.person_data_requests.id
    IS 'Ieraksta identifikators';

COMMENT ON COLUMN audit.person_data_requests."timestamp"
    IS 'Laika zīmogs';

COMMENT ON COLUMN audit.person_data_requests.req_person_id
    IS 'Datu pieprasītāja identifikators';

COMMENT ON COLUMN audit.person_data_requests.req_person_code
    IS 'Datu pieprasītāja personas kods';

COMMENT ON COLUMN audit.person_data_requests.person_code
    IS 'Personas kods';

COMMENT ON COLUMN audit.person_data_requests.action_code
    IS 'Darbības kods';

COMMENT ON COLUMN audit.person_data_requests.action_id
    IS 'Darbības saistītais identifikators';

COMMENT ON COLUMN audit.person_data_requests.ip_address
    IS 'Pieprasītāja IP adrese';

COMMENT ON COLUMN audit.person_data_requests.req_data
    IS 'Papildus datu pieprasītāja dati (firstName, lastName)';
