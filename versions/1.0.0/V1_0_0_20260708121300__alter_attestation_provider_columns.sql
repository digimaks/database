ALTER TABLE attestation_provider.revocation_info
    ALTER COLUMN status_list_uri TYPE varchar(1024);

ALTER TABLE attestation_provider.credential_issuances
    ALTER COLUMN credential_identifier TYPE varchar(512);