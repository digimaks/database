CREATE SCHEMA IF NOT EXISTS session AUTHORIZATION digimaks;
COMMENT ON SCHEMA session IS 'Session schema.';

GRANT ALL ON SCHEMA audit, util, session TO digimaks;
