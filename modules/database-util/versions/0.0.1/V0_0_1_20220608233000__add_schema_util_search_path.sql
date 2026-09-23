DO $$
DECLARE
    v_search_path_setting character varying := 'search_path';
    v_new_schema character varying := 'util';
    v_search_paths text[];
BEGIN
    v_search_paths := STRING_TO_ARRAY(current_setting(v_search_path_setting), ',');

    IF v_new_schema = ANY(v_search_paths) THEN
        return;
    END IF;
        
    v_search_paths := array_append(v_search_paths, v_new_schema);
    UPDATE pg_settings SET setting =  array_to_string (v_search_paths, ',') WHERE name = v_search_path_setting;
    return;
END $$
