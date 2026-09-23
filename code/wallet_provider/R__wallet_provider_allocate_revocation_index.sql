-- SPDX-License-Identifier: EUPL-1.2

CREATE OR REPLACE PROCEDURE wallet_provider.allocate_revocation_index(
  IN pi_params JSONB,
  OUT po_result JSONB)
  LANGUAGE plpgsql
AS
$$
BEGIN
  po_result := wallet_provider.allocate_revocation_index_f(pi_params);
END;
$$;

CREATE OR REPLACE FUNCTION wallet_provider.allocate_revocation_index_f(params JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_hardware_key_tag TEXT;
    v_status_list_uri TEXT;
    v_status_list_idx INTEGER;
    v_wua_expires_at TIMESTAMPTZ;
    v_result JSONB;
    v_instance_row wallet_provider.instances%ROWTYPE;
BEGIN
    -- Extract parameters
    v_hardware_key_tag := params->>'hardware_key_tag';
    v_status_list_uri := params->>'status_list_uri';
    v_status_list_idx := (params->>'status_list_idx')::INTEGER;
    v_wua_expires_at := (params->>'wua_expires_at')::TIMESTAMPTZ;

    -- Validate required parameters
    IF v_hardware_key_tag IS NULL OR v_hardware_key_tag = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'validation_error',
            'message', 'instance_id is required'
        );
    END IF;

    IF v_status_list_uri IS NULL OR v_status_list_uri = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'validation_error',
            'message', 'status_list_uri is required'
        );
    END IF;

    IF v_status_list_idx IS NULL OR v_status_list_idx < 0 THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'validation_error',
            'message', 'status_list_idx must be a non-negative integer'
        );
    END IF;

    IF v_wua_expires_at IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'validation_error',
            'message', 'wua_expires_at is required'
        );
    END IF;

    select *
    into v_instance_row
    FROM wallet_provider.instances
    WHERE hardware_key_tag = v_hardware_key_tag;

    -- Check if instance exists
    IF v_instance_row.id IS NULL THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'not_found',
            'message', 'wallet instance not found'
        );
    END IF;

    -- Check if revocation info already exists for this instance (active)
    IF EXISTS (
        SELECT 1 FROM wallet_provider.revocation_info
        WHERE instance_id = v_instance_row.id
        AND active = true
    ) THEN
        -- Return existing revocation info
        SELECT jsonb_build_object(
            'success', true,
            'data', jsonb_build_object(
                'instance_id', instance_id,
                'status_list_idx', status_list_idx,
                'status_list_uri', status_list_uri,
                'wua_expires_at', wua_expires_at,
                'active', active,
                'is_revoked', NOT active
            )
        ) INTO v_result
        FROM wallet_provider.revocation_info
        WHERE instance_id = v_instance_row.id
        AND active = true
        LIMIT 1;

        RETURN v_result;
    END IF;

    -- Insert new revocation info
    INSERT INTO wallet_provider.revocation_info (
        instance_id,
        status_list_uri,
        status_list_idx,
        wua_expires_at,
        active
    ) VALUES (
        v_instance_row.id,
        v_status_list_uri,
        v_status_list_idx,
        v_wua_expires_at,
        true
    );

    -- Return success with allocated info
    RETURN jsonb_build_object(
        'success', true,
        'data', jsonb_build_object(
            'instance_id', v_instance_row.id,
            'status_list_idx', v_status_list_idx,
            'status_list_uri', v_status_list_uri,
            'wua_expires_at', v_wua_expires_at,
            'active', true,
            'is_revoked', false
        )
    );

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'internal_error',
            'message', SQLERRM
        );
END;
$$;

COMMENT ON PROCEDURE wallet_provider.allocate_revocation_index IS
'Allocates and stores revocation index for WUA (Wallet Unit Attestation). Returns existing allocation if already present.';
