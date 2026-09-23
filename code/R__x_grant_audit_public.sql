-- SPDX-License-Identifier: EUPL-1.2

-- audit
GRANT USAGE ON SCHEMA audit TO audit_public;

GRANT EXECUTE ON PROCEDURE audit.create_audit_partition(date) TO audit_public;
GRANT EXECUTE ON PROCEDURE audit.audit_person_data(text, text) TO audit_public;
GRANT INSERT ON TABLE audit.person_data_requests TO audit_public;

-- audit.failure_events — written by each service's own OnFailure hook
-- (go-platform-kit/errors.FailureHook), one insert per originated failure.
GRANT USAGE ON SCHEMA audit TO wallet_public, issuer_public, idauth_public;
GRANT EXECUTE ON PROCEDURE audit.insert_failure_event(jsonb, jsonb) TO wallet_public, issuer_public, idauth_public;

-- session
GRANT USAGE ON SCHEMA session TO audit_public;

GRANT EXECUTE ON PROCEDURE session."create"(varchar, varchar, varchar, varchar, varchar, varchar, inet) TO audit_public;
