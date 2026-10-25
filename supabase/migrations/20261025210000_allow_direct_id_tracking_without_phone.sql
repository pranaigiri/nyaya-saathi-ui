-- 20261025210000_allow_direct_id_tracking_without_phone.sql
-- Allow direct tracking by Tracking ID alone without requiring phone number.
-- Masks applicant phone number when queried without verified phone number for privacy.

CREATE OR REPLACE FUNCTION public.track_application(
  p_tracking_number text,
  p_phone_number text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_clean_phone text;
  v_app record;
  v_timeline jsonb;
  v_is_owner boolean := false;
  v_advocate jsonb := NULL;
BEGIN
  v_clean_phone := RIGHT(REGEXP_REPLACE(COALESCE(p_phone_number, ''), '\D', '', 'g'), 10);

  SELECT
    a.*,
    c.category_name,
    ct.case_type_name,
    d.district_name,
    adv.id AS adv_id,
    adv.full_name AS adv_full_name,
    adv.enrollment_number AS adv_enrollment_number,
    adv.primary_phone_number AS adv_phone,
    adv.secondary_phone_number AS adv_sec_phone,
    adv.primary_email AS adv_email,
    adv.office_address AS adv_address,
    adv.experience_years AS adv_experience
  INTO v_app
  FROM public.legal_aid_application a
  LEFT JOIN public.legal_aid_category c ON c.id = a.category_id
  LEFT JOIN public.case_type_master ct ON ct.id = a.case_type_id
  LEFT JOIN public.district_master d ON d.id = a.current_district_id
  LEFT JOIN public.advocate_master adv ON adv.id = a.assigned_advocate_id
  WHERE a.tracking_number = TRIM(p_tracking_number)
    AND (
      v_clean_phone = ''
      OR RIGHT(REGEXP_REPLACE(a.applicant_phone_number, '\D', '', 'g'), 10) = v_clean_phone
    )
  LIMIT 1;

  IF v_app.id IS NULL THEN
    RETURN NULL;
  END IF;

  IF auth.uid() IS NOT NULL AND v_app.applicant_id IS NOT NULL AND auth.uid() = v_app.applicant_id THEN
    v_is_owner := true;
  END IF;

  SELECT COALESCE(
    jsonb_agg(
      jsonb_build_object(
        'id', h.id,
        'previous_status', h.previous_status,
        'new_status', h.new_status,
        'created_at', h.created_at
      ) ORDER BY h.created_at ASC
    ),
    '[]'::jsonb
  )
  INTO v_timeline
  FROM public.application_status_history h
  WHERE h.application_id = v_app.id;

  IF v_app.adv_id IS NOT NULL THEN
    v_advocate := jsonb_build_object(
      'id', v_app.adv_id,
      'full_name', v_app.adv_full_name,
      'enrollment_number', COALESCE(v_app.adv_enrollment_number, ''),
      'primary_phone_number', v_app.adv_phone,
      'secondary_phone_number', v_app.adv_sec_phone,
      'primary_email', v_app.adv_email,
      'office_address', v_app.adv_address,
      'experience_years', COALESCE(v_app.adv_experience, 0)
    );
  END IF;

  IF v_is_owner THEN
    RETURN jsonb_build_object(
      'id', v_app.id,
      'tracking_number', v_app.tracking_number,
      'application_mode', v_app.application_mode,
      'applicant_id', v_app.applicant_id,
      'category_id', v_app.category_id,
      'applicant_full_name', v_app.applicant_full_name,
      'applicant_phone_number', v_app.applicant_phone_number,
      'applicant_dob', v_app.applicant_dob,
      'applicant_gender', v_app.applicant_gender,
      'village_or_town', v_app.village_or_town,
      'applicant_district_id', v_app.applicant_district_id,
      'case_type_id', v_app.case_type_id,
      'current_district_id', v_app.current_district_id,
      'current_taluka_id', v_app.current_taluka_id,
      'case_details', COALESCE(v_app.case_details, ''),
      'preferred_advocate_id', v_app.preferred_advocate_id,
      'assigned_advocate_id', v_app.assigned_advocate_id,
      'assigned_advocate_name', v_app.adv_full_name,
      'advocate_master', v_advocate,
      'assigned_advocate', v_advocate,
      'advocate_acceptance_status', COALESCE(v_app.advocate_acceptance_status, 'NONE'),
      'assigned_at', v_app.assigned_at,
      'status', v_app.status,
      'callback_status', v_app.callback_status,
      'details_completed_at', v_app.details_completed_at,
      'is_withdrawn_by_citizen', v_app.is_withdrawn_by_citizen,
      'withdrawal_reason', v_app.withdrawal_reason,
      'withdrawn_at', v_app.withdrawn_at,
      'created_at', v_app.created_at,
      'updated_at', v_app.updated_at,
      'category_name', v_app.category_name,
      'case_type_name', v_app.case_type_name,
      'district_name', v_app.district_name,
      'status_timeline', v_timeline
    );
  ELSE
    RETURN jsonb_build_object(
      'id', v_app.id,
      'tracking_number', v_app.tracking_number,
      'application_mode', v_app.application_mode,
      'status', v_app.status,
      'callback_status', CASE v_app.callback_status
        WHEN 'PENDING_CALL' THEN 'CALLBACK_PENDING'
        WHEN 'CALL_ATTEMPTED' THEN 'CALLBACK_ATTEMPTED'
        WHEN 'UNREACHABLE' THEN 'CALLBACK_UNREACHABLE'
        WHEN 'DETAILS_COLLECTED' THEN 'CALLBACK_COMPLETED'
        ELSE 'NOT_REQUIRED'
      END,
      'category_id', v_app.category_id,
      'case_type_id', v_app.case_type_id,
      'current_district_id', v_app.current_district_id,
      'applicant_district_id', v_app.applicant_district_id,
      'category_name', v_app.category_name,
      'case_type_name', v_app.case_type_name,
      'district_name', v_app.district_name,
      'applicant_full_name', CASE
        WHEN v_app.applicant_full_name IS NULL OR TRIM(v_app.applicant_full_name) = '' THEN NULL
        WHEN LENGTH(TRIM(v_app.applicant_full_name)) = 1 THEN LEFT(TRIM(v_app.applicant_full_name), 1) || '***'
        ELSE LEFT(TRIM(v_app.applicant_full_name), 1) || REPEAT('*', GREATEST(LENGTH(TRIM(v_app.applicant_full_name)) - 1, 3))
      END,
      'applicant_phone_number', CASE
        WHEN v_clean_phone != '' THEN v_clean_phone
        WHEN v_app.applicant_phone_number IS NOT NULL AND LENGTH(REGEXP_REPLACE(v_app.applicant_phone_number, '\D', '', 'g')) >= 10 THEN
          LEFT(REGEXP_REPLACE(v_app.applicant_phone_number, '\D', '', 'g'), 2) || '******' || RIGHT(REGEXP_REPLACE(v_app.applicant_phone_number, '\D', '', 'g'), 2)
        ELSE NULL
      END,
      'applicant_dob', NULL,
      'applicant_gender', v_app.applicant_gender,
      'village_or_town', v_app.village_or_town,
      'case_details', COALESCE(v_app.case_details, ''),
      'details_completed_at', v_app.details_completed_at,
      'preferred_advocate_id', v_app.preferred_advocate_id,
      'assigned_advocate_id', v_app.assigned_advocate_id,
      'assigned_advocate_name', v_app.adv_full_name,
      'advocate_master', v_advocate,
      'assigned_advocate', v_advocate,
      'advocate_acceptance_status', COALESCE(v_app.advocate_acceptance_status, 'NONE'),
      'assigned_at', v_app.assigned_at,
      'is_withdrawn_by_citizen', v_app.is_withdrawn_by_citizen,
      'withdrawal_reason', NULL,
      'withdrawn_at', v_app.withdrawn_at,
      'created_at', v_app.created_at,
      'updated_at', v_app.updated_at,
      'status_timeline', v_timeline
    );
  END IF;
END;
$$;

GRANT EXECUTE ON FUNCTION public.track_application(text, text) TO anon, authenticated, service_role;
