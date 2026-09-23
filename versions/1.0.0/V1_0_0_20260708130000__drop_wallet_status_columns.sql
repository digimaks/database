-- wallet_status_type/uri/index duplicated attestation_provider.revocation_info
-- (the actual source of truth, and the only place that can hold >1 slot per
-- issuance for batch credentials). wallet_status_type only ever distinguished
-- 'identifier_list' vs 'status_list' — ADR-001 commits this project to
-- status_list only, so that distinction never applied here.
ALTER TABLE attestation_provider.credential_issuances
    DROP COLUMN wallet_status_type,
    DROP COLUMN wallet_status_uri,
    DROP COLUMN wallet_status_index;
