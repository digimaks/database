-- SPDX-License-Identifier: EUPL-1.2

-- Revoke a wallet instance
-- Marks the instance as revoked and deactivates its revocation info

CREATE OR REPLACE PROCEDURE wallet_provider.revoke_instance(
  IN pi_params JSONB,
  OUT po_result JSONB)
  LANGUAGE plpgsql
AS
$$
BEGIN
  po_result := wallet_provider.revoke_instance_f(pi_params);
END;
$$;

CREATE OR REPLACE FUNCTION wallet_provider.revoke_instance_f(params JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_instance_id TEXT;
    v_rows_updated INTEGER;
BEGIN
    -- Extract parameters
    v_instance_id := params->>'instance_id';

    -- Validate required parameters
    IF v_instance_id IS NULL OR v_instance_id = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'validation_error',
            'message', 'instance_id is required'
        );
    END IF;

    -- Check if instance exists
    IF NOT EXISTS (
        SELECT 1 FROM wallet_provider.instances
        WHERE id = v_instance_id
    ) THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'not_found',
            'message', 'wallet instance not found'
        );
    END IF;

    -- Update instance to mark as revoked
    UPDATE wallet_provider.instances
    SET 
        revoked_at = NOW(),
        active = false,
        date_modified = NOW()
    WHERE id = v_instance_id
    AND active = true;

    GET DIAGNOSTICS v_rows_updated = ROW_COUNT;

    -- Update revocation_info to deactivate (marks as revoked in status list)
    UPDATE wallet_provider.revocation_info
    SET active = false
    WHERE instance_id = v_instance_id
    AND active = true;

    -- Return success
    RETURN jsonb_build_object(
        'success', true,
        'data', jsonb_build_object(
            'instance_id', v_instance_id,
            'is_revoked', true,
            'revoked_at', NOW(),
            'rows_updated', v_rows_updated
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

COMMENT ON PROCEDURE wallet_provider.revoke_instance IS
'Revokes a wallet instance by setting active=false and revoked_at timestamp. Deactivates revocation_info entries to mark them as revoked in status lists.';
