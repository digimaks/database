-- Links a credential issuance to the wallet_provider.instances device whose
-- Key Attestation minted the credential-binding key — resolved from
-- hardware_key_tag inside record_credential_issuance, not trusted from the
-- caller directly. Nullable: not every issuance resolves to a known device
-- (e.g. the JWE-response path, or a KA minted before this migration).
-- First cross-schema FK in this database — deliberate, Postgres supports it
-- natively within one database.
ALTER TABLE attestation_provider.credential_issuances
    ADD COLUMN instance_id varchar(26) REFERENCES wallet_provider.instances (id);
