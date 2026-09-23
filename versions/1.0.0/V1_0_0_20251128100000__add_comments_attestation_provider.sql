-- SPDX-License-Identifier: EUPL-1.2

COMMENT ON COLUMN attestation_provider.credential_issuances.id IS 'Auto-generated primary key';
COMMENT ON COLUMN attestation_provider.credential_issuances.credential_identifier IS 'Credential Identifier in the issuer metadata';
COMMENT ON COLUMN attestation_provider.credential_issuances.format IS '''mso_mdoc'' or ''dc+sd-jwt''';
COMMENT ON COLUMN attestation_provider.credential_issuances.doctype_vct IS 'doctype for mdoc, vct for SD-JWT VC';
COMMENT ON COLUMN attestation_provider.credential_issuances.issued_at IS 'Credential issuance time';
COMMENT ON COLUMN attestation_provider.credential_issuances.expires_at IS 'Credential expiration time';
COMMENT ON COLUMN attestation_provider.credential_issuances.revoked_at IS 'Timestamp of credential revocation';
COMMENT ON COLUMN attestation_provider.credential_issuances.active IS 'Should be set to false when revoked or expired';
COMMENT ON COLUMN attestation_provider.credential_issuances.holder_identifier_value IS 'Credential holder identification string for finding credentials to be revoked';
COMMENT ON COLUMN attestation_provider.credential_issuances.holder_identifier_type IS 'User identifier type (Based on ETSI identifiers, example: ''PNOLV'', etc.)';
COMMENT ON COLUMN attestation_provider.credential_issuances.holder_given_name IS 'Credential holder given name for auditing purposes';
COMMENT ON COLUMN attestation_provider.credential_issuances.holder_family_name IS 'Credential holder family name for auditing purposes';
COMMENT ON COLUMN attestation_provider.credential_issuances.wallet_provider IS 'Wallet provider ID';
COMMENT ON COLUMN attestation_provider.credential_issuances.wallet_status_type IS 'Wallet status issuer type (''identifier_list'' or ''status_list'')';
COMMENT ON COLUMN attestation_provider.credential_issuances.wallet_status_uri IS 'Wallet status URI';
COMMENT ON COLUMN attestation_provider.credential_issuances.wallet_status_index IS 'Wallet status ''idx'' (for Status List type) or ''id'' (for Identifier List type)';
COMMENT ON COLUMN attestation_provider.credential_issuances.date_created IS 'Timestamp when record was created';
COMMENT ON COLUMN attestation_provider.credential_issuances.date_modified IS 'Timestamp of last modification';
COMMENT ON COLUMN attestation_provider.credential_issuances.install_status IS 'Status ''installed'' is set if the wallet sends acknowledgment of credential acceptance (not mandatory for wallets)';
COMMENT ON COLUMN attestation_provider.credential_issuances.install_message IS 'Message retrieved from the wallet, if wallet sends an acknowledgement';

COMMENT ON COLUMN attestation_provider.revocation_info.id IS 'Auto-generated primary key';
COMMENT ON COLUMN attestation_provider.revocation_info.credential_issuance_id IS 'Reference to respective credential issuance record';
COMMENT ON COLUMN attestation_provider.revocation_info.status_list_uri IS 'Status list URI';
COMMENT ON COLUMN attestation_provider.revocation_info.status_list_idx IS 'Index value in the status list';
COMMENT ON COLUMN attestation_provider.revocation_info.active IS 'Should be set to false when credential is revoked or expired to exclude from DB index';