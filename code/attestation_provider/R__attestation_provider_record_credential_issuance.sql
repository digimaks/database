-- SPDX-License-Identifier: EUPL-1.2

-- TODO: Jāpārbauda process iekš API, vai revocation info ir pieejams jau šajā brīdī.

CREATE OR REPLACE PROCEDURE attestation_provider.record_credential_issuance(
    pi_data jsonb,
    INOUT po_data jsonb)
    LANGUAGE plpgsql
    SECURITY DEFINER
AS
$$
DECLARE
    v_error_msg        text;
    v_payload          jsonb;
    v_issuance         attestation_provider.credential_issuances%ROWTYPE;
    v_hardware_key_tag text;
BEGIN
    v_payload := coalesce(pi_data, '{}'::jsonb);

    -- Extract credential issuance data
    v_issuance.credential_identifier := nullif(trim((v_payload ->> 'credential_identifier')), '');
    v_issuance.format := nullif(trim((v_payload ->> 'format')), '');
    v_issuance.doctype_vct := nullif(trim((v_payload ->> 'doctype_vct')), '');
    v_issuance.issued_at := coalesce((v_payload ->> 'issued_at')::timestamptz, CURRENT_TIMESTAMP);
    v_issuance.expires_at := (v_payload ->> 'expires_at')::timestamptz;
    v_issuance.holder_identifier_type := nullif(trim((v_payload ->> 'holder_identifier_type')), '');
    v_issuance.holder_identifier_value := nullif(trim((v_payload ->> 'holder_identifier_value')), '');
    v_issuance.holder_given_name := nullif(trim((v_payload ->> 'holder_given_name')), '');
    v_issuance.holder_family_name := nullif(trim((v_payload ->> 'holder_family_name')), '');
    v_issuance.wallet_provider := nullif(trim((v_payload ->> 'wallet_provider')), '');
    v_issuance.install_status := coalesce(nullif(trim((v_payload ->> 'install_status')), ''), 'pending');

    v_hardware_key_tag := nullif(trim((v_payload ->> 'hardware_key_tag')), '');

    IF v_hardware_key_tag IS NOT NULL THEN
        SELECT id INTO v_issuance.instance_id
        FROM wallet_provider.instances
        WHERE hardware_key_tag = v_hardware_key_tag;
    END IF;

    -- Validate required fields
    IF v_issuance.format IS NULL THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:formatRequired', 'error', 'Credential format is required');
        RETURN;
    END IF;

    IF v_issuance.format NOT IN ('mso_mdoc', 'dc+sd-jwt') THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:invalidFormat', 'error', 'Invalid credential format. Must be mso_mdoc or dc+sd-jwt');
        RETURN;
    END IF;

    IF v_issuance.doctype_vct IS NULL THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:doctypeVctRequired', 'error', 'Doctype or VCT is required');
        RETURN;
    END IF;

    IF v_issuance.expires_at IS NULL THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:expiresAtRequired', 'error', 'Expiration date is required');
        RETURN;
    END IF;

    IF v_issuance.install_status NOT IN ('pending', 'installed', 'failed') THEN
        po_data := jsonb_build_object('success', false, 'code', 'err:credential:invalidInstallStatus', 'error', 'Invalid install status. Must be pending, installed, or failed');
        RETURN;
    END IF;

    -- Insert credential issuance record
    INSERT INTO attestation_provider.credential_issuances(
        credential_identifier, format, doctype_vct, issued_at, expires_at,
        holder_identifier_type, holder_identifier_value,
        holder_given_name, holder_family_name,
        wallet_provider, install_status, instance_id)
    VALUES (
        v_issuance.credential_identifier, v_issuance.format, v_issuance.doctype_vct,
        v_issuance.issued_at, v_issuance.expires_at,
        v_issuance.holder_identifier_type, v_issuance.holder_identifier_value,
        v_issuance.holder_given_name, v_issuance.holder_family_name,
        v_issuance.wallet_provider, v_issuance.install_status, v_issuance.instance_id)
    RETURNING id INTO v_issuance.id;

    -- One revocation_info row per allocated slot. Batch credential issuance
    -- (a single /credential call minting N physical copies) allocates N
    -- distinct revocation slots — status_list_slots carries all of them.
    -- Falls back to the legacy singular status_list_uri/idx fields when
    -- status_list_slots is absent, so callers on either side of a staged
    -- deploy keep working.
    IF jsonb_typeof(v_payload -> 'status_list_slots') = 'array'
        AND jsonb_array_length(v_payload -> 'status_list_slots') > 0 THEN
        INSERT INTO attestation_provider.revocation_info(
            credential_issuance_id, status_list_uri, status_list_idx)
        SELECT
            v_issuance.id,
            nullif(trim(slot ->> 'uri'), ''),
            (slot ->> 'idx')::integer
        FROM jsonb_array_elements(v_payload -> 'status_list_slots') AS slot
        WHERE nullif(trim(slot ->> 'uri'), '') IS NOT NULL
            AND slot ->> 'idx' IS NOT NULL;
    ELSIF v_payload ->> 'status_list_uri' IS NOT NULL AND v_payload ->> 'status_list_idx' IS NOT NULL THEN
        INSERT INTO attestation_provider.revocation_info(
            credential_issuance_id, status_list_uri, status_list_idx)
        VALUES (
            v_issuance.id,
            nullif(trim((v_payload ->> 'status_list_uri')), ''),
            (v_payload ->> 'status_list_idx')::integer);
    END IF;

    po_data := jsonb_build_object(
        'success', true,
        'data', jsonb_build_object(
            'id', v_issuance.id,
            'credential_identifier', v_issuance.credential_identifier,
            'format', v_issuance.format,
            'doctype_vct', v_issuance.doctype_vct,
            'issued_at', v_issuance.issued_at,
            'expires_at', v_issuance.expires_at,
            'install_status', v_issuance.install_status
        )
    );

EXCEPTION
    WHEN others THEN
        GET STACKED DIAGNOSTICS v_error_msg = message_text;
        po_data := jsonb_build_object('success', false, 'code', 'err:internal:db', 'error', v_error_msg);
        RETURN;
END;
$$;

ALTER PROCEDURE attestation_provider.record_credential_issuance(jsonb, jsonb) OWNER TO digimaks;
REVOKE ALL ON PROCEDURE attestation_provider.record_credential_issuance(jsonb, jsonb) FROM PUBLIC;

COMMENT ON PROCEDURE attestation_provider.record_credential_issuance(jsonb, jsonb)
    IS 'Records a new credential issuance with optional revocation tracking.';
