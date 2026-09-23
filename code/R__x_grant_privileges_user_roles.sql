-- SPDX-License-Identifier: EUPL-1.2

-- Grant privileges for user_read_role;

DO $$
    DECLARE
        myschema RECORD;
    BEGIN
GRANT CONNECT ON DATABASE digimaks TO user_read_role; -- atļauja pieslēgties digimaks datubāzei
        FOR myschema IN (SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT LIKE 'pg_%' AND schema_name <> 'information_schema')
        LOOP
            EXECUTE format ('GRANT USAGE ON SCHEMA %I TO user_read_role', myschema.schema_name);
            EXECUTE format ('GRANT SELECT ON ALL TABLES IN SCHEMA %I TO user_read_role', myschema.schema_name);
        END LOOP;
    END;
    $$ LANGUAGE plpgsql;

-- Grant privileges for user_write_role;

DO $$
    DECLARE
        myschema RECORD;
    BEGIN
GRANT CONNECT ON DATABASE digimaks TO user_write_role; -- atļauja pieslēgties digimaks datubāzei
        FOR myschema IN (SELECT schema_name FROM information_schema.schemata WHERE schema_name NOT LIKE 'pg_%' AND schema_name <> 'information_schema' and schema_name NOT LIKE 'public')
        LOOP
            EXECUTE format ('GRANT USAGE ON SCHEMA %I TO user_write_role', myschema.schema_name);
            EXECUTE format ('GRANT USAGE ON SCHEMA public TO user_write_role', myschema.schema_name);
            EXECUTE format ('GRANT INSERT, UPDATE, DELETE, SELECT ON ALL TABLES IN SCHEMA %I TO user_write_role', myschema.schema_name);
            EXECUTE format ('GRANT INSERT, UPDATE, DELETE, SELECT ON ALL TABLES IN SCHEMA public TO user_write_role', myschema.schema_name);
            EXECUTE format ('GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA %I TO user_write_role', myschema.schema_name);
            EXECUTE format ('GRANT ALL ON ALL FUNCTIONS IN SCHEMA %I TO user_write_role', myschema.schema_name);
            EXECUTE format ('GRANT ALL ON ALL PROCEDURES IN SCHEMA  %I TO user_write_role', myschema.schema_name);
        END LOOP;
    END;
    $$ LANGUAGE plpgsql;
