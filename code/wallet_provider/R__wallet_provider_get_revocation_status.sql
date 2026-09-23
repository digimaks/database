-- SPDX-License-Identifier: EUPL-1.2

-- Get revocation status for a wallet instance
-- Returns the revocation information including status list details

CREATE OR REPLACE PROCEDURE wallet_provider.get_revocation_status(
  IN pi_params JSONB,
  OUT po_result JSONB)
  LANGUAGE plpgsql
AS
$$
BEGIN
  po_result := wallet_provider.get_revocation_status_f(pi_params);
END;
$$;

CREATE OR REPLACE FUNCTION wallet_provider.get_revocation_status_f(params JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_hardware_key_tag TEXT;
    v_result JSONB;
    v_instance_row wallet_provider.instances%ROWTYPE;
BEGIN
    -- Extract parameters
    v_hardware_key_tag := params->>'hardware_key_tag';

    -- Validate required parameters
    IF v_hardware_key_tag IS NULL OR v_hardware_key_tag = '' THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'validation_error',
            'message', 'instance_id is required'
        );
    END IF;

    select *
    into v_instance_row
    FROM wallet_provider.instances
    WHERE hardware_key_tag = v_hardware_key_tag;

    IF v_instance_row.id IS NULL THEN
      RETURN jsonb_build_object(
          'code', 'not_found',
          'success', false,
          'error', 'not_found',
          'message', 'wallet instance not found'
      );
    END IF;

    -- Get revocation info
    SELECT jsonb_build_object(
        'success', true,
        'data', jsonb_build_object(
            'instance_id', ri.instance_id,
            'status_list_idx', ri.status_list_idx,
            'status_list_uri', ri.status_list_uri,
            'wua_expires_at', ri.wua_expires_at,
            'active', ri.active,
            'is_revoked', NOT ri.active
        )
    ) INTO v_result
    FROM wallet_provider.revocation_info ri
    WHERE ri.instance_id = v_instance_row.id
    ORDER BY ri.id DESC
    LIMIT 1;

    -- If not found, return not found
    IF v_result IS NULL THEN
        RETURN jsonb_build_object(
            'code', 'not_found',
            'success', false,
            'error', 'not_found',
            'message', 'revocation info not found for instance'
        );
    END IF;

    RETURN v_result;

EXCEPTION
    WHEN OTHERS THEN
        RETURN jsonb_build_object(
            'success', false,
            'error', 'internal_error',
            'message', SQLERRM
        );
END;
$$;

COMMENT ON PROCEDURE wallet_provider.get_revocation_status IS
'Retrieves revocation status and status list information for a wallet instance.';
