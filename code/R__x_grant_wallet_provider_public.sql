-- SPDX-License-Identifier: EUPL-1.2

GRANT USAGE ON SCHEMA wallet_provider TO wallet_public;

GRANT EXECUTE ON PROCEDURE wallet_provider.create_instance(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.get_public_key(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.delete_inactive_instances(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.get_instance_by_tag(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.get_instance_list(jsonb, jsonb) TO wallet_public;

-- Grant execute permissions on wallet_provider revocation functions to wallet_public role

GRANT EXECUTE ON PROCEDURE wallet_provider.allocate_revocation_index(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.get_revocation_status(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.revoke_instance(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.get_active_revocation_indices(jsonb, jsonb) TO wallet_public;
GRANT EXECUTE ON PROCEDURE wallet_provider.relink_instance_account(jsonb, jsonb) TO wallet_public;