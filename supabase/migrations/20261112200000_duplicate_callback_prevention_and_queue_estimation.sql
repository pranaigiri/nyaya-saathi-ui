-- Migration: 20261112200000_duplicate_callback_prevention_and_queue_estimation.sql
-- Description:
-- 1. Enforces atomic uniqueness for active callback requests at the database level.
-- 2. Implements intelligent queue estimation function based on historical callback processing.
-- 3. Updates create_quick_application RPC to prevent duplicate active callbacks atomically.

-- ============================================================================
-- 1. Deduplicate any existing duplicate active quick callbacks (if any)
-- ============================================================================
WITH ranked_active AS (
  SELECT id,
         ROW_NUMBER() OVER (
           PARTITION BY RIGHT(REGEXP_REPLACE(applicant_phone_number, '\D', '', 'g'), 10)
           ORDER BY created_at ASC
         ) as rn
  FROM public.legal_aid_application
  WHERE application_mode = 'QUICK_CALLBACK'
    AND callback_status IN ('PENDING_CALL', 'CALL_ATTEMPTED')
    AND status NOT IN ('REJECTED', 'WITHDRAWN', 'RESOLVED')
)
UPDATE public.legal_aid_application
SET callback_status = 'DETAILS_COLLECTED'
WHERE id IN (
  SELECT id FROM ranked_active WHERE rn > 1
);

-- ============================================================================
-- 2. Partial unique index: Only ONE active callback per normalized phone number
-- ============================================================================
CREATE UNIQUE INDEX IF NOT EXISTS idx_unique_active_quick_callback_phone
  ON public.legal_aid_application (
    (RIGHT(REGEXP_REPLACE(applicant_phone_number, '\D', '', 'g'), 10))
  )
  WHERE application_mode = 'QUICK_CALLBACK'
    AND callback_status IN ('PENDING_CALL', 'CALL_ATTEMPTED')
    AND status NOT IN ('REJECTED', 'WITHDRAWN', 'RESOLVED');

-- ============================================================================
-- 3. Intelligent Queue Estimation Function: get_callback_queue_estimate
-- ============================================================================
DROP FUNCTION IF EXISTS public.get_callback_queue_estimate(text);

CREATE OR REPLACE FUNCTION public.get_callback_queue_estimate(
  p_phone text DEFAULT NULL
)
RETURNS jsonb
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_clean_phone text;
  v_active_app record;
  v_queue_position int;
  v_total_pending int;
  v_completed_count int;
  v_active_days_count int;
  v_log_completed_count int;
  v_effective_completed int;
  v_daily_throughput numeric;
  v_hourly_throughput numeric;
  v_wait_hours numeric;
  v_wait_text text;
  v_is_reliable boolean := false;
  v_target_created_at timestamptz;
BEGIN
  -- Normalize phone if provided
  IF p_phone IS NOT NULL AND TRIM(p_phone) <> '' THEN
    v_clean_phone := RIGHT(REGEXP_REPLACE(p_phone, '\D', '', 'g'), 10);
  END IF;

  -- 1. Check if the citizen has an active callback request
  IF v_clean_phone IS NOT NULL AND LENGTH(v_clean_phone) = 10 THEN
    SELECT id, tracking_number, created_at, status, callback_status
    INTO v_active_app
    FROM public.legal_aid_application
    WHERE application_mode = 'QUICK_CALLBACK'
      AND callback_status IN ('PENDING_CALL', 'CALL_ATTEMPTED')
      AND status NOT IN ('REJECTED', 'WITHDRAWN', 'RESOLVED')
      AND RIGHT(REGEXP_REPLACE(applicant_phone_number, '\D', '', 'g'), 10) = v_clean_phone
    ORDER BY created_at ASC
    LIMIT 1;
  END IF;

  -- 2. Count total pending callbacks currently in queue
  SELECT COUNT(*)
  INTO v_total_pending
  FROM public.legal_aid_application
  WHERE application_mode = 'QUICK_CALLBACK'
    AND callback_status IN ('PENDING_CALL', 'CALL_ATTEMPTED')
    AND status NOT IN ('REJECTED', 'WITHDRAWN', 'RESOLVED');

  -- 3. Determine queue position
  IF v_active_app.id IS NOT NULL THEN
    v_target_created_at := v_active_app.created_at;
    SELECT COUNT(*)
    INTO v_queue_position
    FROM public.legal_aid_application
    WHERE application_mode = 'QUICK_CALLBACK'
      AND callback_status IN ('PENDING_CALL', 'CALL_ATTEMPTED')
      AND status NOT IN ('REJECTED', 'WITHDRAWN', 'RESOLVED')
      AND created_at <= v_target_created_at;
  ELSE
    -- If asking about next position for a new submission
    v_queue_position := v_total_pending + 1;
  END IF;

  IF v_queue_position < 1 THEN
    v_queue_position := 1;
  END IF;

  -- 4. Calculate historical performance in the last 30 days
  -- From legal_aid_application:
  SELECT
    COUNT(*),
    COUNT(DISTINCT DATE(COALESCE(details_completed_at, updated_at)))
  INTO v_completed_count, v_active_days_count
  FROM public.legal_aid_application
  WHERE application_mode = 'QUICK_CALLBACK'
    AND (callback_status = 'DETAILS_COLLECTED' OR details_completed_at IS NOT NULL)
    AND COALESCE(details_completed_at, updated_at) >= (now() - interval '30 days');

  -- From application_callback_log:
  SELECT COUNT(*)
  INTO v_log_completed_count
  FROM public.application_callback_log
  WHERE outcome = 'DETAILS_COLLECTED'
    AND called_at >= (now() - interval '30 days');

  v_effective_completed := GREATEST(COALESCE(v_completed_count, 0), COALESCE(v_log_completed_count, 0));

  -- If insufficient historical data (< 5 completed callbacks), do not invent arbitrary numbers
  IF v_effective_completed >= 5 THEN
    v_is_reliable := true;
    -- Sikkim SLSA operating hours: 7 hours/day (10:00 AM - 5:00 PM, Mon-Sat)
    v_daily_throughput := (v_effective_completed::numeric / GREATEST(v_active_days_count, 1)::numeric);
    v_hourly_throughput := GREATEST(v_daily_throughput / 7.0, 0.2); -- at least 0.2 callbacks/hr floor

    v_wait_hours := v_queue_position::numeric / v_hourly_throughput;

    IF v_wait_hours <= 1.0 THEN
      v_wait_text := 'Within approximately 1 working hour';
    ELSIF v_wait_hours <= 2.5 THEN
      v_wait_text := 'Within approximately 1–3 working hours';
    ELSIF v_wait_hours <= 5.0 THEN
      v_wait_text := 'Within approximately 3–5 working hours';
    ELSIF v_wait_hours <= 8.0 THEN
      v_wait_text := 'Within 1 working day';
    ELSIF v_wait_hours <= 16.0 THEN
      v_wait_text := 'Within 1–2 working days';
    ELSE
      v_wait_text := 'Within 2–3 working days';
    END IF;
  ELSE
    v_is_reliable := false;
    v_wait_text := NULL;
  END IF;

  RETURN jsonb_build_object(
    'has_active_request', (v_active_app.id IS NOT NULL),
    'tracking_number', v_active_app.tracking_number,
    'queue_position', v_queue_position,
    'total_pending', v_total_pending,
    'is_reliable_estimate', v_is_reliable,
    'estimated_wait_text', v_wait_text,
    'fallback_message', 'Your request is queued. Our team will contact you as soon as possible.',
    'created_at', v_active_app.created_at
  );
END;
$$;

GRANT EXECUTE ON FUNCTION public.get_callback_queue_estimate(text) TO anon, authenticated, service_role;

-- ============================================================================
-- 4. Update create_quick_application to prevent duplicates atomically
-- ============================================================================
-- Must drop the function first because the return TABLE columns (OUT parameters) have changed
DROP FUNCTION IF EXISTS public.create_quick_application(text, text, uuid, text, uuid);

CREATE OR REPLACE FUNCTION public.create_quick_application(
  p_phone text,
  p_name text,
  p_district_id uuid,
  p_note text,
  p_applicant_id uuid
)
RETURNS TABLE(
  tracking_number text,
  application_id uuid,
  is_duplicate boolean,
  queue_position int,
  total_pending int,
  estimated_wait_text text,
  is_reliable_estimate boolean
)
LANGUAGE plpgsql
SECURITY DEFINER
SET search_path = public, pg_temp
AS $$
DECLARE
  v_clean_phone text;
  v_app_id uuid;
  v_tracking text;
  v_existing_id uuid;
  v_existing_tracking text;
  v_estimate jsonb;
BEGIN
  v_clean_phone := RIGHT(REGEXP_REPLACE(COALESCE(p_phone, ''), '\D', '', 'g'), 10);
  IF LENGTH(v_clean_phone) <> 10 THEN
    RAISE EXCEPTION 'Invalid phone number: exactly 10 digits required'
      USING ERRCODE = 'invalid_parameter_value';
  END IF;

  -- 1. Pre-check for existing active callback
  SELECT id, legal_aid_application.tracking_number
  INTO v_existing_id, v_existing_tracking
  FROM public.legal_aid_application
  WHERE application_mode = 'QUICK_CALLBACK'
    AND callback_status IN ('PENDING_CALL', 'CALL_ATTEMPTED')
    AND status NOT IN ('REJECTED', 'WITHDRAWN', 'RESOLVED')
    AND RIGHT(REGEXP_REPLACE(applicant_phone_number, '\D', '', 'g'), 10) = v_clean_phone
  ORDER BY created_at ASC
  LIMIT 1;

  IF v_existing_id IS NOT NULL THEN
    v_estimate := public.get_callback_queue_estimate(v_clean_phone);
    RETURN QUERY SELECT
      v_existing_tracking,
      v_existing_id,
      true, -- is_duplicate = true
      COALESCE((v_estimate->>'queue_position')::int, 1),
      COALESCE((v_estimate->>'total_pending')::int, 1),
      v_estimate->>'estimated_wait_text',
      COALESCE((v_estimate->>'is_reliable_estimate')::boolean, false);
    RETURN;
  END IF;

  -- 2. Insert new callback request atomically protected by unique index
  BEGIN
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
  EXCEPTION WHEN unique_violation THEN
    -- Race condition handled atomically
    SELECT id, legal_aid_application.tracking_number
    INTO v_existing_id, v_existing_tracking
    FROM public.legal_aid_application
    WHERE application_mode = 'QUICK_CALLBACK'
      AND callback_status IN ('PENDING_CALL', 'CALL_ATTEMPTED')
      AND status NOT IN ('REJECTED', 'WITHDRAWN', 'RESOLVED')
      AND RIGHT(REGEXP_REPLACE(applicant_phone_number, '\D', '', 'g'), 10) = v_clean_phone
    ORDER BY created_at ASC
    LIMIT 1;

    v_estimate := public.get_callback_queue_estimate(v_clean_phone);
    RETURN QUERY SELECT
      v_existing_tracking,
      v_existing_id,
      true,
      COALESCE((v_estimate->>'queue_position')::int, 1),
      COALESCE((v_estimate->>'total_pending')::int, 1),
      v_estimate->>'estimated_wait_text',
      COALESCE((v_estimate->>'is_reliable_estimate')::boolean, false);
    RETURN;
  END;

  v_estimate := public.get_callback_queue_estimate(v_clean_phone);
  RETURN QUERY SELECT
    v_tracking,
    v_app_id,
    false, -- is_duplicate = false
    COALESCE((v_estimate->>'queue_position')::int, 1),
    COALESCE((v_estimate->>'total_pending')::int, 1),
    v_estimate->>'estimated_wait_text',
    COALESCE((v_estimate->>'is_reliable_estimate')::boolean, false);
END;
$$;

REVOKE EXECUTE ON FUNCTION public.create_quick_application(text, text, uuid, text, uuid) FROM PUBLIC, anon, authenticated;
GRANT EXECUTE ON FUNCTION public.create_quick_application(text, text, uuid, text, uuid) TO service_role;

