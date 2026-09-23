-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE wallet_provider.create_instance(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg      text;
    v_payload        jsonb;
    v_account        jsonb;
    v_account_code   varchar;
    v_instance       wallet_provider.instances%ROWTYPE;
    v_existing       wallet_provider.instances%ROWTYPE;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);
    v_account := coalesce(v_payload -> 'account', v_payload -> 'person');
    v_account_code := nullif(trim((v_account ->> 'code')), '');

    IF v_account is null or v_account_code is null then
        po_data := json_build_object('code', 'err:account:required', 'error', 'Account data is required');
        RETURN;
    END IF;

    IF lower(v_account_code) = 'anonymous' THEN
        v_instance.account_id := null;
    ELSE
        CALL wallet_provider.save_account(v_account, po_data);
        IF po_data is null or (po_data ->> 'success')::boolean is not true THEN
            RETURN;
        END IF;
        v_instance.account_id := ((po_data -> 'data') ->> 'id');
        po_data := null;
    END IF;

    -- NEW: check for existing instance with the same hardware_key_tag
    SELECT * INTO v_existing
    FROM wallet_provider.instances
    WHERE hardware_key_tag = nullif(trim((v_payload ->> 'hardwareKeyTag')), '')
      AND active
    LIMIT 1;

    IF v_existing.id IS NOT NULL THEN
        IF v_existing.public_key = nullif(trim((v_payload ->> 'publicKey')), '') THEN
            -- Same key — idempotent, return existing instance
            po_data := result_success(wallet_provider.get_instance_data(v_existing.hardware_key_tag)::json);
            RETURN;
        ELSE
            -- Different key — conflict
            po_data := json_build_object(
                'success', false,
                'code',    'err:instance:hardwareKeyTagConflict',
                'error',   'Hardware key tag already registered with a different public key'
            );
            RETURN;
        END IF;
    END IF;

    v_instance.hardware_key_tag := nullif(trim((v_payload ->> 'hardwareKeyTag')), '');
    v_instance.public_key := nullif(trim((v_payload ->> 'publicKey')), '');
    v_instance.fid := nullif(trim((v_payload ->> 'fid')), '');
    v_instance.wscd_anchor_hash := nullif(trim((v_payload ->> 'wscdAnchorHash')), '');
    v_instance.wscd_type := nullif(trim((v_payload ->> 'wscdType')), '');
    v_instance.device_label := nullif(trim((v_payload ->> 'deviceLabel')), '');
    v_instance.hardware_identifiers := v_payload -> 'deviceIdentifiers';

    -- Validate required fields
    IF v_instance.hardware_key_tag IS NULL THEN
        po_data := json_build_object('success', false, 'code', 'err:instance:hardwareKeyTagRequired', 'error', 'Hardware key tag is required');
        RETURN;
    END IF;

    IF v_instance.public_key IS NULL THEN
        po_data := json_build_object('success', false, 'code', 'err:instance:publicKeyRequired', 'error', 'Public key is required');
        RETURN;
    END IF;

    IF v_instance.wscd_anchor_hash IS NULL THEN
      v_instance.wscd_anchor_hash := 'test_data_'::varchar || gen_random_uuid()::text;
    END IF;

    IF v_instance.wscd_type IS NULL THEN
        po_data := json_build_object('success', false, 'code', 'err:instance:wscdTypeRequired', 'error', 'WSCD type is required');
        RETURN;
    END IF;

    IF v_instance.device_label IS NULL THEN
      v_instance.device_label := 'not_specified';
    END IF;

    INSERT INTO wallet_provider.instances(
        account_id,
        hardware_key_tag,
        public_key,
        fid,
        wscd_anchor_hash,
        wscd_type,
        device_label,
        hardware_identifiers)
    VALUES (
        v_instance.account_id,
        v_instance.hardware_key_tag,
        v_instance.public_key,
        v_instance.fid,
        v_instance.wscd_anchor_hash,
        v_instance.wscd_type,
        v_instance.device_label,
        v_instance.hardware_identifiers);

    po_data := result_success(wallet_provider.get_instance_data(v_instance.hardware_key_tag)::json);
exception
    WHEN others THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := result_error('err:internal:db', v_error_msg);
        RETURN;
END;
$$;

GRANT EXECUTE ON PROCEDURE wallet_provider.create_instance(jsonb, jsonb) TO digimaks;
REVOKE ALL ON PROCEDURE wallet_provider.create_instance(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE wallet_provider.create_instance(jsonb, jsonb)
    IS 'Creates a new wallet provider instance and returns its metadata.';