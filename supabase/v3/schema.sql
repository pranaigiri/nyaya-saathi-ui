


SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;


COMMENT ON SCHEMA "public" IS 'standard public schema';



CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";






CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";






CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";






CREATE TYPE "public"."user_status_enum" AS ENUM (
    'ACTIVE',
    'INACTIVE',
    'SUSPENDED'
);


ALTER TYPE "public"."user_status_enum" OWNER TO "postgres";


CREATE TYPE "public"."user_type_enum" AS ENUM (
    'CITIZEN',
    'ADVOCATE',
    'ADMIN',
    'STAFF',
    'DISTRICT_ADMIN',
    'STATE_ADMIN',
    'SUPER_ADMIN'
);


ALTER TYPE "public"."user_type_enum" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_profile_status"() RETURNS "public"."user_status_enum"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT p.status
    FROM public.profiles p
    WHERE p.id = auth.uid()
    LIMIT 1;
$$;


ALTER FUNCTION "public"."current_profile_status"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."current_profile_user_type"() RETURNS "public"."user_type_enum"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT p.user_type
    FROM public.profiles p
    WHERE p.id = auth.uid()
    LIMIT 1;
$$;


ALTER FUNCTION "public"."current_profile_user_type"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_tracking_number"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
    dist_code TEXT;
    year_str TEXT;
    seq_val INT;
BEGIN
    SELECT district_code
    INTO dist_code
    FROM public.district_master
    WHERE id = NEW.current_district_id;

    IF dist_code IS NULL THEN
        dist_code := 'SLSA';
    END IF;

    year_str := TO_CHAR(NOW(), 'YY');
    seq_val := NEXTVAL('public.application_tracking_seq');

    NEW.tracking_number :=
        'SK-' || dist_code || '-' || year_str || '-' || LPAD(seq_val::TEXT, 5, '0');

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."generate_tracking_number"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."profiles" (
    "id" "uuid" NOT NULL,
    "full_name" "text" NOT NULL,
    "phone_number" "text",
    "email" "text",
    "dob" "date",
    "gender" "text",
    "village_or_town" "text",
    "district_id" "uuid",
    "user_type" "public"."user_type_enum" DEFAULT 'CITIZEN'::"public"."user_type_enum" NOT NULL,
    "status" "public"."user_status_enum" DEFAULT 'ACTIVE'::"public"."user_status_enum" NOT NULL,
    "last_login_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_profile"() RETURNS "public"."profiles"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT *
    FROM public.profiles
    WHERE id = auth.uid()
    LIMIT 1;
$$;


ALTER FUNCTION "public"."get_my_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_new_user_signup"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    INSERT INTO public.profiles (
        id,
        full_name,
        phone_number,
        email,
        user_type,
        status
    )
    VALUES (
        NEW.id,
        COALESCE(
            NEW.raw_user_meta_data ->> 'full_name',
            NEW.raw_user_meta_data ->> 'name',
            'Citizen'
        ),
        NULLIF(
            COALESCE(
                NEW.phone,
                NEW.raw_user_meta_data ->> 'phone_number',
                NEW.raw_user_meta_data ->> 'phone',
                ''
            ),
            ''
        ),
        NEW.email,
        'CITIZEN',
        'ACTIVE'
    )
    ON CONFLICT (id) DO UPDATE
    SET
        email = COALESCE(EXCLUDED.email, public.profiles.email),
        phone_number = COALESCE(EXCLUDED.phone_number, public.profiles.phone_number);

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_new_user_signup"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."handle_updated_at"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."handle_updated_at"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_admin"() RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles p
        LEFT JOIN public.admin_scope s ON s.user_id = p.id
        WHERE p.id = auth.uid()
          AND p.status = 'ACTIVE'
          AND (
                p.user_type IN ('ADMIN', 'SUPER_ADMIN')
                OR s.is_global_super_admin = TRUE
          )
    );
$$;


ALTER FUNCTION "public"."is_admin"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_district_admin"("dist_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles p
        LEFT JOIN public.admin_scope s ON s.user_id = p.id
        WHERE p.id = auth.uid()
          AND p.status = 'ACTIVE'
          AND (
                p.user_type IN ('ADMIN', 'SUPER_ADMIN')
                OR s.is_global_super_admin = TRUE
                OR s.district_id = dist_id
          )
    );
$$;


ALTER FUNCTION "public"."is_district_admin"("dist_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_state_admin"("p_state_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.profiles p
        LEFT JOIN public.admin_scope s ON s.user_id = p.id
        WHERE p.id = auth.uid()
          AND p.status = 'ACTIVE'
          AND (
                p.user_type IN ('ADMIN', 'SUPER_ADMIN', 'STATE_ADMIN')
                OR s.is_global_super_admin = TRUE
                OR s.state_id = p_state_id
          )
    );
$$;


ALTER FUNCTION "public"."is_state_admin"("p_state_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."link_guest_applications_on_profile"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
BEGIN
    IF NEW.phone_number IS NOT NULL THEN
        UPDATE public.legal_aid_application
        SET applicant_id = NEW.id
        WHERE applicant_phone_number = NEW.phone_number
          AND applicant_id IS NULL;
    END IF;

    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."link_guest_applications_on_profile"() OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_aid_application" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tracking_number" "text" NOT NULL,
    "applicant_id" "uuid",
    "category_id" "uuid" NOT NULL,
    "applicant_full_name" "text" NOT NULL,
    "applicant_phone_number" "text" NOT NULL,
    "applicant_dob" "date" NOT NULL,
    "applicant_gender" "text" NOT NULL,
    "village_or_town" "text",
    "applicant_district_id" "uuid" NOT NULL,
    "case_type_id" "uuid" NOT NULL,
    "current_district_id" "uuid" NOT NULL,
    "current_taluka_id" "uuid",
    "case_details" "text" NOT NULL,
    "preferred_advocate_id" "uuid",
    "assigned_advocate_id" "uuid",
    "advocate_acceptance_status" "text" DEFAULT 'NONE'::"text" NOT NULL,
    "assigned_at" timestamp with time zone,
    "status" "text" DEFAULT 'SUBMITTED'::"text" NOT NULL,
    "is_withdrawn_by_citizen" boolean DEFAULT false NOT NULL,
    "withdrawal_reason" "text",
    "withdrawn_at" timestamp with time zone,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "legal_aid_application_advocate_acceptance_status_check" CHECK (("advocate_acceptance_status" = ANY (ARRAY['NONE'::"text", 'PENDING'::"text", 'ACCEPTED'::"text", 'REJECTED'::"text"]))),
    CONSTRAINT "legal_aid_application_status_check" CHECK (("status" = ANY (ARRAY['SUBMITTED'::"text", 'UNDER_REVIEW'::"text", 'ADVOCATE_ASSIGNED'::"text", 'RESOLVED'::"text", 'REJECTED'::"text", 'WITHDRAWN'::"text"])))
);


ALTER TABLE "public"."legal_aid_application" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."track_application"("p_tracking_number" "text", "p_phone_number" "text") RETURNS SETOF "public"."legal_aid_application"
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT *
    FROM public.legal_aid_application
    WHERE tracking_number = p_tracking_number
      AND applicant_phone_number = p_phone_number
    LIMIT 1;
$$;


ALTER FUNCTION "public"."track_application"("p_tracking_number" "text", "p_phone_number" "text") OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."admin_scope" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "is_global_super_admin" boolean DEFAULT false NOT NULL,
    "state_id" "uuid",
    "district_id" "uuid",
    "scope_level" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "admin_scope_scope_level_check" CHECK (("scope_level" = ANY (ARRAY['GLOBAL'::"text", 'STATE'::"text", 'DISTRICT'::"text"])))
);


ALTER TABLE "public"."admin_scope" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."advocate_case_action_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "advocate_id" "uuid" NOT NULL,
    "action_type" "text" NOT NULL,
    "reason" "text" NOT NULL,
    "action_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."advocate_case_action_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."advocate_change_request" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "requested_by_citizen_id" "uuid" NOT NULL,
    "current_advocate_id" "uuid",
    "preferred_new_advocate_id" "uuid",
    "reason" "text" NOT NULL,
    "request_status" "text" DEFAULT 'PENDING'::"text" NOT NULL,
    "reviewed_by_admin_id" "uuid",
    "admin_remarks" "text",
    "requested_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "reviewed_at" timestamp with time zone,
    CONSTRAINT "advocate_change_request_request_status_check" CHECK (("request_status" = ANY (ARRAY['PENDING'::"text", 'APPROVED'::"text", 'REJECTED'::"text"])))
);


ALTER TABLE "public"."advocate_change_request" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."advocate_district_mapping" (
    "advocate_id" "uuid" NOT NULL,
    "district_id" "uuid" NOT NULL,
    "is_primary_district" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."advocate_district_mapping" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."advocate_master" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid",
    "full_name" "text" NOT NULL,
    "gender" "text",
    "enrollment_number" "text" NOT NULL,
    "primary_email" "text" NOT NULL,
    "secondary_email" "text",
    "primary_phone_number" "text" NOT NULL,
    "secondary_phone_number" "text",
    "office_address" "text",
    "experience_years" integer DEFAULT 0,
    "is_active" boolean DEFAULT true NOT NULL,
    "is_available_for_assignment" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "advocate_master_experience_years_check" CHECK (("experience_years" >= 0))
);


ALTER TABLE "public"."advocate_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."application_document" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "document_id" "uuid" NOT NULL,
    "file_url" "text" NOT NULL,
    "file_name" "text" NOT NULL,
    "file_size_in_bytes" bigint,
    "is_verified" boolean DEFAULT false NOT NULL,
    "verified_by" "uuid",
    "uploaded_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."application_document" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."application_forward_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "from_district_id" "uuid" NOT NULL,
    "to_district_id" "uuid" NOT NULL,
    "forwarded_by_id" "uuid" NOT NULL,
    "reason" "text" NOT NULL,
    "forwarded_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."application_forward_log" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."application_status_history" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "previous_status" "text",
    "new_status" "text" NOT NULL,
    "changed_by_id" "uuid" NOT NULL,
    "remarks" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."application_status_history" OWNER TO "postgres";


CREATE SEQUENCE IF NOT EXISTS "public"."application_tracking_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE "public"."application_tracking_seq" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."case_type_document_map" (
    "case_type_id" "uuid" NOT NULL,
    "document_id" "uuid" NOT NULL,
    "is_required" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."case_type_document_map" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."case_type_master" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "case_type_code" "text" NOT NULL,
    "case_type_name" "text" NOT NULL,
    "icon_url" "text",
    "display_order" integer DEFAULT 0,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."case_type_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."district_master" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "district_name" "text" NOT NULL,
    "district_code" "text" NOT NULL,
    "state_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."district_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."document_master" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "document_code" "text" NOT NULL,
    "document_name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."document_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_aid_category" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "category_code" "text" NOT NULL,
    "category_name" "text" NOT NULL,
    "description" "text",
    "display_order" integer DEFAULT 0,
    "icon_url" "text",
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."legal_aid_category" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."legal_aid_category_document_map" (
    "category_id" "uuid" NOT NULL,
    "document_id" "uuid" NOT NULL,
    "is_required" boolean DEFAULT true NOT NULL
);


ALTER TABLE "public"."legal_aid_category_document_map" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."roles" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "name" "text" NOT NULL,
    "description" "text",
    "is_active" boolean DEFAULT true NOT NULL,
    "is_system" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."roles" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."state_master" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "state_name" "text" NOT NULL,
    "state_code" "text" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."state_master" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."taluka_master" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "taluka_name" "text" NOT NULL,
    "taluka_code" "text" NOT NULL,
    "district_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL
);


ALTER TABLE "public"."taluka_master" OWNER TO "postgres";


ALTER TABLE ONLY "public"."admin_scope"
    ADD CONSTRAINT "admin_scope_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."advocate_case_action_log"
    ADD CONSTRAINT "advocate_case_action_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."advocate_change_request"
    ADD CONSTRAINT "advocate_change_request_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."advocate_district_mapping"
    ADD CONSTRAINT "advocate_district_mapping_pkey" PRIMARY KEY ("advocate_id", "district_id");



ALTER TABLE ONLY "public"."advocate_master"
    ADD CONSTRAINT "advocate_master_enrollment_number_key" UNIQUE ("enrollment_number");



ALTER TABLE ONLY "public"."advocate_master"
    ADD CONSTRAINT "advocate_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."advocate_master"
    ADD CONSTRAINT "advocate_master_user_id_key" UNIQUE ("user_id");



ALTER TABLE ONLY "public"."application_document"
    ADD CONSTRAINT "application_document_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."application_forward_log"
    ADD CONSTRAINT "application_forward_log_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."application_status_history"
    ADD CONSTRAINT "application_status_history_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."case_type_document_map"
    ADD CONSTRAINT "case_type_document_map_pkey" PRIMARY KEY ("case_type_id", "document_id");



ALTER TABLE ONLY "public"."case_type_master"
    ADD CONSTRAINT "case_type_master_case_type_code_key" UNIQUE ("case_type_code");



ALTER TABLE ONLY "public"."case_type_master"
    ADD CONSTRAINT "case_type_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."district_master"
    ADD CONSTRAINT "district_master_district_code_key" UNIQUE ("district_code");



ALTER TABLE ONLY "public"."district_master"
    ADD CONSTRAINT "district_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."document_master"
    ADD CONSTRAINT "document_master_document_code_key" UNIQUE ("document_code");



ALTER TABLE ONLY "public"."document_master"
    ADD CONSTRAINT "document_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_tracking_number_key" UNIQUE ("tracking_number");



ALTER TABLE ONLY "public"."legal_aid_category"
    ADD CONSTRAINT "legal_aid_category_category_code_key" UNIQUE ("category_code");



ALTER TABLE ONLY "public"."legal_aid_category_document_map"
    ADD CONSTRAINT "legal_aid_category_document_map_pkey" PRIMARY KEY ("category_id", "document_id");



ALTER TABLE ONLY "public"."legal_aid_category"
    ADD CONSTRAINT "legal_aid_category_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_phone_number_key" UNIQUE ("phone_number");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."roles"
    ADD CONSTRAINT "roles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."state_master"
    ADD CONSTRAINT "state_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."state_master"
    ADD CONSTRAINT "state_master_state_code_key" UNIQUE ("state_code");



ALTER TABLE ONLY "public"."taluka_master"
    ADD CONSTRAINT "taluka_master_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."taluka_master"
    ADD CONSTRAINT "taluka_master_taluka_code_key" UNIQUE ("taluka_code");



CREATE OR REPLACE TRIGGER "set_advocate_updated_at" BEFORE UPDATE ON "public"."advocate_master" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_legal_aid_application_updated_at" BEFORE UPDATE ON "public"."legal_aid_application" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_roles_updated_at" BEFORE UPDATE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "trigger_link_guest_applications" AFTER INSERT OR UPDATE OF "phone_number" ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."link_guest_applications_on_profile"();



CREATE OR REPLACE TRIGGER "trigger_set_tracking_number" BEFORE INSERT ON "public"."legal_aid_application" FOR EACH ROW WHEN ((("new"."tracking_number" IS NULL) OR ("new"."tracking_number" = ''::"text"))) EXECUTE FUNCTION "public"."generate_tracking_number"();



ALTER TABLE ONLY "public"."admin_scope"
    ADD CONSTRAINT "admin_scope_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "public"."district_master"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."admin_scope"
    ADD CONSTRAINT "admin_scope_state_id_fkey" FOREIGN KEY ("state_id") REFERENCES "public"."state_master"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."admin_scope"
    ADD CONSTRAINT "admin_scope_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."advocate_case_action_log"
    ADD CONSTRAINT "advocate_case_action_log_advocate_id_fkey" FOREIGN KEY ("advocate_id") REFERENCES "public"."advocate_master"("id");



ALTER TABLE ONLY "public"."advocate_case_action_log"
    ADD CONSTRAINT "advocate_case_action_log_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."legal_aid_application"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."advocate_change_request"
    ADD CONSTRAINT "advocate_change_request_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."legal_aid_application"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."advocate_change_request"
    ADD CONSTRAINT "advocate_change_request_current_advocate_id_fkey" FOREIGN KEY ("current_advocate_id") REFERENCES "public"."advocate_master"("id");



ALTER TABLE ONLY "public"."advocate_change_request"
    ADD CONSTRAINT "advocate_change_request_preferred_new_advocate_id_fkey" FOREIGN KEY ("preferred_new_advocate_id") REFERENCES "public"."advocate_master"("id");



ALTER TABLE ONLY "public"."advocate_change_request"
    ADD CONSTRAINT "advocate_change_request_requested_by_citizen_id_fkey" FOREIGN KEY ("requested_by_citizen_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."advocate_change_request"
    ADD CONSTRAINT "advocate_change_request_reviewed_by_admin_id_fkey" FOREIGN KEY ("reviewed_by_admin_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."advocate_district_mapping"
    ADD CONSTRAINT "advocate_district_mapping_advocate_id_fkey" FOREIGN KEY ("advocate_id") REFERENCES "public"."advocate_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."advocate_district_mapping"
    ADD CONSTRAINT "advocate_district_mapping_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "public"."district_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."advocate_master"
    ADD CONSTRAINT "advocate_master_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."application_document"
    ADD CONSTRAINT "application_document_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."legal_aid_application"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."application_document"
    ADD CONSTRAINT "application_document_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "public"."document_master"("id");



ALTER TABLE ONLY "public"."application_document"
    ADD CONSTRAINT "application_document_verified_by_fkey" FOREIGN KEY ("verified_by") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."application_forward_log"
    ADD CONSTRAINT "application_forward_log_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."legal_aid_application"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."application_forward_log"
    ADD CONSTRAINT "application_forward_log_forwarded_by_id_fkey" FOREIGN KEY ("forwarded_by_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."application_forward_log"
    ADD CONSTRAINT "application_forward_log_from_district_id_fkey" FOREIGN KEY ("from_district_id") REFERENCES "public"."district_master"("id");



ALTER TABLE ONLY "public"."application_forward_log"
    ADD CONSTRAINT "application_forward_log_to_district_id_fkey" FOREIGN KEY ("to_district_id") REFERENCES "public"."district_master"("id");



ALTER TABLE ONLY "public"."application_status_history"
    ADD CONSTRAINT "application_status_history_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."legal_aid_application"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."application_status_history"
    ADD CONSTRAINT "application_status_history_changed_by_id_fkey" FOREIGN KEY ("changed_by_id") REFERENCES "public"."profiles"("id");



ALTER TABLE ONLY "public"."case_type_document_map"
    ADD CONSTRAINT "case_type_document_map_case_type_id_fkey" FOREIGN KEY ("case_type_id") REFERENCES "public"."case_type_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."case_type_document_map"
    ADD CONSTRAINT "case_type_document_map_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "public"."document_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."district_master"
    ADD CONSTRAINT "district_master_state_id_fkey" FOREIGN KEY ("state_id") REFERENCES "public"."state_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_applicant_district_id_fkey" FOREIGN KEY ("applicant_district_id") REFERENCES "public"."district_master"("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_applicant_id_fkey" FOREIGN KEY ("applicant_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_assigned_advocate_id_fkey" FOREIGN KEY ("assigned_advocate_id") REFERENCES "public"."advocate_master"("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_case_type_id_fkey" FOREIGN KEY ("case_type_id") REFERENCES "public"."case_type_master"("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."legal_aid_category"("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_current_district_id_fkey" FOREIGN KEY ("current_district_id") REFERENCES "public"."district_master"("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_current_taluka_id_fkey" FOREIGN KEY ("current_taluka_id") REFERENCES "public"."taluka_master"("id");



ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_preferred_advocate_id_fkey" FOREIGN KEY ("preferred_advocate_id") REFERENCES "public"."advocate_master"("id");



ALTER TABLE ONLY "public"."legal_aid_category_document_map"
    ADD CONSTRAINT "legal_aid_category_document_map_category_id_fkey" FOREIGN KEY ("category_id") REFERENCES "public"."legal_aid_category"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."legal_aid_category_document_map"
    ADD CONSTRAINT "legal_aid_category_document_map_document_id_fkey" FOREIGN KEY ("document_id") REFERENCES "public"."document_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "public"."district_master"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."taluka_master"
    ADD CONSTRAINT "taluka_master_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "public"."district_master"("id") ON DELETE CASCADE;



CREATE POLICY "access_documents_linked_to_authorized_applications" ON "public"."application_document" FOR SELECT USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."legal_aid_application" "a"
  WHERE ("a"."id" = "application_document"."application_id")))));



CREATE POLICY "admin_delete_advocates" ON "public"."advocate_master" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "admin_delete_application_documents" ON "public"."application_document" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "admin_delete_profiles" ON "public"."profiles" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "admin_insert_advocates" ON "public"."advocate_master" FOR INSERT WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_insert_forward_logs" ON "public"."application_forward_log" FOR INSERT WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_insert_profiles" ON "public"."profiles" FOR INSERT WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_insert_status_history" ON "public"."application_status_history" FOR INSERT WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_admin_scope" ON "public"."admin_scope" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_advocate_change_requests" ON "public"."advocate_change_request" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_advocate_district_mapping" ON "public"."advocate_district_mapping" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_case_type_document_map" ON "public"."case_type_document_map" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_case_type_master" ON "public"."case_type_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_category_document_map" ON "public"."legal_aid_category_document_map" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_district_master" ON "public"."district_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_document_master" ON "public"."document_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_legal_aid_category" ON "public"."legal_aid_category" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_roles" ON "public"."roles" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_state_master" ON "public"."state_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_taluka_master" ON "public"."taluka_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_read_forward_logs" ON "public"."application_forward_log" FOR SELECT USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."legal_aid_application" "a"
  WHERE ("a"."id" = "application_forward_log"."application_id")))));



CREATE POLICY "admin_read_status_history" ON "public"."application_status_history" FOR SELECT USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."legal_aid_application" "a"
  WHERE ("a"."id" = "application_status_history"."application_id")))));



ALTER TABLE "public"."admin_scope" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "admin_update_application_documents" ON "public"."application_document" FOR UPDATE USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



ALTER TABLE "public"."advocate_case_action_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."advocate_change_request" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."advocate_district_mapping" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."advocate_master" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "advocates_insert_case_action_logs" ON "public"."advocate_case_action_log" FOR INSERT WITH CHECK (("public"."is_admin"() OR ("advocate_id" IN ( SELECT "a"."id"
   FROM "public"."advocate_master" "a"
  WHERE ("a"."user_id" = "auth"."uid"())))));



CREATE POLICY "advocates_read_case_action_logs" ON "public"."advocate_case_action_log" FOR SELECT USING (("public"."is_admin"() OR ("advocate_id" IN ( SELECT "a"."id"
   FROM "public"."advocate_master" "a"
  WHERE ("a"."user_id" = "auth"."uid"())))));



CREATE POLICY "advocates_update_own_profile" ON "public"."advocate_master" FOR UPDATE USING ((("user_id" = "auth"."uid"()) OR "public"."is_admin"())) WITH CHECK ((("user_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "advocates_view_assigned_cases" ON "public"."legal_aid_application" FOR SELECT USING (("assigned_advocate_id" IN ( SELECT "a"."id"
   FROM "public"."advocate_master" "a"
  WHERE ("a"."user_id" = "auth"."uid"()))));



CREATE POLICY "anyone_submit_applications" ON "public"."legal_aid_application" FOR INSERT WITH CHECK ((("applicant_id" IS NULL) OR ("applicant_id" = "auth"."uid"()) OR "public"."is_admin"()));



ALTER TABLE "public"."application_document" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."application_forward_log" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."application_status_history" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."case_type_document_map" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."case_type_master" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "citizens_create_advocate_change_requests" ON "public"."advocate_change_request" FOR INSERT WITH CHECK (("requested_by_citizen_id" = "auth"."uid"()));



CREATE POLICY "citizens_manage_own_advocate_change_requests" ON "public"."advocate_change_request" FOR SELECT USING ((("requested_by_citizen_id" = "auth"."uid"()) OR "public"."is_admin"()));



CREATE POLICY "citizens_view_own_cases" ON "public"."legal_aid_application" FOR SELECT USING ((("applicant_id" = "auth"."uid"()) OR ("applicant_phone_number" = ( SELECT "p"."phone_number"
   FROM "public"."profiles" "p"
  WHERE ("p"."id" = "auth"."uid"())))));



CREATE POLICY "citizens_withdraw_own_application" ON "public"."legal_aid_application" FOR UPDATE USING (("applicant_id" = "auth"."uid"())) WITH CHECK ((("applicant_id" = "auth"."uid"()) AND ("is_withdrawn_by_citizen" = true) AND ("status" = 'WITHDRAWN'::"text")));



CREATE POLICY "district_admin_manage_district_applications" ON "public"."legal_aid_application" USING ("public"."is_district_admin"("current_district_id")) WITH CHECK ("public"."is_district_admin"("current_district_id"));



ALTER TABLE "public"."district_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."document_master" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "insert_documents_for_authorized_applications" ON "public"."application_document" FOR INSERT WITH CHECK (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."legal_aid_application" "a"
  WHERE ("a"."id" = "application_document"."application_id")))));



ALTER TABLE "public"."legal_aid_application" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_aid_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_aid_category_document_map" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "public_read_active_roles" ON "public"."roles" FOR SELECT USING (("is_active" = true));



CREATE POLICY "public_read_advocate_district_mapping" ON "public"."advocate_district_mapping" FOR SELECT USING (true);



CREATE POLICY "public_read_case_type_document_map" ON "public"."case_type_document_map" FOR SELECT USING (true);



CREATE POLICY "public_read_case_type_master" ON "public"."case_type_master" FOR SELECT USING (true);



CREATE POLICY "public_read_category_document_map" ON "public"."legal_aid_category_document_map" FOR SELECT USING (true);



CREATE POLICY "public_read_district_master" ON "public"."district_master" FOR SELECT USING (true);



CREATE POLICY "public_read_document_master" ON "public"."document_master" FOR SELECT USING (true);



CREATE POLICY "public_read_legal_aid_category" ON "public"."legal_aid_category" FOR SELECT USING (true);



CREATE POLICY "public_read_state_master" ON "public"."state_master" FOR SELECT USING (true);



CREATE POLICY "public_read_taluka_master" ON "public"."taluka_master" FOR SELECT USING (true);



CREATE POLICY "public_view_active_advocates" ON "public"."advocate_master" FOR SELECT USING ((("is_active" = true) OR "public"."is_admin"() OR ("user_id" = "auth"."uid"())));



ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "state_and_super_admin_manage_applications" ON "public"."legal_aid_application" USING (("public"."is_admin"() OR ("public"."current_profile_user_type"() = ANY (ARRAY['STATE_ADMIN'::"public"."user_type_enum", 'SUPER_ADMIN'::"public"."user_type_enum"])))) WITH CHECK (("public"."is_admin"() OR ("public"."current_profile_user_type"() = ANY (ARRAY['STATE_ADMIN'::"public"."user_type_enum", 'SUPER_ADMIN'::"public"."user_type_enum"]))));



ALTER TABLE "public"."state_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."taluka_master" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "users_update_own_profile_without_role_escalation" ON "public"."profiles" FOR UPDATE USING ((("auth"."uid"() = "id") OR "public"."is_admin"())) WITH CHECK (("public"."is_admin"() OR (("auth"."uid"() = "id") AND ("user_type" = "public"."current_profile_user_type"()) AND ("status" = "public"."current_profile_status"()))));



CREATE POLICY "users_view_own_profile" ON "public"."profiles" FOR SELECT USING ((("auth"."uid"() = "id") OR "public"."is_admin"() OR ("public"."current_profile_user_type"() = ANY (ARRAY['DISTRICT_ADMIN'::"public"."user_type_enum", 'STATE_ADMIN'::"public"."user_type_enum", 'SUPER_ADMIN'::"public"."user_type_enum", 'ADMIN'::"public"."user_type_enum"]))));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";


GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."current_profile_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_profile_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_profile_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."current_profile_user_type"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_profile_user_type"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_profile_user_type"() TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_tracking_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_tracking_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_tracking_number"() TO "service_role";



GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";



GRANT ALL ON FUNCTION "public"."get_my_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_new_user_signup"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_new_user_signup"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_new_user_signup"() TO "service_role";



GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "anon";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."handle_updated_at"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_district_admin"("dist_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_district_admin"("dist_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_district_admin"("dist_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_state_admin"("p_state_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_state_admin"("p_state_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_state_admin"("p_state_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."link_guest_applications_on_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."link_guest_applications_on_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."link_guest_applications_on_profile"() TO "service_role";



GRANT ALL ON TABLE "public"."legal_aid_application" TO "anon";
GRANT ALL ON TABLE "public"."legal_aid_application" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_aid_application" TO "service_role";



GRANT ALL ON FUNCTION "public"."track_application"("p_tracking_number" "text", "p_phone_number" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."track_application"("p_tracking_number" "text", "p_phone_number" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."track_application"("p_tracking_number" "text", "p_phone_number" "text") TO "service_role";


















GRANT ALL ON TABLE "public"."admin_scope" TO "anon";
GRANT ALL ON TABLE "public"."admin_scope" TO "authenticated";
GRANT ALL ON TABLE "public"."admin_scope" TO "service_role";



GRANT ALL ON TABLE "public"."advocate_case_action_log" TO "anon";
GRANT ALL ON TABLE "public"."advocate_case_action_log" TO "authenticated";
GRANT ALL ON TABLE "public"."advocate_case_action_log" TO "service_role";



GRANT ALL ON TABLE "public"."advocate_change_request" TO "anon";
GRANT ALL ON TABLE "public"."advocate_change_request" TO "authenticated";
GRANT ALL ON TABLE "public"."advocate_change_request" TO "service_role";



GRANT ALL ON TABLE "public"."advocate_district_mapping" TO "anon";
GRANT ALL ON TABLE "public"."advocate_district_mapping" TO "authenticated";
GRANT ALL ON TABLE "public"."advocate_district_mapping" TO "service_role";



GRANT ALL ON TABLE "public"."advocate_master" TO "anon";
GRANT ALL ON TABLE "public"."advocate_master" TO "authenticated";
GRANT ALL ON TABLE "public"."advocate_master" TO "service_role";



GRANT ALL ON TABLE "public"."application_document" TO "anon";
GRANT ALL ON TABLE "public"."application_document" TO "authenticated";
GRANT ALL ON TABLE "public"."application_document" TO "service_role";



GRANT ALL ON TABLE "public"."application_forward_log" TO "anon";
GRANT ALL ON TABLE "public"."application_forward_log" TO "authenticated";
GRANT ALL ON TABLE "public"."application_forward_log" TO "service_role";



GRANT ALL ON TABLE "public"."application_status_history" TO "anon";
GRANT ALL ON TABLE "public"."application_status_history" TO "authenticated";
GRANT ALL ON TABLE "public"."application_status_history" TO "service_role";



GRANT ALL ON SEQUENCE "public"."application_tracking_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."application_tracking_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."application_tracking_seq" TO "service_role";



GRANT ALL ON TABLE "public"."case_type_document_map" TO "anon";
GRANT ALL ON TABLE "public"."case_type_document_map" TO "authenticated";
GRANT ALL ON TABLE "public"."case_type_document_map" TO "service_role";



GRANT ALL ON TABLE "public"."case_type_master" TO "anon";
GRANT ALL ON TABLE "public"."case_type_master" TO "authenticated";
GRANT ALL ON TABLE "public"."case_type_master" TO "service_role";



GRANT ALL ON TABLE "public"."district_master" TO "anon";
GRANT ALL ON TABLE "public"."district_master" TO "authenticated";
GRANT ALL ON TABLE "public"."district_master" TO "service_role";



GRANT ALL ON TABLE "public"."document_master" TO "anon";
GRANT ALL ON TABLE "public"."document_master" TO "authenticated";
GRANT ALL ON TABLE "public"."document_master" TO "service_role";



GRANT ALL ON TABLE "public"."legal_aid_category" TO "anon";
GRANT ALL ON TABLE "public"."legal_aid_category" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_aid_category" TO "service_role";



GRANT ALL ON TABLE "public"."legal_aid_category_document_map" TO "anon";
GRANT ALL ON TABLE "public"."legal_aid_category_document_map" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_aid_category_document_map" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."state_master" TO "anon";
GRANT ALL ON TABLE "public"."state_master" TO "authenticated";
GRANT ALL ON TABLE "public"."state_master" TO "service_role";



GRANT ALL ON TABLE "public"."taluka_master" TO "anon";
GRANT ALL ON TABLE "public"."taluka_master" TO "authenticated";
GRANT ALL ON TABLE "public"."taluka_master" TO "service_role";









ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS TO "service_role";






ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES TO "service_role";































