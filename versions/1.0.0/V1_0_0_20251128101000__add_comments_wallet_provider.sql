-- SPDX-License-Identifier: EUPL-1.2
-- TODO caurskatīt un papildināt komentārus šeit, svarīgi lai skaids, kas tas ir un no kurienes ņemts

COMMENT ON COLUMN wallet_provider.accounts.id IS 'Auto-generated primary key';
COMMENT ON COLUMN wallet_provider.accounts.active IS 'True if active, false if soft deleted by user or system';
COMMENT ON COLUMN wallet_provider.accounts.given_name IS 'User given name if known';
COMMENT ON COLUMN wallet_provider.accounts.family_name IS 'User family name if known';
COMMENT ON COLUMN wallet_provider.accounts.date_created IS 'Timestamp when record was created';
COMMENT ON COLUMN wallet_provider.accounts.date_modified IS 'Timestamp of last modification';

COMMENT ON COLUMN wallet_provider.user_identifiers.id IS 'Auto-generated primary key';
COMMENT ON COLUMN wallet_provider.user_identifiers.account_id IS 'Reference to user account';
COMMENT ON COLUMN wallet_provider.user_identifiers.identifier_type IS 'User identifier type (Based on ETSI identifiers, example: ''PNOLV'', etc.)';
COMMENT ON COLUMN wallet_provider.user_identifiers.value IS 'User identifier value';
COMMENT ON COLUMN wallet_provider.user_identifiers.valid IS 'If false, it can not be used though is still visible for user as inactive';
COMMENT ON COLUMN wallet_provider.user_identifiers.date_created IS 'Timestamp when record was created';
COMMENT ON COLUMN wallet_provider.user_identifiers.date_modified IS 'Timestamp of last modification';
COMMENT ON COLUMN wallet_provider.user_identifiers.active IS 'False if deleted by user or system';

COMMENT ON COLUMN wallet_provider.user_contact_info.id IS 'Auto-generated primary key';
COMMENT ON COLUMN wallet_provider.user_contact_info.account_id IS 'Reference to user account';
COMMENT ON COLUMN wallet_provider.user_contact_info.contact_type IS 'Types: ''EMAIL'', ''PHONE''';
COMMENT ON COLUMN wallet_provider.user_contact_info.value IS 'Phone number, address etc';
COMMENT ON COLUMN wallet_provider.user_contact_info.date_created IS 'Timestamp when record was created';
COMMENT ON COLUMN wallet_provider.user_contact_info.date_modified IS 'Timestamp of last modification';
COMMENT ON COLUMN wallet_provider.user_contact_info.active IS 'True if active, false if deleted by user';

COMMENT ON COLUMN wallet_provider.instances.id IS 'Auto-generated primary key';
COMMENT ON COLUMN wallet_provider.instances.account_id IS 'Reference to user account';
COMMENT ON COLUMN wallet_provider.instances.hardware_key_tag IS 'Wallet HW secured key tag for WU identification. Taken from attestation.Result.HardwareKeyTag in POST /wallet/instance.';
COMMENT ON COLUMN wallet_provider.instances.public_key IS 'Public part of the wallet identification key. Taken from attestation.Result.PublicKey in POST /wallet/instance.';
COMMENT ON COLUMN wallet_provider.instances.fid IS 'Firebase identifier';
COMMENT ON COLUMN wallet_provider.instances.wscd_anchor_hash IS 'A digest of all data protected by device Verified Boot, should be always the same';
COMMENT ON COLUMN wallet_provider.instances.wscd_type IS 'Android: ''TrustedEnvironment'' vai ''StrongBox''; iOS: ''SECURE_ENCLAVE''';
COMMENT ON COLUMN wallet_provider.instances.device_label IS 'User given Device name from deviceLabel string in POST /wallet/instance. User SHALL BE able to change this name. For Android - manufacturer + model';
COMMENT ON COLUMN wallet_provider.instances.hardware_identifiers IS 'Device identifiers from deviceIdentifiers array in POST /wallet/instance. At least manufacturer and model shall be added, if available';
COMMENT ON COLUMN wallet_provider.instances.active IS 'Set false when the instance is revoked';
COMMENT ON COLUMN wallet_provider.instances.date_created IS 'Instance creation time';
COMMENT ON COLUMN wallet_provider.instances.date_modified IS 'Record last update time';
COMMENT ON COLUMN wallet_provider.instances.revoked_at IS 'Timestamp of instance revocation';

COMMENT ON COLUMN wallet_provider.revocation_info.id IS 'Auto-generated primary key';
COMMENT ON COLUMN wallet_provider.revocation_info.instance_id IS 'Reference to wallet instance record';
COMMENT ON COLUMN wallet_provider.revocation_info.status_list_uri IS 'Revocation index list URI';
COMMENT ON COLUMN wallet_provider.revocation_info.status_list_idx IS 'Index value in the revocation index list';
COMMENT ON COLUMN wallet_provider.revocation_info.wua_expires_at IS 'Expiration timestamp of respective WUA';
COMMENT ON COLUMN wallet_provider.revocation_info.active IS 'Should be set to false after wallet revocation or WUA expiration to to exclude from index';

COMMENT ON COLUMN wallet_provider.parameters.name IS 'Parameter name';
COMMENT ON COLUMN wallet_provider.parameters.value IS 'Parameter value';
COMMENT ON COLUMN wallet_provider.parameters.last_changed IS 'Timestamp of last modification';