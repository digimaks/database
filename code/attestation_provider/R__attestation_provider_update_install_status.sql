-- SPDX-License-Identifier: EUPL-1.2

-- TODO: Jāpārrunā, vai šo info mums padod atpakaļ, un vai tam vispār ir endpoint šobrīd.

CREATE OR REPLACE PROCEDURE attestation_provider.update_install_status(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg      text;
    v_payload        jsonb;
    v_credential_id  varchar;
    v_install_status varchar;
    v_install_message varchar;
    v_updated_count  integer;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);
    v_credential_id := nullif(trim((v_payload ->> 'credential_id')), '');
    v_install_status := nullif(trim((v_payload ->> 'install_status')), '');
    v_install_message := nullif(trim((v_payload ->> 'install_message')), '');

    IF v_credential_id IS NULL THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:idRequired', 'error', 'Credential ID is required');
        RETURN;
    END IF;

    IF v_install_status IS NULL THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:statusRequired', 'error', 'Install status is required');
        RETURN;
    END IF;

    IF v_install_status NOT IN ('pending', 'installed', 'failed') THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:invalidStatus', 'error', 'Invalid install status. Must be pending, installed, or failed');
        RETURN;
    END IF;

    -- Check if credential exists
    IF NOT EXISTS (SELECT 1 FROM attestation_provider.credential_issuances WHERE id = v_credential_id) THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:not_found', 'error', 'Credential not found');
        RETURN;
    END IF;

    -- Update install status
    UPDATE attestation_provider.credential_issuances
    SET install_status = v_install_status,
        install_message = v_install_message,
        date_modified = CURRENT_TIMESTAMP
    WHERE id = v_credential_id;

    GET DIAGNOSTICS v_updated_count = ROW_COUNT;

    IF v_updated_count = 0 THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:updateFailed', 'error', 'Failed to update credential status');
        RETURN;
    END IF;

    po_data := jsonb_build_object(
        'success', true,
        'data', jsonb_build_object(
            'credential_id', v_credential_id,
            'install_status', v_install_status,
            'install_message', v_install_message
        )
    );

EXCEPTION
    WHEN others THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := jsonb_build_object('success', false, 'code', 'err:internal:db', 'error', v_error_msg);
        RETURN;
END;
$$;

ALTER PROCEDURE attestation_provider.update_install_status(jsonb, jsonb) OWNER TO digimaks;
REVOKE ALL ON PROCEDURE attestation_provider.update_install_status(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE attestation_provider.update_install_status(jsonb, jsonb)
    IS 'Updates the installation status and message for a credential (acknowledgment from wallet).';
