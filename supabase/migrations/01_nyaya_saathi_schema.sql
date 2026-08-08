-- =====================================================================
-- NYAYA SAATHI - COMPLETE SUPABASE SCHEMAS & MIGRATION
-- Incorporates SLSA FMS Base Tables & Legal Aid Mobile Extensions
-- =====================================================================

-- Enable extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Base enums
DO $$ BEGIN
    CREATE TYPE public.user_gender AS ENUM ('Male', 'Female', 'Other', 'Transgender', 'Prefer not to say');
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

DO $$ BEGIN
    CREATE TYPE public.application_status_enum AS ENUM (
      'DRAFT', 'SUBMITTED', 'UNDER_SCRUTINY', 'ACTION_REQUIRED', 
      'REJECTED', 'APPROVED_SLSA', 'ASSIGNED_TO_ADVOCATE', 
      'ADVOCATE_ACCEPTED', 'CASE_IN_PROGRESS', 'CLOSED', 'WITHDRAWN'
    );
EXCEPTION
    WHEN duplicate_object THEN null;
END $$;

-- 1. Base Master Tables
CREATE TABLE IF NOT EXISTS public.state_master (
  state_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  state_code text NOT NULL UNIQUE,
  state_name text NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.district_master (
  district_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  state_id bigint NOT NULL REFERENCES public.state_master(state_id),
  district_code text NOT NULL UNIQUE,
  district_name text NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.legal_aid_category (
  legal_aid_category_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  category_code text NOT NULL UNIQUE,
  category_name text NOT NULL,
  description text,
  income_limit numeric(12,2),
  icon_name text DEFAULT 'payments',
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.case_type_master (
  case_type_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  case_type_code text NOT NULL UNIQUE,
  case_type_name text NOT NULL,
  category_group text,
  icon_name text DEFAULT 'gavel',
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.document_master (
  document_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  document_code text NOT NULL UNIQUE,
  document_name text NOT NULL,
  description text,
  is_mandatory_default boolean DEFAULT false,
  is_active boolean DEFAULT true
);

-- Mappings for required documents
CREATE TABLE IF NOT EXISTS public.legal_aid_category_document_map (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  legal_aid_category_id bigint NOT NULL REFERENCES public.legal_aid_category(legal_aid_category_id),
  document_id bigint NOT NULL REFERENCES public.document_master(document_id),
  is_mandatory boolean DEFAULT true,
  UNIQUE(legal_aid_category_id, document_id)
);

CREATE TABLE IF NOT EXISTS public.case_type_document_map (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  case_type_id bigint NOT NULL REFERENCES public.case_type_master(case_type_id),
  document_id bigint NOT NULL REFERENCES public.document_master(document_id),
  is_mandatory boolean DEFAULT true,
  UNIQUE(case_type_id, document_id)
);

-- Profiles & Roles
CREATE TABLE IF NOT EXISTS public.roles (
  role_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  role_code text NOT NULL UNIQUE,
  role_name text NOT NULL
);

CREATE TABLE IF NOT EXISTS public.profiles (
  id uuid PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  role_id bigint REFERENCES public.roles(role_id),
  full_name text NOT NULL,
  email text,
  phone_number text,
  district_id bigint REFERENCES public.district_master(district_id),
  is_active boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.citizen_details (
  citizen_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  aadhaar_last_four text,
  address_line text,
  village_or_town text,
  pin_code text,
  annual_family_income numeric(12,2),
  created_at timestamp with time zone DEFAULT now()
);

CREATE TABLE IF NOT EXISTS public.advocate_master (
  advocate_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  bar_enrollment_number text NOT NULL UNIQUE,
  specialization text,
  years_of_experience integer,
  district_id bigint REFERENCES public.district_master(district_id),
  is_available boolean DEFAULT true,
  created_at timestamp with time zone DEFAULT now()
);

-- 2. Applications Main Table
CREATE TABLE IF NOT EXISTS public.legal_aid_application (
  application_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_number text NOT NULL UNIQUE,
  citizen_id uuid REFERENCES public.profiles(id),
  legal_aid_category_id bigint NOT NULL REFERENCES public.legal_aid_category(legal_aid_category_id),
  case_type_id bigint NOT NULL REFERENCES public.case_type_master(case_type_id),
  district_id bigint NOT NULL REFERENCES public.district_master(district_id),
  summary_of_grievance text NOT NULL,
  relief_sought text,
  current_status public.application_status_enum NOT NULL DEFAULT 'SUBMITTED',
  submitted_at timestamp with time zone DEFAULT now(),
  created_at timestamp with time zone DEFAULT now(),
  updated_at timestamp with time zone DEFAULT now()
);

-- Application Documents
CREATE TABLE IF NOT EXISTS public.application_documents (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id bigint NOT NULL REFERENCES public.legal_aid_application(application_id) ON DELETE CASCADE,
  document_id bigint NOT NULL REFERENCES public.document_master(document_id),
  storage_file_path text NOT NULL,
  uploaded_at timestamp with time zone DEFAULT now()
);

-- Advocates Assignment
CREATE TABLE IF NOT EXISTS public.advocate_assignment (
  assignment_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id bigint NOT NULL REFERENCES public.legal_aid_application(application_id),
  advocate_id uuid NOT NULL REFERENCES public.advocate_master(advocate_id),
  assigned_by uuid REFERENCES public.profiles(id),
  assigned_at timestamp with time zone DEFAULT now(),
  is_current boolean DEFAULT true,
  remarks text
);

-- Application Status History
CREATE TABLE IF NOT EXISTS public.application_status_history (
  history_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id bigint NOT NULL REFERENCES public.legal_aid_application(application_id),
  from_status public.application_status_enum,
  to_status public.application_status_enum NOT NULL,
  changed_by uuid REFERENCES public.profiles(id),
  remarks text,
  changed_at timestamp with time zone DEFAULT now()
);

-- Advocate Change Request
CREATE TABLE IF NOT EXISTS public.advocate_change_request (
  request_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id bigint NOT NULL REFERENCES public.legal_aid_application(application_id),
  requested_by uuid NOT NULL REFERENCES public.profiles(id),
  reason text NOT NULL,
  status text NOT NULL DEFAULT 'PENDING' CHECK (status IN ('PENDING', 'APPROVED', 'REJECTED')),
  created_at timestamp with time zone DEFAULT now()
);

-- =====================================================================
-- 3. MOBILE APP EXTENDED TABLES (From Specification)
-- =====================================================================

-- Applicant identity per application (Self / Other)
CREATE TABLE IF NOT EXISTS public.application_applicant_details (
  application_id bigint NOT NULL PRIMARY KEY REFERENCES public.legal_aid_application(application_id) ON DELETE CASCADE,
  applied_for text NOT NULL CHECK (applied_for IN ('self','other')),
  relation_remark text,
  full_name text NOT NULL,
  gender public.user_gender,
  date_of_birth date,
  village_or_town text,
  district_id bigint REFERENCES public.district_master(district_id),
  email text,
  phone_number text,
  created_at timestamp with time zone DEFAULT now()
);

-- Witnesses (2 per application)
CREATE TABLE IF NOT EXISTS public.application_witness (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id bigint NOT NULL REFERENCES public.legal_aid_application(application_id) ON DELETE CASCADE,
  witness_name text NOT NULL,
  relation_to_applicant text NOT NULL,
  created_at timestamp with time zone DEFAULT now()
);

-- Authority form templates (Form A/B/C/D)
CREATE TABLE IF NOT EXISTS public.form_template_master (
  form_template_id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  form_code text NOT NULL, -- 'A', 'B', 'C', 'D'
  form_name text,
  legal_aid_category_id bigint REFERENCES public.legal_aid_category(legal_aid_category_id),
  case_type_id bigint REFERENCES public.case_type_master(case_type_id),
  template_key text NOT NULL,
  template_version integer NOT NULL DEFAULT 1,
  is_active boolean NOT NULL DEFAULT true,
  created_at timestamp with time zone DEFAULT now(),
  CONSTRAINT form_template_master_key_version_unique UNIQUE (template_key, template_version)
);

CREATE TABLE IF NOT EXISTS public.application_generated_form (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id bigint NOT NULL UNIQUE REFERENCES public.legal_aid_application(application_id) ON DELETE CASCADE,
  form_template_id bigint NOT NULL REFERENCES public.form_template_master(form_template_id),
  generated_pdf_url text NOT NULL,
  generated_at timestamp with time zone DEFAULT now()
);

-- OTP verification
CREATE TABLE IF NOT EXISTS public.otp_verification (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  destination text NOT NULL,
  destination_type text NOT NULL CHECK (destination_type IN ('email','phone')),
  purpose text NOT NULL CHECK (purpose IN ('login','register','application_submit')),
  otp_hash text NOT NULL,
  expires_at timestamp with time zone NOT NULL,
  verified_at timestamp with time zone,
  attempt_count smallint NOT NULL DEFAULT 0,
  resend_count smallint NOT NULL DEFAULT 0,
  last_sent_at timestamp with time zone DEFAULT now(),
  locked_until timestamp with time zone,
  application_id bigint REFERENCES public.legal_aid_application(application_id),
  created_at timestamp with time zone DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_otp_destination ON public.otp_verification (destination, destination_type, purpose);

-- User Preferences
CREATE TABLE IF NOT EXISTS public.user_preferences (
  profile_id uuid PRIMARY KEY REFERENCES public.profiles(id) ON DELETE CASCADE,
  language text NOT NULL DEFAULT 'en' CHECK (language IN ('en','ne')),
  theme text NOT NULL DEFAULT 'system' CHECK (theme IN ('light','dark','system')),
  font_scale text NOT NULL DEFAULT 'medium' CHECK (font_scale IN ('small','medium','large')),
  updated_at timestamp with time zone DEFAULT now()
);

-- Notifications
CREATE TABLE IF NOT EXISTS public.notifications (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  profile_id uuid NOT NULL REFERENCES public.profiles(id) ON DELETE CASCADE,
  application_id bigint REFERENCES public.legal_aid_application(application_id) ON DELETE CASCADE,
  title text NOT NULL,
  body text,
  is_read boolean NOT NULL DEFAULT false,
  created_at timestamp with time zone DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_notifications_profile_unread ON public.notifications (profile_id, is_read);

-- Trigger for Auto Notifications on Status Change
CREATE OR REPLACE FUNCTION public.fn_notify_on_status_change()
RETURNS trigger AS $$
BEGIN
  INSERT INTO public.notifications (profile_id, application_id, title, body)
  SELECT la.citizen_id, NEW.application_id,
         'Application Status Updated',
         'Your application ' || la.application_number || ' status is now: ' || NEW.to_status
  FROM public.legal_aid_application la
  WHERE la.application_id = NEW.application_id AND la.citizen_id IS NOT NULL;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

DROP TRIGGER IF EXISTS trg_notify_on_status_change ON public.application_status_history;
CREATE TRIGGER trg_notify_on_status_change
AFTER INSERT ON public.application_status_history
FOR EACH ROW EXECUTE FUNCTION public.fn_notify_on_status_change();

-- FAQ & Chat
CREATE TABLE IF NOT EXISTS public.faq_master (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  question text NOT NULL,
  answer text NOT NULL,
  display_order smallint,
  is_active boolean NOT NULL DEFAULT true
);

CREATE TABLE IF NOT EXISTS public.chat_message (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_id bigint REFERENCES public.legal_aid_application(application_id) ON DELETE CASCADE,
  sender_id uuid REFERENCES public.profiles(id),
  recipient_id uuid NOT NULL REFERENCES public.profiles(id),
  message text NOT NULL,
  is_from_authority boolean NOT NULL DEFAULT false,
  sent_at timestamp with time zone DEFAULT now(),
  read_at timestamp with time zone
);

CREATE INDEX IF NOT EXISTS idx_chat_message_recipient ON public.chat_message (recipient_id, sent_at);

-- Tracking attempts log (abuse / rate limiting guard)
CREATE TABLE IF NOT EXISTS public.tracking_attempt_log (
  id bigint GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  application_number text NOT NULL,
  secondary_identifier text,
  matched boolean NOT NULL DEFAULT false,
  device_id text,
  ip_address inet,
  attempted_at timestamp with time zone DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_tracking_attempt_device ON public.tracking_attempt_log (device_id, attempted_at);
CREATE INDEX IF NOT EXISTS idx_tracking_attempt_ip ON public.tracking_attempt_log (ip_address, attempted_at);

-- Seed Data (States, Districts, Categories, Case Types, Documents, FAQs)
INSERT INTO public.state_master (state_code, state_name) VALUES ('SK', 'Sikkim') ON CONFLICT (state_code) DO NOTHING;

INSERT INTO public.district_master (district_code, district_name, state_id)
SELECT d.code, d.name, s.state_id
FROM (VALUES 
  ('SK_GANGTOK', 'Gangtok (East Sikkim)'),
  ('SK_NAMCHI', 'Namchi (South Sikkim)'),
  ('SK_GYALSHING', 'Gyalshing (West Sikkim)'),
  ('SK_MANGAN', 'Mangan (North Sikkim)'),
  ('SK_SORENG', 'Soreng'),
  ('SK_PAKYONG', 'Pakyong')
) AS d(code, name)
CROSS JOIN public.state_master s WHERE s.state_code = 'SK'
ON CONFLICT (district_code) DO NOTHING;

INSERT INTO public.legal_aid_category (category_code, category_name, description, income_limit) VALUES
('CAT_GEN', 'General (Income < ₹3,00,000/yr)', 'Citizens with annual family income below ₹3 Lakhs', 300000.00),
('CAT_WOMEN', 'Women & Children', 'Women and minor children regardless of income limit', NULL),
('CAT_SC_ST', 'Scheduled Caste / Scheduled Tribe', 'Members of SC/ST communities', NULL),
('CAT_DISABLED', 'Mentally Ill / Differently Abled', 'Persons with mental or physical disabilities', NULL),
('CAT_DISASTER', 'Victim of Mass Disaster / Violence', 'Victims of natural calamities or ethnic violence', NULL)
ON CONFLICT (category_code) DO NOTHING;

INSERT INTO public.case_type_master (case_type_code, case_type_name, category_group) VALUES
('CT_DOMESTIC', 'Domestic Violence & Maintenance', 'Family Law'),
('CT_PROPERTY', 'Land & Property Dispute', 'Civil Law'),
('CT_SUCCESSION', 'Succession & Heirship Certificate', 'Civil Law'),
('CT_CRIMINAL_DEFENSE', 'Criminal Defense / Bail Application', 'Criminal Law'),
('CT_LABOUR', 'Wages & Labour Dispute', 'Labour Law'),
('CT_CONSUMER', 'Consumer Protection', 'Civil Law')
ON CONFLICT (case_type_code) DO NOTHING;

INSERT INTO public.document_master (document_code, document_name, description, is_mandatory_default) VALUES
('DOC_ID', 'Identity Proof (Aadhaar / Voter ID / Passport)', 'Valid government issued identity document', true),
('DOC_INCOME', 'Income Certificate', 'Certificate issued by Tehsildar or District Magistrate', false),
('DOC_GENDER_PROOF', 'Gender / Identity Declaration', 'Self declaration or ID proof for women category', false),
('DOC_CASTE_CERT', 'Caste Certificate (SC/ST)', 'Official SC/ST community certificate', false),
('DOC_DISABILITY_CERT', 'Disability Certificate', 'Medical certificate from authorized civil surgeon', false),
('DOC_DEATH_CERT', 'Death Certificate of Deceased', 'Required for succession and inheritance cases', false),
('DOC_FIR_COPY', 'FIR / Police Complaint Copy', 'Copy of registered police report for criminal cases', false)
ON CONFLICT (document_code) DO NOTHING;

INSERT INTO public.faq_master (question, answer, display_order) VALUES
('Who is eligible for free Legal Aid in Sikkim?', 'Under Section 12 of the Legal Services Authorities Act, 1987, women, children, members of SC/ST, victims of disasters, mentally ill/disabled persons, and citizens with annual income less than ₹3,00,000 are eligible.', 1),
('How long does it take for my legal aid application to be processed?', 'Initial scrutiny is completed within 3 to 5 working days by the District Legal Services Authority (DLSA). Upon approval, an advocate is assigned immediately.', 2),
('Can I apply on behalf of a family member?', 'Yes. In Step 2 of the application form, select "Other" under "Applying For" and state your relationship with the applicant.', 3),
('How can I track my application without creating an account?', 'Click "Track Application" on the home screen, enter your Tracking ID (e.g. SK-LA-2026-XXXX) along with your Date of Birth or phone number.', 4),
('Is there any fee for submitting a legal aid application?', 'No. Legal aid services provided by Sikkim SLSA & DLSAs are 100% free of cost.', 5)
ON CONFLICT DO NOTHING;
