-- =============================================================================
-- Migration 04: Anonymous submission RPC (fixes INSERT ... RETURNING failure)
-- =============================================================================
-- Problem (discovered after Migration 03):
--   The INSERT policy now allows anonymous submissions, but the app submits
--   with `.insert(...).select(...)` which sends `Prefer: return=representation`
--   to PostgREST -> PostgreSQL executes INSERT ... RETURNING, and PostgreSQL
--   requires the RETURNED row to ALSO pass the table's SELECT policies.
--
--   Anonymous applications (applicant_id IS NULL) match NO SELECT policy on
--   legal_aid_application (they belong to no authenticated user), so the
--   insert fails with:
--     42501 - new row violates row-level security policy
--
--   Adding a SELECT policy for anonymous rows is NOT an option: it would
--   expose every anonymous applicant's PII (name, phone, DOB, case details)
--   to anyone holding the public anon key.
--
-- Fix:
--   A SECURITY DEFINER RPC that performs the insert and returns the created
--   row, bypassing the caller's SELECT RLS. The row is only ever returned to
--   the client that created it in the same call. applicant_id is taken from
--   auth.uid() server-side (NULL for anonymous, own uid for logged-in
--   citizens) and any client-supplied applicant_id is ignored.
-- =============================================================================

CREATE OR REPLACE FUNCTION "public"."submit_legal_aid_application"(
    "p_application" jsonb
)
RETURNS jsonb
LANGUAGE "plpgsql"
SECURITY DEFINER
SET "search_path" TO ''
AS $$
DECLARE
    v_applicant_id uuid := auth.uid();
    v_new_id       uuid;
    v_result       jsonb;
BEGIN
    INSERT INTO "public"."legal_aid_application" (
        "applicant_id",
        "category_id",
        "applicant_full_name",
        "applicant_phone_number",
        "applicant_dob",
        "applicant_gender",
        "village_or_town",
        "applicant_district_id",
        "case_type_id",
        "current_district_id",
        "current_taluka_id",
        "case_details",
        "preferred_advocate_id",
        "tracking_number"
    ) VALUES (
        v_applicant_id,
        ("p_application"->>'category_id')::uuid,
        "p_application"->>'applicant_full_name',
        "p_application"->>'applicant_phone_number',
        ("p_application"->>'applicant_dob')::date,
        UPPER("p_application"->>'applicant_gender'),
        NULLIF("p_application"->>'village_or_town', ''),
        ("p_application"->>'applicant_district_id')::uuid,
        ("p_application"->>'case_type_id')::uuid,
        ("p_application"->>'current_district_id')::uuid,
        ("p_application"->>'current_taluka_id')::uuid,
        "p_application"->>'case_details',
        NULLIF("p_application"->>'preferred_advocate_id', '')::uuid,
        NULLIF("p_application"->>'tracking_number', '')
    )
    RETURNING "id" INTO v_new_id;

    -- Returned as SECURITY DEFINER: readable by the caller who just created
    -- it, without opening the table to anonymous SELECTs.
    SELECT to_jsonb(a)
      INTO v_result
      FROM "public"."legal_aid_application" a
     WHERE a."id" = v_new_id;

    RETURN v_result;
END;
$$;

ALTER FUNCTION "public"."submit_legal_aid_application"(jsonb)
    OWNER TO "postgres";

REVOKE ALL ON FUNCTION "public"."submit_legal_aid_application"(jsonb) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION "public"."submit_legal_aid_application"(jsonb) TO anon;
GRANT EXECUTE ON FUNCTION "public"."submit_legal_aid_application"(jsonb) TO authenticated;
GRANT EXECUTE ON FUNCTION "public"."submit_legal_aid_application"(jsonb) TO service_role;
