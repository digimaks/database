-- WALLET_PROVIDER core tables
CREATE TABLE IF NOT EXISTS wallet_provider.accounts (
    id              varchar(26)              NOT NULL DEFAULT generate_ulid(),
    active          boolean                  NOT NULL DEFAULT true,
    given_name      varchar(100),
    family_name     varchar(100),
    date_created    timestamptz              NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modified   timestamptz,
    CONSTRAINT accounts_id_pkey PRIMARY KEY (id)
);

CREATE TABLE IF NOT EXISTS wallet_provider.user_identifiers (
    id              bigserial                NOT NULL,
    account_id      varchar(26)              NOT NULL REFERENCES wallet_provider.accounts (id),
    identifier_type varchar(50)              NOT NULL,
    value           varchar(100)             NOT NULL,
    valid           boolean                  NOT NULL DEFAULT true,
    date_created    timestamptz              NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modified   timestamptz,
    active          boolean                  NOT NULL DEFAULT true,
    CONSTRAINT identifiers_id_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS user_identifiers_values_uniq
    ON wallet_provider.user_identifiers (account_id, identifier_type, value)
    WHERE active;

CREATE TABLE IF NOT EXISTS wallet_provider.user_contact_info (
    id              bigserial                NOT NULL,
    account_id      varchar(26)              NOT NULL REFERENCES wallet_provider.accounts (id),
    contact_type    varchar(50)              NOT NULL,
    value           varchar(100)             NOT NULL,
    date_created    timestamptz              NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modified   timestamptz,
    active          boolean                  NOT NULL DEFAULT true,
    CONSTRAINT contact_info_id_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS user_contact_info_values_uniq
    ON wallet_provider.user_contact_info (account_id, contact_type, value)
    WHERE active;

CREATE TABLE IF NOT EXISTS wallet_provider.instances (
    id                    varchar(26)  NOT NULL DEFAULT generate_ulid(),
    account_id            varchar(26)      REFERENCES wallet_provider.accounts (id),
    hardware_key_tag      varchar(50)  NOT NULL,
    public_key            text         NOT NULL,
    fid                   varchar(255),
    wscd_anchor_hash      varchar(64)  NOT NULL,
    wscd_type             varchar(50)  NOT NULL,
    device_label          varchar(32)  NOT NULL,
    hardware_identifiers  jsonb,
    active                boolean      NOT NULL DEFAULT true,
    date_created          timestamptz  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    date_modified         timestamptz,
    revoked_at            timestamptz,
    CONSTRAINT instances_id_pkey PRIMARY KEY (id)
);
CREATE INDEX IF NOT EXISTS instances_account_idx
    ON wallet_provider.instances (account_id)
    WHERE active;
CREATE UNIQUE INDEX IF NOT EXISTS instances_hardware_key_tag_uniq
    ON wallet_provider.instances (hardware_key_tag)
    WHERE active;

CREATE TABLE IF NOT EXISTS wallet_provider.revocation_info (
    id              bigserial    NOT NULL,
    instance_id     varchar(26)  NOT NULL REFERENCES wallet_provider.instances (id),
    status_list_uri varchar(128) NOT NULL,
    status_list_idx integer      NOT NULL,
    wua_expires_at  timestamptz  NOT NULL,
    active          boolean      NOT NULL DEFAULT true,
    CONSTRAINT revocation_info_pkey PRIMARY KEY (id)
);
CREATE UNIQUE INDEX IF NOT EXISTS revocation_info_status_uniq
    ON wallet_provider.revocation_info (status_list_uri, status_list_idx)
    WHERE active;

CREATE TABLE IF NOT EXISTS wallet_provider.parameters (
    name         varchar(64)  NOT NULL,
    value        varchar(128) NOT NULL,
    last_changed timestamptz  NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT parameters_pkey PRIMARY KEY (name)
);
