-- SPDX-License-Identifier: EUPL-1.2
-- Assertion-based tests for session and wallet_provider revocation paths.
-- Runs inside a transaction that is rolled back at the end, so no fixture data persists.

BEGIN;

-- session.get_user_data() must reject use before session.create().
-- Note: on a connection where session_state was never created, this raises
-- a raw "relation does not exist" error instead of the intended
-- "Session not initialized" message - the temp table only exists after
-- session.create() has run at least once in that connection.
DO $$
BEGIN
  BEGIN
    PERFORM session.get_user_data();
    RAISE EXCEPTION 'FAIL: get_user_data() did not raise for an uninitialized session';
  EXCEPTION
    WHEN OTHERS THEN
      IF SQLERRM NOT LIKE 'Session not initialized%' AND SQLERRM NOT LIKE '%session_state%does not exist%' THEN
        RAISE;
      END IF;
  END;
END;
$$;

-- session.create() -> session.get_user_data() round trip
DO $$
DECLARE
  v_user record;
BEGIN
  CALL session."create"('01TESTSESSIONID0000000000', 'user-1', '123-45-6789', 'Jane', 'Doe', 'admin', '127.0.0.1');
  v_user := session.get_user_data();
  IF v_user.user_id IS DISTINCT FROM 'user-1' THEN
    RAISE EXCEPTION 'FAIL: session round trip returned user_id %, expected user-1', v_user.user_id;
  END IF;
  IF v_user.user_code IS DISTINCT FROM '123456789' THEN
    RAISE EXCEPTION 'FAIL: session did not strip hyphens from user_code, got %', v_user.user_code;
  END IF;
END;
$$;

-- wallet_provider.allocate_revocation_index: validation, allocation, idempotent re-allocation
DO $$
DECLARE
  v_account_id varchar(26);
  v_instance_id varchar(26);
  v_result jsonb;
BEGIN
  INSERT INTO wallet_provider.accounts DEFAULT VALUES RETURNING id INTO v_account_id;
  INSERT INTO wallet_provider.instances
    (account_id, hardware_key_tag, public_key, wscd_anchor_hash, wscd_type, device_label)
  VALUES
    (v_account_id, 'test-hw-tag-1', 'pubkey', repeat('a', 64), 'tee', 'test-device')
  RETURNING id INTO v_instance_id;

  CALL wallet_provider.allocate_revocation_index(
    jsonb_build_object('hardware_key_tag', 'unknown-tag', 'status_list_uri', 'https://sl/1', 'status_list_idx', 1, 'wua_expires_at', now() + interval '1 day'),
    v_result);
  IF v_result->>'error' IS DISTINCT FROM 'not_found' THEN
    RAISE EXCEPTION 'FAIL: allocate_revocation_index should return not_found for unknown instance, got %', v_result;
  END IF;

  CALL wallet_provider.allocate_revocation_index(
    jsonb_build_object('hardware_key_tag', 'test-hw-tag-1', 'status_list_uri', 'https://sl/1', 'status_list_idx', 42, 'wua_expires_at', now() + interval '1 day'),
    v_result);
  IF (v_result->>'success')::boolean IS NOT TRUE OR (v_result->'data'->>'status_list_idx')::int IS DISTINCT FROM 42 THEN
    RAISE EXCEPTION 'FAIL: allocate_revocation_index did not allocate expected index, got %', v_result;
  END IF;

  -- second call for the same instance must return the existing allocation, not a duplicate
  CALL wallet_provider.allocate_revocation_index(
    jsonb_build_object('hardware_key_tag', 'test-hw-tag-1', 'status_list_uri', 'https://sl/2', 'status_list_idx', 99, 'wua_expires_at', now() + interval '1 day'),
    v_result);
  IF (v_result->'data'->>'status_list_idx')::int IS DISTINCT FROM 42 THEN
    RAISE EXCEPTION 'FAIL: allocate_revocation_index re-allocated instead of returning existing entry, got %', v_result;
  END IF;
  IF (SELECT count(*) FROM wallet_provider.revocation_info WHERE instance_id = v_instance_id) <> 1 THEN
    RAISE EXCEPTION 'FAIL: allocate_revocation_index created a duplicate revocation_info row';
  END IF;
END;
$$;

-- wallet_provider.revoke_instance + get_revocation_status + get_active_revocation_indices
DO $$
DECLARE
  v_account_id varchar(26);
  v_instance_id varchar(26);
  v_result jsonb;
BEGIN
  INSERT INTO wallet_provider.accounts DEFAULT VALUES RETURNING id INTO v_account_id;
  INSERT INTO wallet_provider.instances
    (account_id, hardware_key_tag, public_key, wscd_anchor_hash, wscd_type, device_label)
  VALUES
    (v_account_id, 'test-hw-tag-2', 'pubkey', repeat('b', 64), 'tee', 'test-device-2')
  RETURNING id INTO v_instance_id;

  CALL wallet_provider.allocate_revocation_index(
    jsonb_build_object('hardware_key_tag', 'test-hw-tag-2', 'status_list_uri', 'https://sl/rev', 'status_list_idx', 7, 'wua_expires_at', now() + interval '1 day'),
    v_result);

  CALL wallet_provider.get_revocation_status(jsonb_build_object('hardware_key_tag', 'test-hw-tag-2'), v_result);
  IF (v_result->'data'->>'is_revoked')::boolean IS NOT FALSE THEN
    RAISE EXCEPTION 'FAIL: freshly allocated instance reported as revoked, got %', v_result;
  END IF;

  CALL wallet_provider.revoke_instance(jsonb_build_object('instance_id', 'nonexistent'), v_result);
  IF v_result->>'error' IS DISTINCT FROM 'not_found' THEN
    RAISE EXCEPTION 'FAIL: revoke_instance should return not_found for unknown instance, got %', v_result;
  END IF;

  CALL wallet_provider.revoke_instance(jsonb_build_object('instance_id', v_instance_id), v_result);
  IF (v_result->>'success')::boolean IS NOT TRUE THEN
    RAISE EXCEPTION 'FAIL: revoke_instance did not succeed, got %', v_result;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM wallet_provider.instances WHERE id = v_instance_id AND active = false AND revoked_at IS NOT NULL) THEN
    RAISE EXCEPTION 'FAIL: revoke_instance did not mark the instance inactive/revoked';
  END IF;

  CALL wallet_provider.get_revocation_status(jsonb_build_object('hardware_key_tag', 'test-hw-tag-2'), v_result);
  IF (v_result->'data'->>'is_revoked')::boolean IS NOT TRUE THEN
    RAISE EXCEPTION 'FAIL: get_revocation_status did not reflect revocation, got %', v_result;
  END IF;

  CALL wallet_provider.get_active_revocation_indices(jsonb_build_object('status_list_uri', 'https://sl/rev'), v_result);
  IF NOT (v_result->'data' @> jsonb_build_array(jsonb_build_object('instance_id', v_instance_id, 'status_list_idx', 7, 'status_list_uri', 'https://sl/rev', 'wua_expires_at', (SELECT wua_expires_at FROM wallet_provider.revocation_info WHERE instance_id = v_instance_id), 'is_revoked', true))) THEN
    RAISE EXCEPTION 'FAIL: get_active_revocation_indices did not list the revoked instance, got %', v_result;
  END IF;
END;
$$;

ROLLBACK;
