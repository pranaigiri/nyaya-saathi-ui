-- Migration: allow case_type_id and case_details to be optional on initial submission in FULL mode.
-- If skipped by the citizen, they are verified and collected by an officer via phone call confirmation
-- before advocate assignment (which is guarded by trg_enforce_application_update_invariants).

ALTER TABLE public.legal_aid_application
  DROP CONSTRAINT IF EXISTS chk_application_mode_completeness;

ALTER TABLE public.legal_aid_application
  ADD CONSTRAINT chk_application_mode_completeness
  CHECK (
    application_mode = 'QUICK_CALLBACK' OR (
      category_id IS NOT NULL AND
      applicant_full_name IS NOT NULL AND
      applicant_dob IS NOT NULL AND
      applicant_gender IS NOT NULL AND
      applicant_district_id IS NOT NULL AND
      current_district_id IS NOT NULL
    )
  );
