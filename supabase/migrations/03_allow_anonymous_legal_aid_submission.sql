-- =============================================================================
-- Migration 03: Allow citizens to apply for Legal Aid WITHOUT login (anonymous)
-- =============================================================================
-- Problem:
--   Anonymous (not-logged-in) citizens got:
--     42501 - new row violates row-level security policy for table
--             "legal_aid_application"
--   when submitting the application wizard.
--
-- Root cause:
--   The "anyone_submit_applications" INSERT policy existed in supabase/v3/
--   schema.sql but was never applied to the live database.
--
-- This migration:
--   1. Recreates the anonymous-submission INSERT policy on legal_aid_application
--   2. Lets the submitter link uploaded documents (application_document) to the
--      application row they just created (the EXISTS sub-select in the old
--      policy runs under the caller's SELECT RLS, which anonymous users fail)
--   3. Allows anonymous uploads to the legal-documents storage bucket under the
--      draft-uploads/ prefix (Step 4 of the wizard happens before login)
-- =============================================================================

-- -----------------------------------------------------------------------------
-- 1. Anonymous submissions of legal aid applications
--    (app omits applicant_id when the user is not logged in -> NULL)
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "anyone_submit_applications"
    ON "public"."legal_aid_application";

CREATE POLICY "anyone_submit_applications"
    ON "public"."legal_aid_application"
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (
        "applicant_id" IS NULL
        OR "applicant_id" = auth.uid()
        OR "public"."is_admin"()
    );

-- -----------------------------------------------------------------------------
-- 2. Link documents to the application that was just created
--    SECURITY DEFINER so the existence check is not blocked by the caller's
--    SELECT RLS on legal_aid_application. The application id is an unguessable
--    UUID returned only to the client that created the row.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION "public"."application_exists_for_link"(app_id uuid)
    RETURNS boolean
    LANGUAGE "sql"
    STABLE
    SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."legal_aid_application"
        WHERE "id" = app_id
    );
$$;

ALTER FUNCTION "public"."application_exists_for_link"(uuid)
    OWNER TO "postgres";

GRANT ALL ON FUNCTION "public"."application_exists_for_link"(uuid) TO "anon";
GRANT ALL ON FUNCTION "public"."application_exists_for_link"(uuid) TO "authenticated";
GRANT ALL ON FUNCTION "public"."application_exists_for_link"(uuid) TO "service_role";

DROP POLICY IF EXISTS "insert_documents_for_authorized_applications"
    ON "public"."application_document";

CREATE POLICY "insert_documents_for_authorized_applications"
    ON "public"."application_document"
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (
        "public"."is_admin"()
        OR "public"."application_exists_for_link"("application_id")
    );

-- -----------------------------------------------------------------------------
-- 3. Storage: anonymous document uploads during the wizard (Step 4)
--    Restricted to the draft-uploads/ prefix of the legal-documents bucket.
--    Read access is intentionally NOT granted to anon.
-- -----------------------------------------------------------------------------
DROP POLICY IF EXISTS "anon_upload_draft_documents" ON "storage"."objects";

CREATE POLICY "anon_upload_draft_documents"
    ON "storage"."objects"
    FOR INSERT
    TO anon, authenticated
    WITH CHECK (
        "bucket_id" = 'legal-documents'
        AND "name" LIKE 'draft-uploads/%'
    );

-- Allow the uploader to replace a re-taken photo for the same draft slot
-- (the app uploads with upsert: true).
DROP POLICY IF EXISTS "anon_update_draft_documents" ON "storage"."objects";

CREATE POLICY "anon_update_draft_documents"
    ON "storage"."objects"
    FOR UPDATE
    TO anon, authenticated
    USING (
        "bucket_id" = 'legal-documents'
        AND "name" LIKE 'draft-uploads/%'
    )
    WITH CHECK (
        "bucket_id" = 'legal-documents'
        AND "name" LIKE 'draft-uploads/%'
    );
