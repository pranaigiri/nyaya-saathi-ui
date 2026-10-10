


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


CREATE EXTENSION IF NOT EXISTS "pg_net" WITH SCHEMA "extensions";






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


CREATE OR REPLACE FUNCTION "public"."application_exists_for_link"("app_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."legal_aid_application"
        WHERE "id" = app_id
    );
$$;


ALTER FUNCTION "public"."application_exists_for_link"("app_id" "uuid") OWNER TO "postgres";


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


CREATE OR REPLACE FUNCTION "public"."enforce_master_code_immutable"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    IF COALESCE(to_jsonb(NEW) ->> TG_ARGV[0], '') IS DISTINCT FROM COALESCE(to_jsonb(OLD) ->> TG_ARGV[0], '') THEN
        RAISE EXCEPTION '% of %.% is immutable (locked value: %)',
            TG_ARGV[0], TG_TABLE_SCHEMA, TG_TABLE_NAME, to_jsonb(OLD) ->> TG_ARGV[0];
    END IF;
    RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."enforce_master_code_immutable"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."fn_handle_application_status_change"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $
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

  -- 1. Always record transition in application_status_history
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
$;


ALTER FUNCTION "public"."fn_handle_application_status_change"() OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";


CREATE TABLE IF NOT EXISTS "public"."legal_aid_application" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "tracking_number" "text" NOT NULL,
    "applicant_id" "uuid",
    "category_id" "uuid",
    "applicant_full_name" "text",
    "applicant_phone_number" "text" NOT NULL,
    "applicant_dob" "date",
    "applicant_gender" "text",
    "village_or_town" "text",
    "applicant_district_id" "uuid",
    "case_type_id" "uuid",
    "current_district_id" "uuid",
    "current_taluka_id" "uuid",
    "case_details" "text",
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
    "application_mode" "text" DEFAULT 'FULL'::"text" NOT NULL,
    "callback_status" "text" DEFAULT 'NOT_REQUIRED'::"text" NOT NULL,
    "callback_attempts" integer DEFAULT 0 NOT NULL,
    "last_callback_at" timestamp with time zone,
    "details_completed_at" timestamp with time zone,
    "details_completed_by" "uuid",
    CONSTRAINT "legal_aid_application_advocate_acceptance_status_check" CHECK (("advocate_acceptance_status" = ANY (ARRAY['NONE'::"text", 'PENDING'::"text", 'ACCEPTED'::"text", 'REJECTED'::"text"]))),
    CONSTRAINT "legal_aid_application_status_check" CHECK (("status" = ANY (ARRAY['SUBMITTED'::"text", 'UNDER_REVIEW'::"text", 'ADVOCATE_ASSIGNED'::"text", 'RESOLVED'::"text", 'REJECTED'::"text", 'WITHDRAWN'::"text"]))),
    CONSTRAINT "legal_aid_application_application_mode_check" CHECK (("application_mode" = ANY (ARRAY['FULL'::"text", 'QUICK_CALLBACK'::"text"]))),
    CONSTRAINT "legal_aid_application_callback_status_check" CHECK (("callback_status" = ANY (ARRAY['NOT_REQUIRED'::"text", 'PENDING_CALL'::"text", 'CALL_ATTEMPTED'::"text", 'UNREACHABLE'::"text", 'DETAILS_COLLECTED'::"text"]))),
    CONSTRAINT "chk_application_mode_completeness" CHECK ((("application_mode" = 'QUICK_CALLBACK'::"text") OR (("category_id" IS NOT NULL) AND ("applicant_full_name" IS NOT NULL) AND ("applicant_dob" IS NOT NULL) AND ("applicant_gender" IS NOT NULL) AND ("applicant_district_id" IS NOT NULL) AND ("case_type_id" IS NOT NULL) AND ("current_district_id" IS NOT NULL) AND ("case_details" IS NOT NULL))))
);


ALTER TABLE "public"."legal_aid_application" OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."forward_application"("p_application_id" "uuid", "p_target_district_id" "uuid") RETURNS "public"."legal_aid_application"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
DECLARE
  v_app      public.legal_aid_application;
  v_updated  public.legal_aid_application;
BEGIN
  -- 1) The caller must be a geo/global admin at all.
  IF NOT public.is_geo_admin() THEN
    RAISE EXCEPTION 'Permission denied: only (geo) admins can forward applications';
  END IF;

  -- 2) The application must exist (load current state for authz + audit).
  SELECT * INTO v_app
  FROM public.legal_aid_application
  WHERE id = p_application_id;
  IF NOT FOUND THEN
    RAISE EXCEPTION 'Application not found';
  END IF;

  -- 3) The caller must be authorized to move it:
  --      * geo-admin holding the application in their district, or
  --      * state/super admin (global access).
  IF NOT (public.is_admin() OR public.current_profile_user_type() IN ('STATE_ADMIN', 'SUPER_ADMIN')) THEN
    IF NOT EXISTS (
      SELECT 1
      FROM public.admin_scope s
      WHERE s.user_id = auth.uid()
        AND s.scope_level = 'DISTRICT'
        AND s.district_id = v_app.current_district_id
    ) THEN
      RAISE EXCEPTION 'Permission denied: application is not currently in your district';
    END IF;
  END IF;

  -- 4) Move it (target district must exist - FK will enforce). The
  --    BEFORE UPDATE trigger writes the application_forward_log audit
  --    row (single source of truth - no duplicate logging).
  UPDATE public.legal_aid_application
     SET current_district_id = p_target_district_id
   WHERE id = p_application_id
  RETURNING * INTO v_updated;

  RETURN v_updated;
END;
$$;


ALTER FUNCTION "public"."forward_application"("p_application_id" "uuid", "p_target_district_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."generate_tracking_number"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $
DECLARE
    dist_code TEXT;
    year_str TEXT;
    seq_val INT;
    target_district uuid;
BEGIN
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
$;


ALTER FUNCTION "public"."generate_tracking_number"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."get_my_permission_codes"() RETURNS TABLE("permission_code" "text")
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
WITH me AS (SELECT p.user_type, p.status FROM public.profiles p WHERE p.id = auth.uid() LIMIT 1),
my_scopes AS (SELECT s.scope_level, s.is_global_super_admin FROM public.admin_scope s WHERE s.user_id = auth.uid()),
base_codes AS (SELECT v.code FROM (VALUES ('dashboard.view'),('applications.view')) v(code) WHERE EXISTS (SELECT 1 FROM me WHERE status = 'ACTIVE')),
type_codes AS (
  SELECT v.code FROM (VALUES ('users.view'),('users.create'),('users.update'),('users.delete'),('roles.view'),('roles.update'),('admin_scopes.view'),('admin_scopes.manage'),('advocates.view'),('advocates.create'),('advocates.update'),('advocates.delete'),('applications.create'),('applications.update'),('applications.delete'),('master_data.view'),('master_data.create'),('master_data.update'),('master_data.delete')) v(code)
  WHERE EXISTS (SELECT 1 FROM me WHERE status = 'ACTIVE' AND (user_type IN ('ADMIN','SUPER_ADMIN') OR EXISTS (SELECT 1 FROM my_scopes WHERE is_global_super_admin)))
  UNION ALL
  SELECT v.code FROM (VALUES ('users.view'),('users.update'),('advocates.view'),('advocates.create'),('advocates.update'),('applications.create'),('applications.update')) v(code)
  WHERE EXISTS (SELECT 1 FROM me WHERE status = 'ACTIVE' AND (user_type = 'STATE_ADMIN' OR EXISTS (SELECT 1 FROM my_scopes WHERE scope_level = 'STATE')))
  UNION ALL
  SELECT v.code FROM (VALUES ('advocates.view'),('advocates.create'),('advocates.update'),('applications.create'),('applications.update')) v(code)
  WHERE EXISTS (SELECT 1 FROM me WHERE status = 'ACTIVE' AND (user_type = 'DISTRICT_ADMIN' OR EXISTS (SELECT 1 FROM my_scopes WHERE scope_level = 'DISTRICT')))
  UNION ALL
  SELECT v.code FROM (VALUES ('advocates.view'),('applications.update')) v(code)
  WHERE EXISTS (SELECT 1 FROM me WHERE status = 'ACTIVE' AND user_type = 'ADVOCATE')
  UNION ALL
  SELECT v.code FROM (VALUES ('applications.create'),('applications.update'),('advocates.view')) v(code)
  WHERE EXISTS (SELECT 1 FROM me WHERE status = 'ACTIVE' AND user_type = 'STAFF')
),
role_codes AS (SELECT rp.permission_code FROM public.user_roles ur JOIN public.roles r ON r.id = ur.role_id AND r.is_active JOIN public.role_permissions rp ON rp.role_id = r.id WHERE ur.user_id = auth.uid())
SELECT DISTINCT permission_code FROM (SELECT code AS permission_code FROM base_codes UNION SELECT code FROM type_codes UNION SELECT permission_code FROM role_codes) all_codes;
$$;


ALTER FUNCTION "public"."get_my_permission_codes"() OWNER TO "postgres";


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
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "fcm_token" "text"
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


CREATE OR REPLACE FUNCTION "public"."is_district_forward_party"("p_application_id" "uuid") RETURNS boolean
    LANGUAGE "sql" STABLE SECURITY DEFINER
    SET "search_path" TO ''
    AS $$
    SELECT EXISTS (
        SELECT 1
        FROM public.application_forward_log f
        JOIN public.profiles p
          ON p.id = auth.uid()
         AND p.status = 'ACTIVE'
        JOIN public.admin_scope s
          ON s.user_id = p.id
        WHERE f.application_id = p_application_id
          AND s.district_id IS NOT NULL
          AND s.district_id IN (f.from_district_id, f.to_district_id)
    );
$$;


ALTER FUNCTION "public"."is_district_forward_party"("p_application_id" "uuid") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."is_geo_admin"() RETURNS boolean
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
                p.user_type IN ('ADMIN', 'SUPER_ADMIN', 'STATE_ADMIN', 'DISTRICT_ADMIN')
                OR s.is_global_super_admin = TRUE
                OR s.scope_level IN ('DISTRICT', 'STATE')
                OR s.district_id IS NOT NULL
                OR s.state_id IS NOT NULL
          )
    );
$$;


ALTER FUNCTION "public"."is_geo_admin"() OWNER TO "postgres";


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
    SET "search_path" TO 'public', 'pg_temp'
    AS $
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
$;


ALTER FUNCTION "public"."link_guest_applications_on_profile"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."log_application_district_transfer"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO ''
    AS $$
BEGIN
  IF auth.uid() IS NOT NULL THEN
    INSERT INTO public.application_forward_log
      (application_id, from_district_id, to_district_id, forwarded_by_id, reason)
    VALUES
      (NEW.id, OLD.current_district_id, NEW.current_district_id, auth.uid(), 'District transfer');
  END IF;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."log_application_district_transfer"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."submit_legal_aid_application"("p_application" "jsonb") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
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


ALTER FUNCTION "public"."submit_legal_aid_application"("p_application" "jsonb") OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."sync_user_type_from_admin_scope"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
DECLARE v_new_type user_type_enum;
BEGIN
  IF NEW.is_global_super_admin THEN v_new_type := 'SUPER_ADMIN';
  ELSIF NEW.scope_level = 'STATE' OR NEW.state_id IS NOT NULL THEN v_new_type := 'STATE_ADMIN';
  ELSIF NEW.scope_level = 'DISTRICT' OR NEW.district_id IS NOT NULL THEN v_new_type := 'DISTRICT_ADMIN';
  ELSE v_new_type := 'ADMIN'; END IF;
  UPDATE public.profiles SET user_type = v_new_type WHERE id = NEW.user_id AND user_type IN ('ADMIN','SUPER_ADMIN','STATE_ADMIN','DISTRICT_ADMIN') AND user_type <> v_new_type;
  RETURN NEW;
END;
$$;


ALTER FUNCTION "public"."sync_user_type_from_admin_scope"() OWNER TO "postgres";


CREATE OR REPLACE FUNCTION "public"."track_application"("p_tracking_number" "text", "p_phone_number" "text") RETURNS "jsonb"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $
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
$;


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
    "changed_by_id" "uuid",
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
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "case_type_description" "text"
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


CREATE TABLE IF NOT EXISTS "public"."modules" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "code" "text" NOT NULL,
    "permission_code" "text" NOT NULL,
    "label" "text" NOT NULL,
    "route" "text",
    "icon" "text",
    "section" "text" DEFAULT 'ADMINISTRATION'::"text" NOT NULL,
    "group_label" "text",
    "display_order" integer DEFAULT 0 NOT NULL,
    "is_active" boolean DEFAULT true NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "updated_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "modules_section_check" CHECK (("section" = ANY (ARRAY['HOME'::"text", 'ADMINISTRATION'::"text"])))
);


ALTER TABLE "public"."modules" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."notifications" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "user_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "body" "text" NOT NULL,
    "title" "text" DEFAULT 'Application Status Updated'::"text" NOT NULL,
    "application_id" "uuid",
    "type" "text" DEFAULT 'application_status_update'::"text" NOT NULL,
    "is_read" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."notifications" OWNER TO "postgres";


CREATE TABLE IF NOT EXISTS "public"."role_permissions" (
    "role_id" "uuid" NOT NULL,
    "permission_code" "text" NOT NULL,
    CONSTRAINT "role_permissions_code_format_check" CHECK (("permission_code" ~ '^[a-z_]+[.][a-z_]+$'::"text"))
);


ALTER TABLE "public"."role_permissions" OWNER TO "postgres";


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


CREATE TABLE IF NOT EXISTS "public"."user_roles" (
    "user_id" "uuid" NOT NULL,
    "role_id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "assigned_by" "uuid"
);


ALTER TABLE "public"."user_roles" OWNER TO "postgres";


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



ALTER TABLE ONLY "public"."modules"
    ADD CONSTRAINT "modules_code_key" UNIQUE ("code");



ALTER TABLE ONLY "public"."modules"
    ADD CONSTRAINT "modules_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_email_key" UNIQUE ("email");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_phone_number_key" UNIQUE ("phone_number");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_pkey" PRIMARY KEY ("role_id", "permission_code");



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



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_pkey" PRIMARY KEY ("user_id", "role_id");



CREATE INDEX "application_forward_log_application_id_idx" ON "public"."application_forward_log" USING "btree" ("application_id", "forwarded_at");



CREATE INDEX "idx_modules_permission_code" ON "public"."modules" USING "btree" ("permission_code");



CREATE INDEX "idx_notifications_application_id" ON "public"."notifications" USING "btree" ("application_id");



CREATE INDEX "idx_notifications_user_created" ON "public"."notifications" USING "btree" ("user_id", "created_at" DESC);



CREATE INDEX "idx_notifications_user_unread" ON "public"."notifications" USING "btree" ("user_id", "is_read");



CREATE INDEX "idx_role_permissions_code" ON "public"."role_permissions" USING "btree" ("permission_code");



CREATE INDEX "idx_status_history_application" ON "public"."application_status_history" USING "btree" ("application_id", "created_at" DESC);



CREATE INDEX "idx_user_roles_role_id" ON "public"."user_roles" USING "btree" ("role_id");



CREATE INDEX "user_roles_role_id_idx" ON "public"."user_roles" USING "btree" ("role_id");



CREATE OR REPLACE TRIGGER "case_type_master_code_immutable" BEFORE UPDATE ON "public"."case_type_master" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_master_code_immutable"('case_type_code');



CREATE OR REPLACE TRIGGER "district_master_code_immutable" BEFORE UPDATE ON "public"."district_master" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_master_code_immutable"('district_code');



CREATE OR REPLACE TRIGGER "document_master_code_immutable" BEFORE UPDATE ON "public"."document_master" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_master_code_immutable"('document_code');



CREATE OR REPLACE TRIGGER "legal_aid_category_code_immutable" BEFORE UPDATE ON "public"."legal_aid_category" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_master_code_immutable"('category_code');



CREATE OR REPLACE TRIGGER "send_notification_webhook" AFTER INSERT ON "public"."notifications" FOR EACH ROW EXECUTE FUNCTION "supabase_functions"."http_request"('https://rzcubveosldxzcbvzidu.supabase.co/functions/v1/send-fcm-notification', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6Y3VidmVvc2xkeHpjYnZ6aWR1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjUxMzg2NSwiZXhwIjoyMTAyMDg5ODY1fQ.dWZ03X2tKGdRkRWNc2ksXtxu6JHmQ17MPjRTfu2aXJk"}', '{}', '1000');



CREATE OR REPLACE TRIGGER "set_advocate_updated_at" BEFORE UPDATE ON "public"."advocate_master" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_legal_aid_application_updated_at" BEFORE UPDATE ON "public"."legal_aid_application" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_modules_updated_at" BEFORE UPDATE ON "public"."modules" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_profiles_updated_at" BEFORE UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "set_roles_updated_at" BEFORE UPDATE ON "public"."roles" FOR EACH ROW EXECUTE FUNCTION "public"."handle_updated_at"();



CREATE OR REPLACE TRIGGER "state_master_code_immutable" BEFORE UPDATE ON "public"."state_master" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_master_code_immutable"('state_code');



CREATE OR REPLACE TRIGGER "taluka_master_code_immutable" BEFORE UPDATE ON "public"."taluka_master" FOR EACH ROW EXECUTE FUNCTION "public"."enforce_master_code_immutable"('taluka_code');



CREATE OR REPLACE TRIGGER "trg_application_district_transfer" BEFORE UPDATE OF "current_district_id" ON "public"."legal_aid_application" FOR EACH ROW WHEN (("old"."current_district_id" IS DISTINCT FROM "new"."current_district_id")) EXECUTE FUNCTION "public"."log_application_district_transfer"();



CREATE OR REPLACE TRIGGER "trg_application_status_notification_insert" AFTER INSERT ON "public"."legal_aid_application" FOR EACH ROW WHEN (("new"."status" IS NOT NULL)) EXECUTE FUNCTION "public"."fn_handle_application_status_change"();



CREATE OR REPLACE TRIGGER "trg_application_status_notification_update" AFTER UPDATE OF "status" ON "public"."legal_aid_application" FOR EACH ROW WHEN (("old"."status" IS DISTINCT FROM "new"."status")) EXECUTE FUNCTION "public"."fn_handle_application_status_change"();



CREATE OR REPLACE TRIGGER "trg_sync_user_type_from_admin_scope" AFTER INSERT OR UPDATE OF "is_global_super_admin", "state_id", "district_id", "scope_level" ON "public"."admin_scope" FOR EACH ROW EXECUTE FUNCTION "public"."sync_user_type_from_admin_scope"();



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



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."legal_aid_application"("id");



ALTER TABLE ONLY "public"."notifications"
    ADD CONSTRAINT "notifications_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "auth"."users"("id");



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "public"."district_master"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."role_permissions"
    ADD CONSTRAINT "role_permissions_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."taluka_master"
    ADD CONSTRAINT "taluka_master_district_id_fkey" FOREIGN KEY ("district_id") REFERENCES "public"."district_master"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_assigned_by_fkey" FOREIGN KEY ("assigned_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_role_id_fkey" FOREIGN KEY ("role_id") REFERENCES "public"."roles"("id") ON DELETE CASCADE;



ALTER TABLE ONLY "public"."user_roles"
    ADD CONSTRAINT "user_roles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;



CREATE POLICY "Citizens can update own notifications" ON "public"."notifications" FOR UPDATE TO "authenticated" USING (("auth"."uid"() = "user_id")) WITH CHECK (("auth"."uid"() = "user_id"));



CREATE POLICY "Citizens can view own notifications" ON "public"."notifications" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "access_documents_linked_to_authorized_applications" ON "public"."application_document" FOR SELECT USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."legal_aid_application" "a"
  WHERE ("a"."id" = "application_document"."application_id")))));



CREATE POLICY "admin_delete_advocates" ON "public"."advocate_master" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "admin_delete_application_documents" ON "public"."application_document" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "admin_delete_profiles" ON "public"."profiles" FOR DELETE USING ("public"."is_admin"());



CREATE POLICY "admin_insert_advocates" ON "public"."advocate_master" FOR INSERT WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_insert_forward_logs" ON "public"."application_forward_log" FOR INSERT WITH CHECK ("public"."is_geo_admin"());



CREATE POLICY "admin_insert_profiles" ON "public"."profiles" FOR INSERT WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_insert_status_history" ON "public"."application_status_history" FOR INSERT WITH CHECK ("public"."is_geo_admin"());



CREATE POLICY "admin_manage_admin_scope" ON "public"."admin_scope" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_advocate_change_requests" ON "public"."advocate_change_request" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_advocate_district_mapping" ON "public"."advocate_district_mapping" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_case_type_document_map" ON "public"."case_type_document_map" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_case_type_master" ON "public"."case_type_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_category_document_map" ON "public"."legal_aid_category_document_map" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_district_master" ON "public"."district_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_document_master" ON "public"."document_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_legal_aid_category" ON "public"."legal_aid_category" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_modules" ON "public"."modules" TO "authenticated" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_role_permissions" ON "public"."role_permissions" TO "authenticated" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_roles" ON "public"."roles" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_state_master" ON "public"."state_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_taluka_master" ON "public"."taluka_master" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_manage_user_roles" ON "public"."user_roles" TO "authenticated" USING ("public"."is_admin"()) WITH CHECK ("public"."is_admin"());



CREATE POLICY "admin_read_forward_logs" ON "public"."application_forward_log" FOR SELECT USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."legal_aid_application" "a"
  WHERE ("a"."id" = "application_forward_log"."application_id"))) OR ("public"."is_geo_admin"() AND (EXISTS ( SELECT 1
   FROM "public"."admin_scope" "s"
  WHERE (("s"."user_id" = "auth"."uid"()) AND ("s"."district_id" = "application_forward_log"."from_district_id")))))));



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



CREATE POLICY "anyone_submit_applications" ON "public"."legal_aid_application" FOR INSERT TO "authenticated" WITH CHECK ((("applicant_id" IS NULL) OR ("applicant_id" = "auth"."uid"()) OR "public"."is_admin"()));



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



CREATE POLICY "district_admin_delete_district_applications" ON "public"."legal_aid_application" FOR DELETE USING ("public"."is_district_admin"("current_district_id"));



CREATE POLICY "district_admin_forward_district_applications" ON "public"."legal_aid_application" FOR UPDATE USING ("public"."is_district_admin"("current_district_id")) WITH CHECK ("public"."is_geo_admin"());



CREATE POLICY "district_admin_insert_district_applications" ON "public"."legal_aid_application" FOR INSERT WITH CHECK ("public"."is_district_admin"("current_district_id"));



CREATE POLICY "district_admin_view_district_applications" ON "public"."legal_aid_application" FOR SELECT USING (("public"."is_district_admin"("current_district_id") OR "public"."is_district_admin"("applicant_district_id") OR "public"."is_district_forward_party"("id")));



ALTER TABLE "public"."district_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."document_master" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "insert_documents_for_authorized_applications" ON "public"."application_document" FOR INSERT TO "authenticated", "anon" WITH CHECK (("public"."is_admin"() OR "public"."application_exists_for_link"("application_id")));



ALTER TABLE "public"."legal_aid_application" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_aid_category" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."legal_aid_category_document_map" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."modules" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;


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



CREATE POLICY "read_visible_modules" ON "public"."modules" FOR SELECT TO "authenticated" USING ((("is_active" = true) OR "public"."is_admin"()));



CREATE POLICY "read_visible_role_permissions" ON "public"."role_permissions" FOR SELECT TO "authenticated" USING (("public"."is_admin"() OR (EXISTS ( SELECT 1
   FROM "public"."roles" "r"
  WHERE (("r"."id" = "role_permissions"."role_id") AND ("r"."is_active" = true))))));



ALTER TABLE "public"."role_permissions" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."roles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "state_and_super_admin_manage_applications" ON "public"."legal_aid_application" USING (("public"."is_admin"() OR ("public"."current_profile_user_type"() = ANY (ARRAY['STATE_ADMIN'::"public"."user_type_enum", 'SUPER_ADMIN'::"public"."user_type_enum"])))) WITH CHECK (("public"."is_admin"() OR ("public"."current_profile_user_type"() = ANY (ARRAY['STATE_ADMIN'::"public"."user_type_enum", 'SUPER_ADMIN'::"public"."user_type_enum"]))));



ALTER TABLE "public"."state_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."taluka_master" ENABLE ROW LEVEL SECURITY;


ALTER TABLE "public"."user_roles" ENABLE ROW LEVEL SECURITY;


CREATE POLICY "user_roles_self_read" ON "public"."user_roles" FOR SELECT TO "authenticated" USING (("user_id" = "auth"."uid"()));



CREATE POLICY "users_read_own_admin_scope" ON "public"."admin_scope" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "user_id"));



CREATE POLICY "users_read_own_roles" ON "public"."user_roles" FOR SELECT TO "authenticated" USING ((("auth"."uid"() = "user_id") OR "public"."is_admin"()));



CREATE POLICY "users_update_own_profile_without_role_escalation" ON "public"."profiles" FOR UPDATE USING ((("auth"."uid"() = "id") OR "public"."is_admin"())) WITH CHECK (("public"."is_admin"() OR (("auth"."uid"() = "id") AND ("user_type" = "public"."current_profile_user_type"()) AND ("status" = "public"."current_profile_status"()))));



CREATE POLICY "users_view_own_profile" ON "public"."profiles" FOR SELECT USING ((("auth"."uid"() = "id") OR "public"."is_admin"() OR ("public"."current_profile_user_type"() = ANY (ARRAY['DISTRICT_ADMIN'::"public"."user_type_enum", 'STATE_ADMIN'::"public"."user_type_enum", 'SUPER_ADMIN'::"public"."user_type_enum", 'ADMIN'::"public"."user_type_enum"]))));





ALTER PUBLICATION "supabase_realtime" OWNER TO "postgres";






ALTER PUBLICATION "supabase_realtime" ADD TABLE ONLY "public"."legal_aid_application";






GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";






















































































































































GRANT ALL ON FUNCTION "public"."application_exists_for_link"("app_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."application_exists_for_link"("app_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."application_exists_for_link"("app_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."current_profile_status"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_profile_status"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_profile_status"() TO "service_role";



GRANT ALL ON FUNCTION "public"."current_profile_user_type"() TO "anon";
GRANT ALL ON FUNCTION "public"."current_profile_user_type"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."current_profile_user_type"() TO "service_role";



GRANT ALL ON FUNCTION "public"."enforce_master_code_immutable"() TO "anon";
GRANT ALL ON FUNCTION "public"."enforce_master_code_immutable"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."enforce_master_code_immutable"() TO "service_role";



GRANT ALL ON FUNCTION "public"."fn_handle_application_status_change"() TO "anon";
GRANT ALL ON FUNCTION "public"."fn_handle_application_status_change"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."fn_handle_application_status_change"() TO "service_role";



GRANT ALL ON TABLE "public"."legal_aid_application" TO "anon";
GRANT ALL ON TABLE "public"."legal_aid_application" TO "authenticated";
GRANT ALL ON TABLE "public"."legal_aid_application" TO "service_role";



GRANT ALL ON FUNCTION "public"."forward_application"("p_application_id" "uuid", "p_target_district_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."forward_application"("p_application_id" "uuid", "p_target_district_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."forward_application"("p_application_id" "uuid", "p_target_district_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."generate_tracking_number"() TO "anon";
GRANT ALL ON FUNCTION "public"."generate_tracking_number"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."generate_tracking_number"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."get_my_permission_codes"() FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."get_my_permission_codes"() TO "anon";
GRANT ALL ON FUNCTION "public"."get_my_permission_codes"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."get_my_permission_codes"() TO "service_role";



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



GRANT ALL ON FUNCTION "public"."is_district_forward_party"("p_application_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_district_forward_party"("p_application_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_district_forward_party"("p_application_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."is_geo_admin"() TO "anon";
GRANT ALL ON FUNCTION "public"."is_geo_admin"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_geo_admin"() TO "service_role";



GRANT ALL ON FUNCTION "public"."is_state_admin"("p_state_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."is_state_admin"("p_state_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_state_admin"("p_state_id" "uuid") TO "service_role";



GRANT ALL ON FUNCTION "public"."link_guest_applications_on_profile"() TO "anon";
GRANT ALL ON FUNCTION "public"."link_guest_applications_on_profile"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."link_guest_applications_on_profile"() TO "service_role";



GRANT ALL ON FUNCTION "public"."log_application_district_transfer"() TO "anon";
GRANT ALL ON FUNCTION "public"."log_application_district_transfer"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."log_application_district_transfer"() TO "service_role";



REVOKE ALL ON FUNCTION "public"."submit_legal_aid_application"("p_application" "jsonb") FROM PUBLIC;
GRANT ALL ON FUNCTION "public"."submit_legal_aid_application"("p_application" "jsonb") TO "anon";
GRANT ALL ON FUNCTION "public"."submit_legal_aid_application"("p_application" "jsonb") TO "authenticated";
GRANT ALL ON FUNCTION "public"."submit_legal_aid_application"("p_application" "jsonb") TO "service_role";



GRANT ALL ON FUNCTION "public"."sync_user_type_from_admin_scope"() TO "anon";
GRANT ALL ON FUNCTION "public"."sync_user_type_from_admin_scope"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."sync_user_type_from_admin_scope"() TO "service_role";



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



GRANT ALL ON TABLE "public"."modules" TO "anon";
GRANT ALL ON TABLE "public"."modules" TO "authenticated";
GRANT ALL ON TABLE "public"."modules" TO "service_role";



GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";



GRANT ALL ON TABLE "public"."role_permissions" TO "anon";
GRANT ALL ON TABLE "public"."role_permissions" TO "authenticated";
GRANT ALL ON TABLE "public"."role_permissions" TO "service_role";



GRANT ALL ON TABLE "public"."roles" TO "anon";
GRANT ALL ON TABLE "public"."roles" TO "authenticated";
GRANT ALL ON TABLE "public"."roles" TO "service_role";



GRANT ALL ON TABLE "public"."state_master" TO "anon";
GRANT ALL ON TABLE "public"."state_master" TO "authenticated";
GRANT ALL ON TABLE "public"."state_master" TO "service_role";



GRANT ALL ON TABLE "public"."taluka_master" TO "anon";
GRANT ALL ON TABLE "public"."taluka_master" TO "authenticated";
GRANT ALL ON TABLE "public"."taluka_master" TO "service_role";



GRANT ALL ON TABLE "public"."user_roles" TO "anon";
GRANT ALL ON TABLE "public"."user_roles" TO "authenticated";
GRANT ALL ON TABLE "public"."user_roles" TO "service_role";









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
































-- ============================================================================
-- Quick Callback & Application Tracking Additions
-- ============================================================================

CREATE TABLE IF NOT EXISTS "public"."application_callback_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "application_id" "uuid" NOT NULL,
    "called_by_id" "uuid",
    "outcome" "text" NOT NULL,
    "notes" "text",
    "called_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    CONSTRAINT "application_callback_log_outcome_check" CHECK (("outcome" = ANY (ARRAY['NO_ANSWER'::"text", 'SWITCHED_OFF'::"text", 'WRONG_NUMBER'::"text", 'CALL_BACK_LATER'::"text", 'DETAILS_COLLECTED'::"text", 'REFUSED'::"text"])))
);

ALTER TABLE "public"."application_callback_log" OWNER TO "postgres";

ALTER TABLE ONLY "public"."application_callback_log"
    ADD CONSTRAINT "application_callback_log_pkey" PRIMARY KEY ("id");

ALTER TABLE ONLY "public"."application_callback_log"
    ADD CONSTRAINT "application_callback_log_application_id_fkey" FOREIGN KEY ("application_id") REFERENCES "public"."legal_aid_application"("id") ON DELETE CASCADE;

ALTER TABLE ONLY "public"."application_callback_log"
    ADD CONSTRAINT "application_callback_log_called_by_id_fkey" FOREIGN KEY ("called_by_id") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE ONLY "public"."legal_aid_application"
    ADD CONSTRAINT "legal_aid_application_details_completed_by_fkey" FOREIGN KEY ("details_completed_by") REFERENCES "public"."profiles"("id") ON DELETE SET NULL;

ALTER TABLE "public"."application_callback_log" ENABLE ROW LEVEL SECURITY;

CREATE POLICY "admin_select_callback_log" ON "public"."application_callback_log" FOR SELECT USING (("public"."is_admin"() OR ("public"."is_geo_admin"() AND (EXISTS ( SELECT 1 FROM "public"."legal_aid_application" "a" WHERE ("a"."id" = "application_callback_log"."application_id"))))));
CREATE POLICY "admin_insert_callback_log" ON "public"."application_callback_log" FOR INSERT WITH CHECK (("public"."is_admin"() OR ("public"."is_geo_admin"() AND (EXISTS ( SELECT 1 FROM "public"."legal_aid_application" "a" WHERE ("a"."id" = "application_callback_log"."application_id"))))));

CREATE TABLE IF NOT EXISTS "public"."submission_attempt_log" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "action" "text" NOT NULL,
    "phone_hash" "text" NOT NULL,
    "device_hash" "text" NOT NULL,
    "ip_hash" "text" NOT NULL,
    "outcome" "text" NOT NULL,
    "reason" "text"
);

ALTER TABLE "public"."submission_attempt_log" OWNER TO "postgres";

ALTER TABLE ONLY "public"."submission_attempt_log"
    ADD CONSTRAINT "submission_attempt_log_pkey" PRIMARY KEY ("id");

CREATE INDEX IF NOT EXISTS "idx_sub_attempt_phone_time" ON "public"."submission_attempt_log" USING "btree" ("phone_hash", "created_at" DESC);
CREATE INDEX IF NOT EXISTS "idx_sub_attempt_device_time" ON "public"."submission_attempt_log" USING "btree" ("device_hash", "created_at" DESC);
CREATE INDEX IF NOT EXISTS "idx_sub_attempt_ip_time" ON "public"."submission_attempt_log" USING "btree" ("ip_hash", "created_at" DESC);

ALTER TABLE "public"."submission_attempt_log" ENABLE ROW LEVEL SECURITY;

CREATE OR REPLACE FUNCTION "public"."fn_enforce_application_update_invariants"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
    AS $$
BEGIN
  IF OLD.tracking_number IS NOT NULL AND OLD.tracking_number <> '' THEN
    NEW.tracking_number := OLD.tracking_number;
  END IF;

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

ALTER FUNCTION "public"."fn_enforce_application_update_invariants"() OWNER TO "postgres";

CREATE OR REPLACE TRIGGER "trg_enforce_application_update_invariants" BEFORE UPDATE ON "public"."legal_aid_application" FOR EACH ROW EXECUTE FUNCTION "public"."fn_enforce_application_update_invariants"();

CREATE OR REPLACE FUNCTION "public"."create_quick_application"(
    "p_phone" "text",
    "p_name" "text",
    "p_district_id" "uuid",
    "p_note" "text",
    "p_applicant_id" "uuid"
) RETURNS TABLE("tracking_number" "text", "application_id" "uuid")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
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

ALTER FUNCTION "public"."create_quick_application"("p_phone" "text", "p_name" "text", "p_district_id" "uuid", "p_note" "text", "p_applicant_id" "uuid") OWNER TO "postgres";
REVOKE EXECUTE ON FUNCTION "public"."create_quick_application"("p_phone" "text", "p_name" "text", "p_district_id" "uuid", "p_note" "text", "p_applicant_id" "uuid") FROM PUBLIC, "anon", "authenticated";
GRANT EXECUTE ON FUNCTION "public"."create_quick_application"("p_phone" "text", "p_name" "text", "p_district_id" "uuid", "p_note" "text", "p_applicant_id" "uuid") TO "service_role";

CREATE OR REPLACE FUNCTION "public"."track_applications_by_phone"(
    "p_phone" "text"
) RETURNS TABLE("tracking_number" "text", "application_mode" "text", "status" "text", "callback_status" "text", "category_name" "text", "case_type_name" "text", "created_at" timestamp with time zone, "updated_at" timestamp with time zone, "masked_name" "text")
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public', 'pg_temp'
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

ALTER FUNCTION "public"."track_applications_by_phone"("p_phone" "text") OWNER TO "postgres";
REVOKE EXECUTE ON FUNCTION "public"."track_applications_by_phone"("p_phone" "text") FROM PUBLIC, "anon", "authenticated";
GRANT EXECUTE ON FUNCTION "public"."track_applications_by_phone"("p_phone" "text") TO "service_role";
