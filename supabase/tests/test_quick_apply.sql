-- ============================================================================
-- TEST SUITE: Quick Apply (Request a Call) & Telemetry Verification
-- Run inside Supabase SQL Editor or via psql transaction
-- ============================================================================

BEGIN;

-- Savepoint so test can clean up
SAVEPOINT test_start;

DO $$
DECLARE
  v_test_dist_id uuid;
  v_test_cat_id uuid;
  v_test_case_id uuid;
  v_quick_app_id uuid;
  v_quick_tracking text;
  v_quick_dist_app_id uuid;
  v_quick_dist_tracking text;
  v_full_app jsonb;
  v_full_tracking text;
  v_history_count int;
  v_tracked_records int;
  v_tracked_json jsonb;
  v_blocked boolean := false;
  v_old_tracking text;
BEGIN
  RAISE NOTICE '>>> STARTING QUICK APPLY TEST SUITE <<<';

  -- --------------------------------------------------------------------------
  -- 1. Verify Existing Rows Integrity
  -- --------------------------------------------------------------------------
  ASSERT (
    SELECT COUNT(*) FROM public.legal_aid_application WHERE application_mode <> 'FULL'
  ) = 0, 'FAIL: Found existing rows with application_mode <> FULL';

  ASSERT (
    SELECT COUNT(*) FROM public.legal_aid_application WHERE callback_status <> 'NOT_REQUIRED'
  ) = 0, 'FAIL: Found existing rows with callback_status <> NOT_REQUIRED';

  RAISE NOTICE 'Test 1 PASS: Existing rows are in FULL mode and NOT_REQUIRED callback status.';

  -- Resolve test references
  SELECT id INTO v_test_dist_id FROM public.district_master WHERE district_code = 'GTK' LIMIT 1;
  SELECT id INTO v_test_cat_id FROM public.legal_aid_category LIMIT 1;
  SELECT id INTO v_test_case_id FROM public.case_type_master LIMIT 1;

  -- --------------------------------------------------------------------------
  -- 2. Quick Insert with Phone Only
  -- --------------------------------------------------------------------------
  SELECT tracking_number, application_id
  INTO v_quick_tracking, v_quick_app_id
  FROM public.create_quick_application(
    '9811122233',
    'Test Quick Applicant',
    NULL,
    'Urgent callback requested regarding land dispute',
    NULL
  );

  ASSERT v_quick_tracking LIKE 'SK-GEN-%',
    'FAIL: Expected tracking number to start with SK-GEN-, got ' || v_quick_tracking;

  ASSERT (
    SELECT application_mode FROM public.legal_aid_application WHERE id = v_quick_app_id
  ) = 'QUICK_CALLBACK', 'FAIL: Application mode is not QUICK_CALLBACK';

  ASSERT (
    SELECT callback_status FROM public.legal_aid_application WHERE id = v_quick_app_id
  ) = 'PENDING_CALL', 'FAIL: Callback status is not PENDING_CALL';

  -- Verify initial status history row (SUBMITTED) was written even without applicant_id
  SELECT COUNT(*) INTO v_history_count
  FROM public.application_status_history
  WHERE application_id = v_quick_app_id AND new_status = 'SUBMITTED';

  ASSERT v_history_count = 1,
    'FAIL: Expected 1 SUBMITTED status history row for guest quick apply, found ' || v_history_count;

  RAISE NOTICE 'Test 2 PASS: Quick apply with phone only generated % and status history row.', v_quick_tracking;

  -- --------------------------------------------------------------------------
  -- 3. Quick Insert with District
  -- --------------------------------------------------------------------------
  SELECT tracking_number, application_id
  INTO v_quick_dist_tracking, v_quick_dist_app_id
  FROM public.create_quick_application(
    '9811122233',
    'District Quick Applicant',
    v_test_dist_id,
    'Need help in Gangtok district',
    NULL
  );

  ASSERT v_quick_dist_tracking LIKE 'SK-GTK-%',
    'FAIL: Expected tracking number to start with SK-GTK-, got ' || v_quick_dist_tracking;

  ASSERT (
    SELECT current_district_id FROM public.legal_aid_application WHERE id = v_quick_dist_app_id
  ) = v_test_dist_id, 'FAIL: current_district_id not populated on quick insert with district';

  RAISE NOTICE 'Test 3 PASS: Quick apply with district generated % with correct district assignment.', v_quick_dist_tracking;

  -- --------------------------------------------------------------------------
  -- 4. Tracking Number Immutability on Update
  -- --------------------------------------------------------------------------
  v_old_tracking := v_quick_tracking;
  UPDATE public.legal_aid_application
  SET applicant_district_id = v_test_dist_id,
      current_district_id = v_test_dist_id,
      tracking_number = 'SK-MODIFIED-99-99999'
  WHERE id = v_quick_app_id;

  ASSERT (
    SELECT tracking_number FROM public.legal_aid_application WHERE id = v_quick_app_id
  ) = v_old_tracking, 'FAIL: Tracking number was modified during update';

  RAISE NOTICE 'Test 4 PASS: Tracking number remained strictly immutable after updating district.';

  -- --------------------------------------------------------------------------
  -- 5. Enforce Details Before ADVOCATE_ASSIGNED
  -- --------------------------------------------------------------------------
  v_blocked := false;
  BEGIN
    UPDATE public.legal_aid_application
    SET status = 'ADVOCATE_ASSIGNED'
    WHERE id = v_quick_app_id;
  EXCEPTION WHEN check_violation THEN
    v_blocked := true;
  END;

  ASSERT v_blocked, 'FAIL: Status was changed to ADVOCATE_ASSIGNED while details were incomplete';

  -- Complete details and then assign
  UPDATE public.legal_aid_application
  SET category_id = v_test_cat_id,
      case_type_id = v_test_case_id,
      applicant_full_name = 'Full Applicant Name',
      applicant_dob = '1995-05-15',
      applicant_gender = 'MALE',
      applicant_district_id = v_test_dist_id,
      current_district_id = v_test_dist_id,
      case_details = 'Comprehensive case details collected by admin callback.',
      callback_status = 'DETAILS_COLLECTED',
      details_completed_at = now()
  WHERE id = v_quick_app_id;

  UPDATE public.legal_aid_application
  SET status = 'ADVOCATE_ASSIGNED'
  WHERE id = v_quick_app_id;

  ASSERT (
    SELECT status FROM public.legal_aid_application WHERE id = v_quick_app_id
  ) = 'ADVOCATE_ASSIGNED', 'FAIL: Status could not be updated after details were completed';

  RAISE NOTICE 'Test 5 PASS: ADVOCATE_ASSIGNED correctly blocked until details are complete.';

  -- --------------------------------------------------------------------------
  -- 6. Phone-Only Tracking (track_applications_by_phone)
  -- --------------------------------------------------------------------------
  SELECT COUNT(*) INTO v_tracked_records
  FROM public.track_applications_by_phone('+91 98111 22233');

  ASSERT v_tracked_records >= 2,
    'FAIL: Expected at least 2 applications for phone 9811122233, found ' || v_tracked_records;

  -- Verify masking
  ASSERT (
    SELECT masked_name FROM public.track_applications_by_phone('9811122233') LIMIT 1
  ) LIKE '%***%', 'FAIL: Applicant name was not masked';

  RAISE NOTICE 'Test 6 PASS: Phone-only tracking returns sanitized, masked results matching normalized numbers.';

  -- --------------------------------------------------------------------------
  -- 7. track_application RPC Minimized View
  -- --------------------------------------------------------------------------
  SELECT public.track_application(v_quick_dist_tracking, '+91-98111-22233')
  INTO v_tracked_json;

  ASSERT v_tracked_json IS NOT NULL, 'FAIL: track_application returned NULL for valid number';
  ASSERT (v_tracked_json->>'case_details') = '', 'FAIL: Guest track_application leaked case_details';
  ASSERT (v_tracked_json->'applicant_dob') IS NULL, 'FAIL: Guest track_application leaked DOB';
  ASSERT (v_tracked_json->'status_timeline') IS NOT NULL, 'FAIL: Missing status_timeline in guest track_application';

  RAISE NOTICE 'Test 7 PASS: track_application RPC returns safe guest view with timeline.';

  -- --------------------------------------------------------------------------
  -- 8. Old FULL Flow Backward Compatibility
  -- --------------------------------------------------------------------------
  SELECT public.submit_legal_aid_application(
    jsonb_build_object(
      'category_id', v_test_cat_id,
      'applicant_full_name', 'Legacy Flow User',
      'applicant_phone_number', '9700011122',
      'applicant_dob', '1998-01-01',
      'applicant_gender', 'FEMALE',
      'applicant_district_id', v_test_dist_id,
      'case_type_id', v_test_case_id,
      'current_district_id', v_test_dist_id,
      'case_details', 'Detailed grievance from 5-step wizard'
    )
  ) INTO v_full_app;

  v_full_tracking := v_full_app->>'tracking_number';
  ASSERT v_full_tracking IS NOT NULL, 'FAIL: submit_legal_aid_application failed';
  ASSERT (v_full_app->>'application_mode') = 'FULL', 'FAIL: Legacy app mode is not FULL';

  RAISE NOTICE 'Test 8 PASS: Legacy submit_legal_aid_application RPC works seamlessly.';

  -- --------------------------------------------------------------------------
  -- 9. Callback Log Append-Only Integrity
  -- --------------------------------------------------------------------------
  INSERT INTO public.application_callback_log (
    application_id,
    outcome,
    notes
  ) VALUES (
    v_quick_app_id,
    'CALL_BACK_LATER',
    'Citizen requested callback after 5 PM'
  );

  ASSERT (
    SELECT COUNT(*) FROM public.application_callback_log WHERE application_id = v_quick_app_id
  ) = 1, 'FAIL: Callback log insert failed';

  RAISE NOTICE 'Test 9 PASS: Application callback log append-only insert verified.';

  -- --------------------------------------------------------------------------
  -- 10. Submission Attempt Telemetry
  -- --------------------------------------------------------------------------
  INSERT INTO public.submission_attempt_log (
    action,
    phone_hash,
    device_hash,
    ip_hash,
    outcome,
    reason
  ) VALUES (
    'SUBMIT_QUICK',
    'test_phone_hash_abc',
    'test_device_hash_def',
    'test_ip_hash_123',
    'SUCCESS',
    NULL
  );

  ASSERT (
    SELECT COUNT(*) FROM public.submission_attempt_log WHERE phone_hash = 'test_phone_hash_abc'
  ) = 1, 'FAIL: Submission attempt log insert failed';

  RAISE NOTICE 'Test 10 PASS: Submission attempt log telemetry verified.';

  RAISE NOTICE '>>> ALL 10 TESTS PASSED SUCCESSFULLY! <<<';
END $$;

-- Roll back changes so database state is untouched
ROLLBACK TO SAVEPOINT test_start;
COMMIT;
