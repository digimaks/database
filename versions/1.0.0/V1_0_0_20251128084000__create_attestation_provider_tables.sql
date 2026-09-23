-- ATTESTATION_PROVIDER tables derived from dbdiagram_ap.io
CREATE TABLE IF NOT EXISTS attestation_provider.credential_issuances (
    id                       varchar(26)  NOT NULL DEFAULT generate_ulid(),
    credential_identifier    varchar(50),
    format                   varchar(20)  NOT NULL,
    doctype_vct              varchar(100) NOT NULL,
    issued_at                timestamptz  NOT NULL,
    expires_at               timestamptz  NOT NULL,
    revoked_at               timestamptz,
    active                   boolean      NOT NULL DEFAULT true,
    holder_identifier_value  varchar(100),
    holder_identifier_type   varchar(20),
    holder_given_name        varchar(100),
    holder_family_name       varchar(100),
    wallet_provider          varchar(512),
    wallet_status_type       varchar(20),
    wallet_status_uri        text,
    wallet_status_index      integer,
    date_created             timestamptz  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modified            timestamptz,
    install_status           varchar(26)  NOT NULL,
    install_message          varchar(300),
    CONSTRAINT issuances_id_pkey PRIMARY KEY (id)
);
ALTER TABLE attestation_provider.credential_issuances OWNER TO digimaks;
CREATE INDEX IF NOT EXISTS issuances_holder_value_idx
    ON attestation_provider.credential_issuances (holder_identifier_type, holder_identifier_value)
    WHERE active
      AND holder_identifier_type IS NOT NULL
      AND holder_identifier_value IS NOT NULL;

CREATE TABLE IF NOT EXISTS attestation_provider.revocation_info (
    id                     bigserial    NOT NULL,
    credential_issuance_id varchar(26)  NOT NULL REFERENCES attestation_provider.credential_issuances (id),
    status_list_uri        varchar(128) NOT NULL,
    status_list_idx        integer      NOT NULL,
    active                 boolean      NOT NULL DEFAULT true,
    CONSTRAINT revocation_info_pkey PRIMARY KEY (id)
);
ALTER TABLE attestation_provider.revocation_info OWNER TO digimaks;
CREATE UNIQUE INDEX IF NOT EXISTS revocation_info_status_uniq
    ON attestation_provider.revocation_info (status_list_uri, status_list_idx)
    WHERE active;
