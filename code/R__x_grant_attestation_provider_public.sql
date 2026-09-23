-- SPDX-License-Identifier: EUPL-1.2


-- TOTO, while issuing instances and credentials is done via api_wallet (same service), reading credentials is done via wallet_public
-- IF issuance of instances and credentials is splited to different services, wallet_public should not have access to read credentials
-- NEW role, for example "credential_public" should be created and GRANT USAGE and EXECUTE should be given to it instead of wallet_public

GRANT USAGE ON SCHEMA attestation_provider TO wallet_public;
GRANT USAGE ON SCHEMA attestation_provider TO issuer_public;

GRANT EXECUTE ON PROCEDURE attestation_provider.record_credential_issuance(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE attestation_provider.record_credential_issuance(jsonb, jsonb) TO issuer_public;
-- GRANT EXECUTE ON FUNCTION attestation_provider.get_credential_by_id(varchar) TO wallet_public;
-- GRANT EXECUTE ON FUNCTION attestation_provider.list_credentials_by_holder(varchar, varchar, boolean) TO wallet_public;
-- GRANT EXECUTE ON PROCEDURE attestation_provider.revoke_credential(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE attestation_provider.update_install_status(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE attestation_provider.update_install_status(jsonb, jsonb) TO issuer_public;
-- GRANT EXECUTE ON PROCEDURE attestation_provider.cleanup_expired_credentials(jsonb, jsonb) TO wallet_public;
-- GRANT EXECUTE ON FUNCTION attestation_provider.get_credentials_for_revocation(varchar) TO wallet_public;
