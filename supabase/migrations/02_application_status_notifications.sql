-- =====================================================================
-- NYAYA SAATHI: APPLICATION STATUS NOTIFICATIONS MIGRATION
-- Aligned with v3 Schema (public.legal_aid_application, profiles, application_status_history)
-- File: supabase/migrations/02_application_status_notifications.sql
-- =====================================================================

-- 1. Ensure fcm_token column exists on public.profiles
ALTER TABLE public.profiles 
ADD COLUMN IF NOT EXISTS fcm_token text;

-- 2. Ensure application_status_history supports nullable changed_by_id for trigger updates
DO $$ 
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns 
    WHERE table_schema = 'public' 
      AND table_name = 'application_status_history' 
      AND column_name = 'changed_by_id'
      AND is_nullable = 'NO'
  ) THEN
    ALTER TABLE public.application_status_history ALTER COLUMN changed_by_id DROP NOT NULL;
  END IF;
END $$;

-- 3. Create or update public.notifications table
CREATE TABLE IF NOT EXISTS "public"."notifications" (
  "id" uuid DEFAULT gen_random_uuid() NOT NULL PRIMARY KEY,
  "user_id" uuid NOT NULL REFERENCES "public"."profiles"("id") ON DELETE CASCADE,
  "application_id" uuid REFERENCES "public"."legal_aid_application"("id") ON DELETE CASCADE,
  "title" text NOT NULL,
  "body" text NOT NULL,
  "is_read" boolean DEFAULT false NOT NULL,
  "created_at" timestamp with time zone DEFAULT now() NOT NULL
);

-- Grant standard permissions
GRANT ALL ON TABLE "public"."notifications" TO "anon";
GRANT ALL ON TABLE "public"."notifications" TO "authenticated";
GRANT ALL ON TABLE "public"."notifications" TO "service_role";

-- 4. Indexes for query performance
CREATE INDEX IF NOT EXISTS idx_notifications_user_unread 
  ON "public"."notifications" ("user_id", "is_read");

CREATE INDEX IF NOT EXISTS idx_notifications_user_created 
  ON "public"."notifications" ("user_id", "created_at" DESC);

CREATE INDEX IF NOT EXISTS idx_notifications_application_id 
  ON "public"."notifications" ("application_id");

-- 5. Enable Row Level Security (RLS) on public.notifications
ALTER TABLE "public"."notifications" ENABLE ROW LEVEL SECURITY;

-- Citizens can only view their own notifications
DROP POLICY IF EXISTS "Citizens can view own notifications" ON "public"."notifications";
CREATE POLICY "Citizens can view own notifications" 
  ON "public"."notifications" 
  FOR SELECT 
  TO authenticated 
  USING (auth.uid() = user_id);

-- Citizens can update (mark as read) their own notifications
DROP POLICY IF EXISTS "Citizens can update own notifications" ON "public"."notifications";
CREATE POLICY "Citizens can update own notifications" 
  ON "public"."notifications" 
  FOR UPDATE 
  TO authenticated 
  USING (auth.uid() = user_id)
  WITH CHECK (auth.uid() = user_id);

-- Deny direct client inserts / deletes
DROP POLICY IF EXISTS "Citizens cannot insert notifications" ON "public"."notifications";
DROP POLICY IF EXISTS "Citizens cannot delete notifications" ON "public"."notifications";

-- 6. Trigger Function to Generate Status Notifications & Record Status History
CREATE OR REPLACE FUNCTION "public"."fn_handle_application_status_change"()
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
  -- Target citizen profile
  v_applicant_id := NEW.applicant_id;

  -- Exit if no applicant is associated (e.g. unlinked draft)
  IF v_applicant_id IS NULL THEN
    RETURN NEW;
  END IF;

  -- Verify applicant profile exists
  IF NOT EXISTS (SELECT 1 FROM public.profiles WHERE id = v_applicant_id) THEN
    RETURN NEW;
  END IF;

  v_tracking := COALESCE(NEW.tracking_number, 'SK-APPLICATION');
  v_status_normalized := UPPER(COALESCE(NEW.status, ''));

  -- Map application status to citizen push notification title and body
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

  -- 1. Record transition in application_status_history
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
    -- Fallback in case of constraint difference
    NULL;
  END;

  -- 2. Insert into notifications table (fires the Database Webhook to FCM Edge Function)
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

ALTER FUNCTION "public"."fn_handle_application_status_change"() OWNER TO "postgres";

-- 7. Trigger on public.legal_aid_application
-- Fires exclusively on UPDATE when status changes
DROP TRIGGER IF EXISTS trg_application_status_notification_update ON public.legal_aid_application;
CREATE TRIGGER trg_application_status_notification_update
  AFTER UPDATE OF status ON public.legal_aid_application
  FOR EACH ROW
  WHEN (OLD.status IS DISTINCT FROM NEW.status)
  EXECUTE FUNCTION public.fn_handle_application_status_change();

-- Fires on initial application INSERT
DROP TRIGGER IF EXISTS trg_application_status_notification_insert ON public.legal_aid_application;
CREATE TRIGGER trg_application_status_notification_insert
  AFTER INSERT ON public.legal_aid_application
  FOR EACH ROW
  WHEN (NEW.status IS NOT NULL AND NEW.applicant_id IS NOT NULL)
  EXECUTE FUNCTION public.fn_handle_application_status_change();
