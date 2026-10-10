-- Migration: 20261010163000_quick_callback_mode.sql
-- Description: Adds Quick Apply (Request a Call) mode, callback log, submission attempt telemetry,
-- and server-side RPCs with backward compatibility for Flutter and Angular CMS.

-- ============================================================================
-- 1. ALTER legal_aid_application
-- ============================================================================

-- Add new columns if not existing
ALTER TABLE public.legal_aid_application
  ADD COLUMN IF NOT EXISTS application_mode text NOT NULL DEFAULT 'FULL',
  ADD COLUMN IF NOT EXISTS callback_status text NOT NULL DEFAULT 'NOT_REQUIRED',
  ADD COLUMN IF NOT EXISTS callback_attempts int NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS last_callback_at timestamptz NULL,
  ADD COLUMN IF NOT EXISTS details_completed_at timestamptz NULL,
  ADD COLUMN IF NOT EXISTS details_completed_by uuid NULL REFERENCES public.profiles(id) ON DELETE SET NULL;

-- Backfill existing rows
UPDATE public.legal_aid_application
SET application_mode = 'FULL'
WHERE application_mode IS NULL OR application_mode = '';

UPDATE public.legal_aid_application
SET callback_status = 'NOT_REQUIRED'
WHERE callback_status IS NULL OR callback_status = '';

-- Add CHECK constraints
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'legal_aid_application_application_mode_check'
  ) THEN
    ALTER TABLE public.legal_aid_application
      ADD CONSTRAINT legal_aid_application_application_mode_check
      CHECK (application_mode IN ('FULL', 'QUICK_CALLBACK'));
  END IF;

  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'legal_aid_application_callback_status_check'
  ) THEN
    ALTER TABLE public.legal_aid_application
      ADD CONSTRAINT legal_aid_application_callback_status_check
      CHECK (callback_status IN ('NOT_REQUIRED', 'PENDING_CALL', 'CALL_ATTEMPTED', 'UNREACHABLE', 'DETAILS_COLLECTED'));
  END IF;
END $$;

-- Drop NOT NULL constraints to accommodate QUICK_CALLBACK
ALTER TABLE public.legal_aid_application
  ALTER COLUMN category_id DROP NOT NULL,
  ALTER COLUMN applicant_full_name DROP NOT NULL,
  ALTER COLUMN applicant_dob DROP NOT NULL,
  ALTER COLUMN applicant_gender DROP NOT NULL,
  ALTER COLUMN applicant_district_id DROP NOT NULL,
  ALTER COLUMN case_type_id DROP NOT NULL,
  ALTER COLUMN current_district_id DROP NOT NULL,
  ALTER COLUMN case_details DROP NOT NULL;

-- Integrity check: FULL mode must have all required columns non-null
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM pg_constraint WHERE conname = 'chk_application_mode_completeness'
  ) THEN
    ALTER TABLE public.legal_aid_application
      ADD CONSTRAINT chk_application_mode_completeness
      CHECK (
        application_mode = 'QUICK_CALLBACK' OR (
          category_id IS NOT NULL AND
          applicant_full_name IS NOT NULL AND
          applicant_dob IS NOT NULL AND
          applicant_gender IS NOT NULL AND
          applicant_district_id IS NOT NULL AND
          case_type_id IS NOT NULL AND
          current_district_id IS NOT NULL AND
          case_details IS NOT NULL
        )
      );
  END IF;
END $$;

-- ============================================================================
-- 2. CREATE TABLE application_callback_log
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.application_callback_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  application_id uuid NOT NULL REFERENCES public.legal_aid_application(id) ON DELETE CASCADE,
  called_by_id uuid REFERENCES public.profiles(id) ON DELETE SET NULL,
  outcome text NOT NULL CHECK (outcome IN ('NO_ANSWER', 'SWITCHED_OFF', 'WRONG_NUMBER', 'CALL_BACK_LATER', 'DETAILS_COLLECTED', 'REFUSED')),
  notes text NULL,
  called_at timestamptz NOT NULL DEFAULT now()
);

ALTER TABLE public.application_callback_log ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "admin_select_callback_log" ON public.application_callback_log;
CREATE POLICY "admin_select_callback_log" ON public.application_callback_log
  FOR SELECT
  USING (
    public.is_admin() OR (
      public.is_geo_admin() AND EXISTS (
        SELECT 1 FROM public.legal_aid_application a
        WHERE a.id = application_callback_log.application_id
      )
    )
  );

DROP POLICY IF EXISTS "admin_insert_callback_log" ON public.application_callback_log;
CREATE POLICY "admin_insert_callback_log" ON public.application_callback_log
  FOR INSERT
  WITH CHECK (
    public.is_admin() OR (
      public.is_geo_admin() AND EXISTS (
        SELECT 1 FROM public.legal_aid_application a
        WHERE a.id = application_callback_log.application_id
      )
    )
  );

-- No UPDATE or DELETE policies created: Table is append-only.

-- ============================================================================
-- 3. CREATE TABLE submission_attempt_log
-- ============================================================================

CREATE TABLE IF NOT EXISTS public.submission_attempt_log (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  created_at timestamptz NOT NULL DEFAULT now(),
  action text NOT NULL,
  phone_hash text NOT NULL,
  device_hash text NOT NULL,
  ip_hash text NOT NULL,
  outcome text NOT NULL,
  reason text NULL
);

ALTER TABLE public.submission_attempt_log ENABLE ROW LEVEL SECURITY;
-- No RLS policies => restricted to service_role only.

CREATE INDEX IF NOT EXISTS idx_sub_attempt_phone_time
  ON public.submission_attempt_log (phone_hash, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sub_attempt_device_time
  ON public.submission_attempt_log (device_hash, created_at DESC);

CREATE INDEX IF NOT EXISTS idx_sub_attempt_ip_time
  ON public.submission_attempt_log (ip_hash, created_at DESC);

-- RETENTION POLICY NOTE:
-- submission_attempt_log records represent rate-limit and abuse telemetry.
-- A scheduled maintenance purge is recommended every 30 days:
--   DELETE FROM public.submission_attempt_log WHERE created_at < now() - INTERVAL '30 days';

-- ============================================================================
-- 4. UPDATE generate_tracking_number (Immutable, fallback GEN token)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.generate_tracking_number()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
    dist_code text;
    year_str text;
    seq_val int;
    target_district uuid;
BEGIN
    -- If tracking number is already populated and non-empty, keep it
    IF NEW.tracking_number IS NOT NULL AND NEW.tracking_number <> '' THEN
        RETURN NEW;
    END IF;

    target_district := COALESCE(NEW.current_district_id, NEW.applicant_district_id);

    IF target_district IS NOT NULL THEN
        SELECT district_code
        INTO dist_code
        FROM public.district_master
        WHERE id = target_district;
    END IF;

    IF dist_code IS NULL OR dist_code = '' THEN
        dist_code := 'GEN';
    END IF;

    year_str := TO_CHAR(NOW(), 'YY');
    seq_val := NEXTVAL('public.application_tracking_seq');

    NEW.tracking_number :=
        'SK-' || dist_code || '-' || year_str || '-' || LPAD(seq_val::TEXT, 5, '0');

    RETURN NEW;
END;
$$;

-- ============================================================================
-- 5. UPDATE fn_handle_application_status_change & INSERT Trigger
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_handle_application_status_change()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_title text;
  v_body text;
  v_tracking text;
  v_applicant_id uuid;
  v_status_normalized text;
BEGIN
  v_tracking := COALESCE(NEW.tracking_number, 'SK-APPLICATION');
  v_status_normalized := UPPER(COALESCE(NEW.status, ''));
  v_applicant_id := NEW.applicant_id;

  -- 1. Always record transition in application_status_history (even for guests where applicant_id IS NULL)
  BEGIN
    INSERT INTO public.application_status_history (
      application_id,
      previous_status,
      new_status,
      changed_by_id,
      created_at
    ) VALUES (
      NEW.id,
      CASE WHEN TG_OP = 'UPDATE' THEN OLD.status ELSE NULL END,
      NEW.status,
      COALESCE(auth.uid(), v_applicant_id),
      now()
    );
  EXCEPTION WHEN OTHERS THEN
    NULL;
  END;

  -- 2. Exit notification pipeline if no registered citizen account exists
  IF v_applicant_id IS NULL THEN
    RETURN NEW;
  END IF;

  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = v_applicant_id) THEN
    RETURN NEW;
  END IF;

  CASE v_status_normalized
    WHEN 'SUBMITTED' THEN
      v_title := 'Application Submitted';
      v_body := 'Your application ' || v_tracking || ' has been submitted successfully.';
    WHEN 'UNDER_REVIEW' THEN
      v_title := 'Application Under Review';
      v_body := 'Your application ' || v_tracking || ' is now under review.';
    WHEN 'ADVOCATE_ASSIGNED' THEN
      v_title := 'Advocate Assigned';
      v_body := 'An advocate has been assigned to your application ' || v_tracking || '.';
    WHEN 'RESOLVED' THEN
      v_title := 'Application Resolved';
      v_body := 'Your application ' || v_tracking || ' has been resolved.';
    WHEN 'REJECTED' THEN
      v_title := 'Application Rejected';
      v_body := 'Your application ' || v_tracking || ' has been rejected.';
    WHEN 'WITHDRAWN' THEN
      v_title := 'Application Withdrawn';
      v_body := 'Your application ' || v_tracking || ' has been withdrawn.';
    ELSE
      v_title := 'Application Status Updated';
      v_body := 'Your application ' || v_tracking || ' status is now ' || REPLACE(v_status_normalized, '_', ' ') || '.';
  END CASE;

  INSERT INTO public.notifications (
    user_id,
    application_id,
    title,
    body,
    is_read,
    created_at
  ) VALUES (
    v_applicant_id,
    NEW.id,
    v_title,
    v_body,
    false,
    now()
  );

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS "trg_application_status_notification_insert" ON public.legal_aid_application;
CREATE TRIGGER "trg_application_status_notification_insert"
  AFTER INSERT ON public.legal_aid_application
  FOR EACH ROW
  WHEN (NEW.status IS NOT NULL)
  EXECUTE FUNCTION public.fn_handle_application_status_change();

-- ============================================================================
-- 6. BEFORE UPDATE Trigger: Block ADVOCATE_ASSIGNED until details complete & enforce tracking immutability
-- ============================================================================

CREATE OR REPLACE FUNCTION public.fn_enforce_application_update_invariants()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
BEGIN
  -- 1. Tracking number is immutable once set
  IF OLD.tracking_number IS NOT NULL AND OLD.tracking_number <> '' THEN
    NEW.tracking_number := OLD.tracking_number;
  END IF;

  -- 2. Block transition to ADVOCATE_ASSIGNED or advocate assignment if details are incomplete
  IF (NEW.status = 'ADVOCATE_ASSIGNED' OR (NEW.assigned_advocate_id IS NOT NULL AND OLD.assigned_advocate_id IS NULL)) THEN
    IF NEW.category_id IS NULL OR
       NEW.case_type_id IS NULL OR
       NEW.applicant_full_name IS NULL OR TRIM(NEW.applicant_full_name) = '' OR
       NEW.applicant_district_id IS NULL OR
       NEW.current_district_id IS NULL THEN
      RAISE EXCEPTION 'Cannot assign advocate until applicant details (full name, category, case type, and district) are completed.'
        USING ERRCODE = 'check_violation';
    END IF;
  END IF;

  RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS trg_enforce_application_update_invariants ON public.legal_aid_application;
CREATE TRIGGER trg_enforce_application_update_invariants
  BEFORE UPDATE ON public.legal_aid_application
  FOR EACH ROW
  EXECUTE FUNCTION public.fn_enforce_application_update_invariants();

-- ============================================================================
-- 7. Tighten anyone_submit_applications INSERT policy
-- ============================================================================

DROP POLICY IF EXISTS "anyone_submit_applications" ON public.legal_aid_application;
CREATE POLICY "anyone_submit_applications" ON public.legal_aid_application
  FOR INSERT TO authenticated
  WITH CHECK (
    applicant_id IS NULL OR
    applicant_id = auth.uid() OR
    public.is_admin()
  );

-- ============================================================================
-- 8. SECURITY DEFINER RPC: create_quick_application
-- ============================================================================

CREATE OR REPLACE FUNCTION public.create_quick_application(
  p_phone text,
  p_name text,
  p_district_id uuid,
  p_note text,
  p_applicant_id uuid
)
RETURNS TABLE(tracking_number text, application_id uuid)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_clean_phone text;
  v_app_id uuid;
  v_tracking text;
BEGIN
  v_clean_phone := RIGHT(REGEXP_REPLACE(COALESCE(p_phone, ''), '\D', '', 'g'), 10);
  IF LENGTH(v_clean_phone) <> 10 THEN
    RAISE EXCEPTION 'Invalid phone number: exactly 10 digits required'
      USING ERRCODE = 'invalid_parameter_value';
  END IF;

  INSERT INTO public.legal_aid_application (
    application_mode,
    status,
    callback_status,
    callback_attempts,
    applicant_phone_number,
    applicant_full_name,
    applicant_district_id,
    current_district_id,
    case_details,
    applicant_id
  ) VALUES (
    'QUICK_CALLBACK',
    'SUBMITTED',
    'PENDING_CALL',
    0,
    v_clean_phone,
    NULLIF(TRIM(p_name), ''),
    p_district_id,
    p_district_id,
    COALESCE(NULLIF(TRIM(p_note), ''), 'Quick callback request'),
    p_applicant_id
  )
  RETURNING id, legal_aid_application.tracking_number INTO v_app_id, v_tracking;

  RETURN QUERY SELECT v_tracking, v_app_id;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.create_quick_application(text, text, uuid, text, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_quick_application(text, text, uuid, text, uuid) TO service_role;

-- ============================================================================
-- 9. SECURITY DEFINER RPC: track_applications_by_phone
-- ============================================================================

CREATE OR REPLACE FUNCTION public.track_applications_by_phone(
  p_phone text
)
RETURNS TABLE(
  tracking_number text,
  application_mode text,
  status text,
  callback_status text,
  category_name text,
  case_type_name text,
  created_at timestamptz,
  updated_at timestamptz,
  masked_name text
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_clean_phone text;
BEGIN
  v_clean_phone := RIGHT(REGEXP_REPLACE(COALESCE(p_phone, ''), '\D', '', 'g'), 10);
  IF LENGTH(v_clean_phone) <> 10 THEN
    RETURN;
  END IF;

  RETURN QUERY
  SELECT
    a.tracking_number,
    a.application_mode,
    a.status,
    CASE a.callback_status
      WHEN 'PENDING_CALL' THEN 'CALLBACK_PENDING'
      WHEN 'CALL_ATTEMPTED' THEN 'CALLBACK_ATTEMPTED'
      WHEN 'UNREACHABLE' THEN 'CALLBACK_UNREACHABLE'
      WHEN 'DETAILS_COLLECTED' THEN 'CALLBACK_COMPLETED'
      ELSE 'NOT_REQUIRED'
    END AS callback_status,
    c.category_name,
    ct.case_type_name,
    a.created_at,
    a.updated_at,
    CASE
      WHEN a.applicant_full_name IS NULL OR TRIM(a.applicant_full_name) = '' THEN NULL
      WHEN LENGTH(TRIM(a.applicant_full_name)) = 1 THEN LEFT(TRIM(a.applicant_full_name), 1) || '***'
      ELSE LEFT(TRIM(a.applicant_full_name), 1) || REPEAT('*', GREATEST(LENGTH(TRIM(a.applicant_full_name)) - 1, 3))
    END AS masked_name
  FROM public.legal_aid_application a
  LEFT JOIN public.legal_aid_category c ON c.id = a.category_id
  LEFT JOIN public.case_type_master ct ON ct.id = a.case_type_id
  WHERE RIGHT(REGEXP_REPLACE(a.applicant_phone_number, '\D', '', 'g'), 10) = v_clean_phone
  ORDER BY a.created_at DESC
  LIMIT 50;
END;
$$;

REVOKE EXECUTE ON FUNCTION public.track_applications_by_phone(text) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.track_applications_by_phone(text) TO service_role;

-- ============================================================================
-- 10. UPDATE track_application (Minimized guest view + status timeline)
-- ============================================================================

DROP FUNCTION IF EXISTS public.track_application(text, text);

CREATE OR REPLACE FUNCTION public.track_application(
  p_tracking_number text,
  p_phone_number text
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
BEGIN
  v_clean_phone := RIGHT(REGEXP_REPLACE(COALESCE(p_phone_number, ''), '\D', '', 'g'), 10);

  SELECT
    a.*,
    c.category_name,
    ct.case_type_name,
    d.district_name
  INTO v_app
  FROM public.legal_aid_application a
  LEFT JOIN public.legal_aid_category c ON c.id = a.category_id
  LEFT JOIN public.case_type_master ct ON ct.id = a.case_type_id
  LEFT JOIN public.district_master d ON d.id = a.current_district_id
  WHERE a.tracking_number = TRIM(p_tracking_number)
    AND RIGHT(REGEXP_REPLACE(a.applicant_phone_number, '\D', '', 'g'), 10) = v_clean_phone
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
      'case_details', v_app.case_details,
      'preferred_advocate_id', v_app.preferred_advocate_id,
      'assigned_advocate_id', v_app.assigned_advocate_id,
      'advocate_acceptance_status', v_app.advocate_acceptance_status,
      'assigned_at', v_app.assigned_at,
      'status', v_app.status,
      'callback_status', v_app.callback_status,
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
      'applicant_phone_number', v_clean_phone,
      'applicant_dob', NULL,
      'applicant_gender', NULL,
      'village_or_town', NULL,
      'case_details', '',
      'preferred_advocate_id', NULL,
      'assigned_advocate_id', NULL,
      'advocate_acceptance_status', 'NONE',
      'assigned_at', NULL,
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

-- ============================================================================
-- 11. UPDATE link_guest_applications_on_profile (Normalized 10-digit phone match)
-- ============================================================================

CREATE OR REPLACE FUNCTION public.link_guest_applications_on_profile()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_norm_phone text;
BEGIN
  IF NEW.phone_number IS NOT NULL THEN
    v_norm_phone := RIGHT(REGEXP_REPLACE(NEW.phone_number, '\D', '', 'g'), 10);
    IF LENGTH(v_norm_phone) = 10 THEN
      UPDATE public.legal_aid_application
      SET applicant_id = NEW.id
      WHERE RIGHT(REGEXP_REPLACE(applicant_phone_number, '\D', '', 'g'), 10) = v_norm_phone
        AND applicant_id IS NULL;
    END IF;
  END IF;

  RETURN NEW;
END;
$$;
