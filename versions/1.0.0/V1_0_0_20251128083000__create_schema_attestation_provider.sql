-- Create attestation_provider schema
CREATE SCHEMA IF NOT EXISTS attestation_provider AUTHORIZATION digimaks;
COMMENT ON SCHEMA attestation_provider IS 'Attestation provider schema for digimaks. Contains data regarding attestation instances and records.';

GRANT ALL ON SCHEMA attestation_provider TO digimaks;