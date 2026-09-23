-- SPDX-License-Identifier: EUPL-1.2

-- Get revoked instances for status list generation
-- Returns all instances that have been revoked (active=false) for building status list bit arrays

CREATE OR REPLACE PROCEDURE wallet_provider.get_active_revocation_indices(
  IN pi_params JSONB,
  OUT po_result JSONB)
  LANGUAGE plpgsql
AS
$$
BEGIN
  po_result := wallet_provider.get_active_revocation_indices_f(pi_params);
END;
$$;

CREATE OR REPLACE FUNCTION wallet_provider.get_active_revocation_indices_f(params JSONB)
RETURNS JSONB
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
DECLARE
    v_status_list_uri TEXT;
    v_result JSONB;
BEGIN
    -- Extract parameters
    v_status_list_uri := params->>'status_list_uri';

    -- Build result with all revoked instances (active=false means revoked)
    -- These are the indices that should be marked in the status list bit array
    SELECT jsonb_build_object(
        'success', true,
        'data', jsonb_agg(
            jsonb_build_object(
                'instance_id', ri.instance_id,
                'status_list_idx', ri.status_list_idx,
                'status_list_uri', ri.status_list_uri,
                'wua_expires_at', ri.wua_expires_at,
                'is_revoked', NOT ri.active
            )
        )
    ) INTO v_result
    FROM wallet_provider.revocation_info ri
    WHERE ri.active = false  -- active=false means revoked
    AND (v_status_list_uri IS NULL OR ri.status_list_uri = v_status_list_uri)
    AND ri.status_list_idx >= 0;  -- Only include properly allocated indices

    -- If no results, return empty array
    IF v_result IS NULL OR v_result->'data' IS NULL THEN
        RETURN jsonb_build_object(
            'success', true,
            'data', '[]'::jsonb
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

COMMENT ON PROCEDURE wallet_provider.get_active_revocation_indices IS
'Returns all revoked wallet instances (active=false) with their status list indices for status list generation. Used by status list service to build revocation bit arrays.';
