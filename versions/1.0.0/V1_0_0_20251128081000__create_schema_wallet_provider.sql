CREATE SCHEMA IF NOT EXISTS wallet_provider AUTHORIZATION digimaks;
COMMENT ON SCHEMA wallet_provider IS 'Wallet provider schema for digimaks. Contains data regarding wallet instances and accounts.';

GRANT ALL ON SCHEMA wallet_provider TO digimaks;