create type "public"."user_status_enum" as enum ('ACTIVE', 'INACTIVE', 'SUSPENDED');

create type "public"."user_type_enum" as enum ('CITIZEN', 'ADVOCATE', 'ADMIN', 'STAFF', 'DISTRICT_ADMIN', 'STATE_ADMIN', 'SUPER_ADMIN');

create sequence "public"."application_tracking_seq";


  create table "public"."admin_scope" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "is_global_super_admin" boolean not null default false,
    "state_id" uuid,
    "district_id" uuid,
    "scope_level" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."admin_scope" enable row level security;


  create table "public"."advocate_case_action_log" (
    "id" uuid not null default gen_random_uuid(),
    "application_id" uuid not null,
    "advocate_id" uuid not null,
    "action_type" text not null,
    "reason" text not null,
    "action_at" timestamp with time zone not null default now()
      );


alter table "public"."advocate_case_action_log" enable row level security;


  create table "public"."advocate_change_request" (
    "id" uuid not null default gen_random_uuid(),
    "application_id" uuid not null,
    "requested_by_citizen_id" uuid not null,
    "current_advocate_id" uuid,
    "preferred_new_advocate_id" uuid,
    "reason" text not null,
    "request_status" text not null default 'PENDING'::text,
    "reviewed_by_admin_id" uuid,
    "admin_remarks" text,
    "requested_at" timestamp with time zone not null default now(),
    "reviewed_at" timestamp with time zone
      );


alter table "public"."advocate_change_request" enable row level security;


  create table "public"."advocate_district_mapping" (
    "advocate_id" uuid not null,
    "district_id" uuid not null,
    "is_primary_district" boolean not null default true
      );


alter table "public"."advocate_district_mapping" enable row level security;


  create table "public"."advocate_master" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid,
    "full_name" text not null,
    "gender" text,
    "enrollment_number" text not null,
    "primary_email" text not null,
    "secondary_email" text,
    "primary_phone_number" text not null,
    "secondary_phone_number" text,
    "office_address" text,
    "experience_years" integer default 0,
    "is_active" boolean not null default true,
    "is_available_for_assignment" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."advocate_master" enable row level security;


  create table "public"."application_document" (
    "id" uuid not null default gen_random_uuid(),
    "application_id" uuid not null,
    "document_id" uuid not null,
    "file_url" text not null,
    "file_name" text not null,
    "file_size_in_bytes" bigint,
    "is_verified" boolean not null default false,
    "verified_by" uuid,
    "uploaded_at" timestamp with time zone not null default now()
      );


alter table "public"."application_document" enable row level security;


  create table "public"."application_forward_log" (
    "id" uuid not null default gen_random_uuid(),
    "application_id" uuid not null,
    "from_district_id" uuid not null,
    "to_district_id" uuid not null,
    "forwarded_by_id" uuid not null,
    "reason" text not null,
    "forwarded_at" timestamp with time zone not null default now()
      );


alter table "public"."application_forward_log" enable row level security;


  create table "public"."application_status_history" (
    "id" uuid not null default gen_random_uuid(),
    "application_id" uuid not null,
    "previous_status" text,
    "new_status" text not null,
    "changed_by_id" uuid,
    "remarks" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."application_status_history" enable row level security;


  create table "public"."case_type_document_map" (
    "case_type_id" uuid not null,
    "document_id" uuid not null,
    "is_required" boolean not null default true
      );


alter table "public"."case_type_document_map" enable row level security;


  create table "public"."case_type_master" (
    "id" uuid not null default gen_random_uuid(),
    "case_type_code" text not null,
    "case_type_name" text not null,
    "icon_url" text,
    "display_order" integer default 0,
    "is_active" boolean not null default true,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."case_type_master" enable row level security;


  create table "public"."district_master" (
    "id" uuid not null default gen_random_uuid(),
    "district_name" text not null,
    "district_code" text not null,
    "state_id" uuid not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."district_master" enable row level security;


  create table "public"."document_master" (
    "id" uuid not null default gen_random_uuid(),
    "document_code" text not null,
    "document_name" text not null,
    "description" text,
    "is_active" boolean not null default true,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."document_master" enable row level security;


  create table "public"."legal_aid_application" (
    "id" uuid not null default gen_random_uuid(),
    "tracking_number" text not null,
    "applicant_id" uuid,
    "category_id" uuid not null,
    "applicant_full_name" text not null,
    "applicant_phone_number" text not null,
    "applicant_dob" date not null,
    "applicant_gender" text not null,
    "village_or_town" text,
    "applicant_district_id" uuid not null,
    "case_type_id" uuid not null,
    "current_district_id" uuid not null,
    "current_taluka_id" uuid,
    "case_details" text not null,
    "preferred_advocate_id" uuid,
    "assigned_advocate_id" uuid,
    "advocate_acceptance_status" text not null default 'NONE'::text,
    "assigned_at" timestamp with time zone,
    "status" text not null default 'SUBMITTED'::text,
    "is_withdrawn_by_citizen" boolean not null default false,
    "withdrawal_reason" text,
    "withdrawn_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."legal_aid_application" enable row level security;


  create table "public"."legal_aid_category" (
    "id" uuid not null default gen_random_uuid(),
    "category_code" text not null,
    "category_name" text not null,
    "description" text,
    "display_order" integer default 0,
    "icon_url" text,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."legal_aid_category" enable row level security;


  create table "public"."legal_aid_category_document_map" (
    "category_id" uuid not null,
    "document_id" uuid not null,
    "is_required" boolean not null default true
      );


alter table "public"."legal_aid_category_document_map" enable row level security;


  create table "public"."modules" (
    "id" uuid not null default gen_random_uuid(),
    "code" text not null,
    "permission_code" text not null,
    "label" text not null,
    "route" text,
    "icon" text,
    "section" text not null default 'ADMINISTRATION'::text,
    "group_label" text,
    "display_order" integer not null default 0,
    "is_active" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."modules" enable row level security;


  create table "public"."notifications" (
    "id" uuid not null default gen_random_uuid(),
    "user_id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "body" text not null,
    "title" text not null default 'Application Status Updated'::text,
    "application_id" uuid,
    "type" text not null default 'application_status_update'::text,
    "is_read" boolean not null default false
      );


alter table "public"."notifications" enable row level security;


  create table "public"."profiles" (
    "id" uuid not null,
    "full_name" text not null,
    "phone_number" text,
    "email" text,
    "dob" date,
    "gender" text,
    "village_or_town" text,
    "district_id" uuid,
    "user_type" public.user_type_enum not null default 'CITIZEN'::public.user_type_enum,
    "status" public.user_status_enum not null default 'ACTIVE'::public.user_status_enum,
    "last_login_at" timestamp with time zone,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now(),
    "fcm_token" text
      );


alter table "public"."profiles" enable row level security;


  create table "public"."role_permissions" (
    "role_id" uuid not null,
    "permission_code" text not null
      );


alter table "public"."role_permissions" enable row level security;


  create table "public"."roles" (
    "id" uuid not null default gen_random_uuid(),
    "code" text not null,
    "name" text not null,
    "description" text,
    "is_active" boolean not null default true,
    "is_system" boolean not null default true,
    "created_at" timestamp with time zone not null default now(),
    "updated_at" timestamp with time zone not null default now()
      );


alter table "public"."roles" enable row level security;


  create table "public"."state_master" (
    "id" uuid not null default gen_random_uuid(),
    "state_name" text not null,
    "state_code" text not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."state_master" enable row level security;


  create table "public"."taluka_master" (
    "id" uuid not null default gen_random_uuid(),
    "taluka_name" text not null,
    "taluka_code" text not null,
    "district_id" uuid not null,
    "created_at" timestamp with time zone not null default now()
      );


alter table "public"."taluka_master" enable row level security;


  create table "public"."user_roles" (
    "user_id" uuid not null,
    "role_id" uuid not null,
    "created_at" timestamp with time zone not null default now(),
    "assigned_by" uuid
      );


alter table "public"."user_roles" enable row level security;

CREATE UNIQUE INDEX admin_scope_pkey ON public.admin_scope USING btree (id);

CREATE UNIQUE INDEX advocate_case_action_log_pkey ON public.advocate_case_action_log USING btree (id);

CREATE UNIQUE INDEX advocate_change_request_pkey ON public.advocate_change_request USING btree (id);

CREATE UNIQUE INDEX advocate_district_mapping_pkey ON public.advocate_district_mapping USING btree (advocate_id, district_id);

CREATE UNIQUE INDEX advocate_master_enrollment_number_key ON public.advocate_master USING btree (enrollment_number);

CREATE UNIQUE INDEX advocate_master_pkey ON public.advocate_master USING btree (id);

CREATE UNIQUE INDEX advocate_master_user_id_key ON public.advocate_master USING btree (user_id);

CREATE UNIQUE INDEX application_document_pkey ON public.application_document USING btree (id);

CREATE INDEX application_forward_log_application_id_idx ON public.application_forward_log USING btree (application_id, forwarded_at);

CREATE UNIQUE INDEX application_forward_log_pkey ON public.application_forward_log USING btree (id);

CREATE UNIQUE INDEX application_status_history_pkey ON public.application_status_history USING btree (id);

CREATE UNIQUE INDEX case_type_document_map_pkey ON public.case_type_document_map USING btree (case_type_id, document_id);

CREATE UNIQUE INDEX case_type_master_case_type_code_key ON public.case_type_master USING btree (case_type_code);

CREATE UNIQUE INDEX case_type_master_pkey ON public.case_type_master USING btree (id);

CREATE UNIQUE INDEX district_master_district_code_key ON public.district_master USING btree (district_code);

CREATE UNIQUE INDEX district_master_pkey ON public.district_master USING btree (id);

CREATE UNIQUE INDEX document_master_document_code_key ON public.document_master USING btree (document_code);

CREATE UNIQUE INDEX document_master_pkey ON public.document_master USING btree (id);

CREATE INDEX idx_modules_permission_code ON public.modules USING btree (permission_code);

CREATE INDEX idx_notifications_application_id ON public.notifications USING btree (application_id);

CREATE INDEX idx_notifications_user_created ON public.notifications USING btree (user_id, created_at DESC);

CREATE INDEX idx_notifications_user_unread ON public.notifications USING btree (user_id, is_read);

CREATE INDEX idx_role_permissions_code ON public.role_permissions USING btree (permission_code);

CREATE INDEX idx_status_history_application ON public.application_status_history USING btree (application_id, created_at DESC);

CREATE INDEX idx_user_roles_role_id ON public.user_roles USING btree (role_id);

CREATE UNIQUE INDEX legal_aid_application_pkey ON public.legal_aid_application USING btree (id);

CREATE UNIQUE INDEX legal_aid_application_tracking_number_key ON public.legal_aid_application USING btree (tracking_number);

CREATE UNIQUE INDEX legal_aid_category_category_code_key ON public.legal_aid_category USING btree (category_code);

CREATE UNIQUE INDEX legal_aid_category_document_map_pkey ON public.legal_aid_category_document_map USING btree (category_id, document_id);

CREATE UNIQUE INDEX legal_aid_category_pkey ON public.legal_aid_category USING btree (id);

CREATE UNIQUE INDEX modules_code_key ON public.modules USING btree (code);

CREATE UNIQUE INDEX modules_pkey ON public.modules USING btree (id);

CREATE UNIQUE INDEX profiles_email_key ON public.profiles USING btree (email);

CREATE UNIQUE INDEX profiles_phone_number_key ON public.profiles USING btree (phone_number);

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

CREATE UNIQUE INDEX role_permissions_pkey ON public.role_permissions USING btree (role_id, permission_code);

CREATE UNIQUE INDEX roles_code_key ON public.roles USING btree (code);

CREATE UNIQUE INDEX roles_pkey ON public.roles USING btree (id);

CREATE UNIQUE INDEX state_master_pkey ON public.state_master USING btree (id);

CREATE UNIQUE INDEX state_master_state_code_key ON public.state_master USING btree (state_code);

CREATE UNIQUE INDEX taluka_master_pkey ON public.taluka_master USING btree (id);

CREATE UNIQUE INDEX taluka_master_taluka_code_key ON public.taluka_master USING btree (taluka_code);

CREATE UNIQUE INDEX user_roles_pkey ON public.user_roles USING btree (user_id, role_id);

CREATE INDEX user_roles_role_id_idx ON public.user_roles USING btree (role_id);

alter table "public"."admin_scope" add constraint "admin_scope_pkey" PRIMARY KEY using index "admin_scope_pkey";

alter table "public"."advocate_case_action_log" add constraint "advocate_case_action_log_pkey" PRIMARY KEY using index "advocate_case_action_log_pkey";

alter table "public"."advocate_change_request" add constraint "advocate_change_request_pkey" PRIMARY KEY using index "advocate_change_request_pkey";

alter table "public"."advocate_district_mapping" add constraint "advocate_district_mapping_pkey" PRIMARY KEY using index "advocate_district_mapping_pkey";

alter table "public"."advocate_master" add constraint "advocate_master_pkey" PRIMARY KEY using index "advocate_master_pkey";

alter table "public"."application_document" add constraint "application_document_pkey" PRIMARY KEY using index "application_document_pkey";

alter table "public"."application_forward_log" add constraint "application_forward_log_pkey" PRIMARY KEY using index "application_forward_log_pkey";

alter table "public"."application_status_history" add constraint "application_status_history_pkey" PRIMARY KEY using index "application_status_history_pkey";

alter table "public"."case_type_document_map" add constraint "case_type_document_map_pkey" PRIMARY KEY using index "case_type_document_map_pkey";

alter table "public"."case_type_master" add constraint "case_type_master_pkey" PRIMARY KEY using index "case_type_master_pkey";

alter table "public"."district_master" add constraint "district_master_pkey" PRIMARY KEY using index "district_master_pkey";

alter table "public"."document_master" add constraint "document_master_pkey" PRIMARY KEY using index "document_master_pkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_pkey" PRIMARY KEY using index "legal_aid_application_pkey";

alter table "public"."legal_aid_category" add constraint "legal_aid_category_pkey" PRIMARY KEY using index "legal_aid_category_pkey";

alter table "public"."legal_aid_category_document_map" add constraint "legal_aid_category_document_map_pkey" PRIMARY KEY using index "legal_aid_category_document_map_pkey";

alter table "public"."modules" add constraint "modules_pkey" PRIMARY KEY using index "modules_pkey";

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."role_permissions" add constraint "role_permissions_pkey" PRIMARY KEY using index "role_permissions_pkey";

alter table "public"."roles" add constraint "roles_pkey" PRIMARY KEY using index "roles_pkey";

alter table "public"."state_master" add constraint "state_master_pkey" PRIMARY KEY using index "state_master_pkey";

alter table "public"."taluka_master" add constraint "taluka_master_pkey" PRIMARY KEY using index "taluka_master_pkey";

alter table "public"."user_roles" add constraint "user_roles_pkey" PRIMARY KEY using index "user_roles_pkey";

alter table "public"."admin_scope" add constraint "admin_scope_district_id_fkey" FOREIGN KEY (district_id) REFERENCES public.district_master(id) ON DELETE SET NULL not valid;

alter table "public"."admin_scope" validate constraint "admin_scope_district_id_fkey";

alter table "public"."admin_scope" add constraint "admin_scope_scope_level_check" CHECK ((scope_level = ANY (ARRAY['GLOBAL'::text, 'STATE'::text, 'DISTRICT'::text]))) not valid;

alter table "public"."admin_scope" validate constraint "admin_scope_scope_level_check";

alter table "public"."admin_scope" add constraint "admin_scope_state_id_fkey" FOREIGN KEY (state_id) REFERENCES public.state_master(id) ON DELETE SET NULL not valid;

alter table "public"."admin_scope" validate constraint "admin_scope_state_id_fkey";

alter table "public"."admin_scope" add constraint "admin_scope_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."admin_scope" validate constraint "admin_scope_user_id_fkey";

alter table "public"."advocate_case_action_log" add constraint "advocate_case_action_log_advocate_id_fkey" FOREIGN KEY (advocate_id) REFERENCES public.advocate_master(id) not valid;

alter table "public"."advocate_case_action_log" validate constraint "advocate_case_action_log_advocate_id_fkey";

alter table "public"."advocate_case_action_log" add constraint "advocate_case_action_log_application_id_fkey" FOREIGN KEY (application_id) REFERENCES public.legal_aid_application(id) ON DELETE CASCADE not valid;

alter table "public"."advocate_case_action_log" validate constraint "advocate_case_action_log_application_id_fkey";

alter table "public"."advocate_change_request" add constraint "advocate_change_request_application_id_fkey" FOREIGN KEY (application_id) REFERENCES public.legal_aid_application(id) ON DELETE CASCADE not valid;

alter table "public"."advocate_change_request" validate constraint "advocate_change_request_application_id_fkey";

alter table "public"."advocate_change_request" add constraint "advocate_change_request_current_advocate_id_fkey" FOREIGN KEY (current_advocate_id) REFERENCES public.advocate_master(id) not valid;

alter table "public"."advocate_change_request" validate constraint "advocate_change_request_current_advocate_id_fkey";

alter table "public"."advocate_change_request" add constraint "advocate_change_request_preferred_new_advocate_id_fkey" FOREIGN KEY (preferred_new_advocate_id) REFERENCES public.advocate_master(id) not valid;

alter table "public"."advocate_change_request" validate constraint "advocate_change_request_preferred_new_advocate_id_fkey";

alter table "public"."advocate_change_request" add constraint "advocate_change_request_request_status_check" CHECK ((request_status = ANY (ARRAY['PENDING'::text, 'APPROVED'::text, 'REJECTED'::text]))) not valid;

alter table "public"."advocate_change_request" validate constraint "advocate_change_request_request_status_check";

alter table "public"."advocate_change_request" add constraint "advocate_change_request_requested_by_citizen_id_fkey" FOREIGN KEY (requested_by_citizen_id) REFERENCES public.profiles(id) not valid;

alter table "public"."advocate_change_request" validate constraint "advocate_change_request_requested_by_citizen_id_fkey";

alter table "public"."advocate_change_request" add constraint "advocate_change_request_reviewed_by_admin_id_fkey" FOREIGN KEY (reviewed_by_admin_id) REFERENCES public.profiles(id) not valid;

alter table "public"."advocate_change_request" validate constraint "advocate_change_request_reviewed_by_admin_id_fkey";

alter table "public"."advocate_district_mapping" add constraint "advocate_district_mapping_advocate_id_fkey" FOREIGN KEY (advocate_id) REFERENCES public.advocate_master(id) ON DELETE CASCADE not valid;

alter table "public"."advocate_district_mapping" validate constraint "advocate_district_mapping_advocate_id_fkey";

alter table "public"."advocate_district_mapping" add constraint "advocate_district_mapping_district_id_fkey" FOREIGN KEY (district_id) REFERENCES public.district_master(id) ON DELETE CASCADE not valid;

alter table "public"."advocate_district_mapping" validate constraint "advocate_district_mapping_district_id_fkey";

alter table "public"."advocate_master" add constraint "advocate_master_enrollment_number_key" UNIQUE using index "advocate_master_enrollment_number_key";

alter table "public"."advocate_master" add constraint "advocate_master_experience_years_check" CHECK ((experience_years >= 0)) not valid;

alter table "public"."advocate_master" validate constraint "advocate_master_experience_years_check";

alter table "public"."advocate_master" add constraint "advocate_master_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."advocate_master" validate constraint "advocate_master_user_id_fkey";

alter table "public"."advocate_master" add constraint "advocate_master_user_id_key" UNIQUE using index "advocate_master_user_id_key";

alter table "public"."application_document" add constraint "application_document_application_id_fkey" FOREIGN KEY (application_id) REFERENCES public.legal_aid_application(id) ON DELETE CASCADE not valid;

alter table "public"."application_document" validate constraint "application_document_application_id_fkey";

alter table "public"."application_document" add constraint "application_document_document_id_fkey" FOREIGN KEY (document_id) REFERENCES public.document_master(id) not valid;

alter table "public"."application_document" validate constraint "application_document_document_id_fkey";

alter table "public"."application_document" add constraint "application_document_verified_by_fkey" FOREIGN KEY (verified_by) REFERENCES public.profiles(id) not valid;

alter table "public"."application_document" validate constraint "application_document_verified_by_fkey";

alter table "public"."application_forward_log" add constraint "application_forward_log_application_id_fkey" FOREIGN KEY (application_id) REFERENCES public.legal_aid_application(id) ON DELETE CASCADE not valid;

alter table "public"."application_forward_log" validate constraint "application_forward_log_application_id_fkey";

alter table "public"."application_forward_log" add constraint "application_forward_log_forwarded_by_id_fkey" FOREIGN KEY (forwarded_by_id) REFERENCES public.profiles(id) not valid;

alter table "public"."application_forward_log" validate constraint "application_forward_log_forwarded_by_id_fkey";

alter table "public"."application_forward_log" add constraint "application_forward_log_from_district_id_fkey" FOREIGN KEY (from_district_id) REFERENCES public.district_master(id) not valid;

alter table "public"."application_forward_log" validate constraint "application_forward_log_from_district_id_fkey";

alter table "public"."application_forward_log" add constraint "application_forward_log_to_district_id_fkey" FOREIGN KEY (to_district_id) REFERENCES public.district_master(id) not valid;

alter table "public"."application_forward_log" validate constraint "application_forward_log_to_district_id_fkey";

alter table "public"."application_status_history" add constraint "application_status_history_application_id_fkey" FOREIGN KEY (application_id) REFERENCES public.legal_aid_application(id) ON DELETE CASCADE not valid;

alter table "public"."application_status_history" validate constraint "application_status_history_application_id_fkey";

alter table "public"."application_status_history" add constraint "application_status_history_changed_by_id_fkey" FOREIGN KEY (changed_by_id) REFERENCES public.profiles(id) not valid;

alter table "public"."application_status_history" validate constraint "application_status_history_changed_by_id_fkey";

alter table "public"."case_type_document_map" add constraint "case_type_document_map_case_type_id_fkey" FOREIGN KEY (case_type_id) REFERENCES public.case_type_master(id) ON DELETE CASCADE not valid;

alter table "public"."case_type_document_map" validate constraint "case_type_document_map_case_type_id_fkey";

alter table "public"."case_type_document_map" add constraint "case_type_document_map_document_id_fkey" FOREIGN KEY (document_id) REFERENCES public.document_master(id) ON DELETE CASCADE not valid;

alter table "public"."case_type_document_map" validate constraint "case_type_document_map_document_id_fkey";

alter table "public"."case_type_master" add constraint "case_type_master_case_type_code_key" UNIQUE using index "case_type_master_case_type_code_key";

alter table "public"."district_master" add constraint "district_master_district_code_key" UNIQUE using index "district_master_district_code_key";

alter table "public"."district_master" add constraint "district_master_state_id_fkey" FOREIGN KEY (state_id) REFERENCES public.state_master(id) ON DELETE CASCADE not valid;

alter table "public"."district_master" validate constraint "district_master_state_id_fkey";

alter table "public"."document_master" add constraint "document_master_document_code_key" UNIQUE using index "document_master_document_code_key";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_advocate_acceptance_status_check" CHECK ((advocate_acceptance_status = ANY (ARRAY['NONE'::text, 'PENDING'::text, 'ACCEPTED'::text, 'REJECTED'::text]))) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_advocate_acceptance_status_check";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_applicant_district_id_fkey" FOREIGN KEY (applicant_district_id) REFERENCES public.district_master(id) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_applicant_district_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_applicant_id_fkey" FOREIGN KEY (applicant_id) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_applicant_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_assigned_advocate_id_fkey" FOREIGN KEY (assigned_advocate_id) REFERENCES public.advocate_master(id) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_assigned_advocate_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_case_type_id_fkey" FOREIGN KEY (case_type_id) REFERENCES public.case_type_master(id) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_case_type_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.legal_aid_category(id) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_category_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_current_district_id_fkey" FOREIGN KEY (current_district_id) REFERENCES public.district_master(id) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_current_district_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_current_taluka_id_fkey" FOREIGN KEY (current_taluka_id) REFERENCES public.taluka_master(id) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_current_taluka_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_preferred_advocate_id_fkey" FOREIGN KEY (preferred_advocate_id) REFERENCES public.advocate_master(id) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_preferred_advocate_id_fkey";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_status_check" CHECK ((status = ANY (ARRAY['SUBMITTED'::text, 'UNDER_REVIEW'::text, 'ADVOCATE_ASSIGNED'::text, 'RESOLVED'::text, 'REJECTED'::text, 'WITHDRAWN'::text]))) not valid;

alter table "public"."legal_aid_application" validate constraint "legal_aid_application_status_check";

alter table "public"."legal_aid_application" add constraint "legal_aid_application_tracking_number_key" UNIQUE using index "legal_aid_application_tracking_number_key";

alter table "public"."legal_aid_category" add constraint "legal_aid_category_category_code_key" UNIQUE using index "legal_aid_category_category_code_key";

alter table "public"."legal_aid_category_document_map" add constraint "legal_aid_category_document_map_category_id_fkey" FOREIGN KEY (category_id) REFERENCES public.legal_aid_category(id) ON DELETE CASCADE not valid;

alter table "public"."legal_aid_category_document_map" validate constraint "legal_aid_category_document_map_category_id_fkey";

alter table "public"."legal_aid_category_document_map" add constraint "legal_aid_category_document_map_document_id_fkey" FOREIGN KEY (document_id) REFERENCES public.document_master(id) ON DELETE CASCADE not valid;

alter table "public"."legal_aid_category_document_map" validate constraint "legal_aid_category_document_map_document_id_fkey";

alter table "public"."modules" add constraint "modules_code_key" UNIQUE using index "modules_code_key";

alter table "public"."modules" add constraint "modules_section_check" CHECK ((section = ANY (ARRAY['HOME'::text, 'ADMINISTRATION'::text]))) not valid;

alter table "public"."modules" validate constraint "modules_section_check";

alter table "public"."notifications" add constraint "notifications_application_id_fkey" FOREIGN KEY (application_id) REFERENCES public.legal_aid_application(id) not valid;

alter table "public"."notifications" validate constraint "notifications_application_id_fkey";

alter table "public"."notifications" add constraint "notifications_user_id_fkey" FOREIGN KEY (user_id) REFERENCES auth.users(id) not valid;

alter table "public"."notifications" validate constraint "notifications_user_id_fkey";

alter table "public"."profiles" add constraint "profiles_district_id_fkey" FOREIGN KEY (district_id) REFERENCES public.district_master(id) ON DELETE SET NULL not valid;

alter table "public"."profiles" validate constraint "profiles_district_id_fkey";

alter table "public"."profiles" add constraint "profiles_email_key" UNIQUE using index "profiles_email_key";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) ON DELETE CASCADE not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

alter table "public"."profiles" add constraint "profiles_phone_number_key" UNIQUE using index "profiles_phone_number_key";

alter table "public"."role_permissions" add constraint "role_permissions_code_format_check" CHECK ((permission_code ~ '^[a-z_]+[.][a-z_]+$'::text)) not valid;

alter table "public"."role_permissions" validate constraint "role_permissions_code_format_check";

alter table "public"."role_permissions" add constraint "role_permissions_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE not valid;

alter table "public"."role_permissions" validate constraint "role_permissions_role_id_fkey";

alter table "public"."roles" add constraint "roles_code_key" UNIQUE using index "roles_code_key";

alter table "public"."state_master" add constraint "state_master_state_code_key" UNIQUE using index "state_master_state_code_key";

alter table "public"."taluka_master" add constraint "taluka_master_district_id_fkey" FOREIGN KEY (district_id) REFERENCES public.district_master(id) ON DELETE CASCADE not valid;

alter table "public"."taluka_master" validate constraint "taluka_master_district_id_fkey";

alter table "public"."taluka_master" add constraint "taluka_master_taluka_code_key" UNIQUE using index "taluka_master_taluka_code_key";

alter table "public"."user_roles" add constraint "user_roles_assigned_by_fkey" FOREIGN KEY (assigned_by) REFERENCES public.profiles(id) ON DELETE SET NULL not valid;

alter table "public"."user_roles" validate constraint "user_roles_assigned_by_fkey";

alter table "public"."user_roles" add constraint "user_roles_role_id_fkey" FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE not valid;

alter table "public"."user_roles" validate constraint "user_roles_role_id_fkey";

alter table "public"."user_roles" add constraint "user_roles_user_id_fkey" FOREIGN KEY (user_id) REFERENCES public.profiles(id) ON DELETE CASCADE not valid;

alter table "public"."user_roles" validate constraint "user_roles_user_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.application_exists_for_link(app_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT EXISTS (
        SELECT 1
        FROM "public"."legal_aid_application"
        WHERE "id" = app_id
    );
$function$
;

CREATE OR REPLACE FUNCTION public.current_profile_status()
 RETURNS public.user_status_enum
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT p.status
    FROM public.profiles p
    WHERE p.id = auth.uid()
    LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.current_profile_user_type()
 RETURNS public.user_type_enum
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT p.user_type
    FROM public.profiles p
    WHERE p.id = auth.uid()
    LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.enforce_master_code_immutable()
 RETURNS trigger
 LANGUAGE plpgsql
AS $function$
BEGIN
    IF COALESCE(to_jsonb(NEW) ->> TG_ARGV[0], '') IS DISTINCT FROM COALESCE(to_jsonb(OLD) ->> TG_ARGV[0], '') THEN
        RAISE EXCEPTION '% of %.% is immutable (locked value: %)',
            TG_ARGV[0], TG_TABLE_SCHEMA, TG_TABLE_NAME, to_jsonb(OLD) ->> TG_ARGV[0];
    END IF;
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.fn_handle_application_status_change()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.forward_application(p_application_id uuid, p_target_district_id uuid)
 RETURNS public.legal_aid_application
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.generate_tracking_number()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_permission_codes()
 RETURNS TABLE(permission_code text)
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.get_my_profile()
 RETURNS public.profiles
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT *
    FROM public.profiles
    WHERE id = auth.uid()
    LIMIT 1;
$function$
;

CREATE OR REPLACE FUNCTION public.handle_new_user_signup()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.handle_updated_at()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.is_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.is_district_admin(dist_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.is_district_forward_party(p_application_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.is_geo_admin()
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.is_state_admin(p_state_id uuid)
 RETURNS boolean
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.link_guest_applications_on_profile()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
BEGIN
    IF NEW.phone_number IS NOT NULL THEN
        UPDATE public.legal_aid_application
        SET applicant_id = NEW.id
        WHERE applicant_phone_number = NEW.phone_number
          AND applicant_id IS NULL;
    END IF;

    RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.log_application_district_transfer()
 RETURNS trigger
 LANGUAGE plpgsql
 SET search_path TO ''
AS $function$
BEGIN
  IF auth.uid() IS NOT NULL THEN
    INSERT INTO public.application_forward_log
      (application_id, from_district_id, to_district_id, forwarded_by_id, reason)
    VALUES
      (NEW.id, OLD.current_district_id, NEW.current_district_id, auth.uid(), 'District transfer');
  END IF;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.submit_legal_aid_application(p_application jsonb)
 RETURNS jsonb
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO ''
AS $function$
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
$function$
;

CREATE OR REPLACE FUNCTION public.sync_user_type_from_admin_scope()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public', 'pg_temp'
AS $function$
DECLARE v_new_type user_type_enum;
BEGIN
  IF NEW.is_global_super_admin THEN v_new_type := 'SUPER_ADMIN';
  ELSIF NEW.scope_level = 'STATE' OR NEW.state_id IS NOT NULL THEN v_new_type := 'STATE_ADMIN';
  ELSIF NEW.scope_level = 'DISTRICT' OR NEW.district_id IS NOT NULL THEN v_new_type := 'DISTRICT_ADMIN';
  ELSE v_new_type := 'ADMIN'; END IF;
  UPDATE public.profiles SET user_type = v_new_type WHERE id = NEW.user_id AND user_type IN ('ADMIN','SUPER_ADMIN','STATE_ADMIN','DISTRICT_ADMIN') AND user_type <> v_new_type;
  RETURN NEW;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.track_application(p_tracking_number text, p_phone_number text)
 RETURNS SETOF public.legal_aid_application
 LANGUAGE sql
 STABLE SECURITY DEFINER
 SET search_path TO ''
AS $function$
    SELECT *
    FROM public.legal_aid_application
    WHERE tracking_number = p_tracking_number
      AND applicant_phone_number = p_phone_number
    LIMIT 1;
$function$
;

grant delete on table "public"."admin_scope" to "anon";

grant insert on table "public"."admin_scope" to "anon";

grant references on table "public"."admin_scope" to "anon";

grant select on table "public"."admin_scope" to "anon";

grant trigger on table "public"."admin_scope" to "anon";

grant truncate on table "public"."admin_scope" to "anon";

grant update on table "public"."admin_scope" to "anon";

grant delete on table "public"."admin_scope" to "authenticated";

grant insert on table "public"."admin_scope" to "authenticated";

grant references on table "public"."admin_scope" to "authenticated";

grant select on table "public"."admin_scope" to "authenticated";

grant trigger on table "public"."admin_scope" to "authenticated";

grant truncate on table "public"."admin_scope" to "authenticated";

grant update on table "public"."admin_scope" to "authenticated";

grant delete on table "public"."admin_scope" to "service_role";

grant insert on table "public"."admin_scope" to "service_role";

grant references on table "public"."admin_scope" to "service_role";

grant select on table "public"."admin_scope" to "service_role";

grant trigger on table "public"."admin_scope" to "service_role";

grant truncate on table "public"."admin_scope" to "service_role";

grant update on table "public"."admin_scope" to "service_role";

grant delete on table "public"."advocate_case_action_log" to "anon";

grant insert on table "public"."advocate_case_action_log" to "anon";

grant references on table "public"."advocate_case_action_log" to "anon";

grant select on table "public"."advocate_case_action_log" to "anon";

grant trigger on table "public"."advocate_case_action_log" to "anon";

grant truncate on table "public"."advocate_case_action_log" to "anon";

grant update on table "public"."advocate_case_action_log" to "anon";

grant delete on table "public"."advocate_case_action_log" to "authenticated";

grant insert on table "public"."advocate_case_action_log" to "authenticated";

grant references on table "public"."advocate_case_action_log" to "authenticated";

grant select on table "public"."advocate_case_action_log" to "authenticated";

grant trigger on table "public"."advocate_case_action_log" to "authenticated";

grant truncate on table "public"."advocate_case_action_log" to "authenticated";

grant update on table "public"."advocate_case_action_log" to "authenticated";

grant delete on table "public"."advocate_case_action_log" to "service_role";

grant insert on table "public"."advocate_case_action_log" to "service_role";

grant references on table "public"."advocate_case_action_log" to "service_role";

grant select on table "public"."advocate_case_action_log" to "service_role";

grant trigger on table "public"."advocate_case_action_log" to "service_role";

grant truncate on table "public"."advocate_case_action_log" to "service_role";

grant update on table "public"."advocate_case_action_log" to "service_role";

grant delete on table "public"."advocate_change_request" to "anon";

grant insert on table "public"."advocate_change_request" to "anon";

grant references on table "public"."advocate_change_request" to "anon";

grant select on table "public"."advocate_change_request" to "anon";

grant trigger on table "public"."advocate_change_request" to "anon";

grant truncate on table "public"."advocate_change_request" to "anon";

grant update on table "public"."advocate_change_request" to "anon";

grant delete on table "public"."advocate_change_request" to "authenticated";

grant insert on table "public"."advocate_change_request" to "authenticated";

grant references on table "public"."advocate_change_request" to "authenticated";

grant select on table "public"."advocate_change_request" to "authenticated";

grant trigger on table "public"."advocate_change_request" to "authenticated";

grant truncate on table "public"."advocate_change_request" to "authenticated";

grant update on table "public"."advocate_change_request" to "authenticated";

grant delete on table "public"."advocate_change_request" to "service_role";

grant insert on table "public"."advocate_change_request" to "service_role";

grant references on table "public"."advocate_change_request" to "service_role";

grant select on table "public"."advocate_change_request" to "service_role";

grant trigger on table "public"."advocate_change_request" to "service_role";

grant truncate on table "public"."advocate_change_request" to "service_role";

grant update on table "public"."advocate_change_request" to "service_role";

grant delete on table "public"."advocate_district_mapping" to "anon";

grant insert on table "public"."advocate_district_mapping" to "anon";

grant references on table "public"."advocate_district_mapping" to "anon";

grant select on table "public"."advocate_district_mapping" to "anon";

grant trigger on table "public"."advocate_district_mapping" to "anon";

grant truncate on table "public"."advocate_district_mapping" to "anon";

grant update on table "public"."advocate_district_mapping" to "anon";

grant delete on table "public"."advocate_district_mapping" to "authenticated";

grant insert on table "public"."advocate_district_mapping" to "authenticated";

grant references on table "public"."advocate_district_mapping" to "authenticated";

grant select on table "public"."advocate_district_mapping" to "authenticated";

grant trigger on table "public"."advocate_district_mapping" to "authenticated";

grant truncate on table "public"."advocate_district_mapping" to "authenticated";

grant update on table "public"."advocate_district_mapping" to "authenticated";

grant delete on table "public"."advocate_district_mapping" to "service_role";

grant insert on table "public"."advocate_district_mapping" to "service_role";

grant references on table "public"."advocate_district_mapping" to "service_role";

grant select on table "public"."advocate_district_mapping" to "service_role";

grant trigger on table "public"."advocate_district_mapping" to "service_role";

grant truncate on table "public"."advocate_district_mapping" to "service_role";

grant update on table "public"."advocate_district_mapping" to "service_role";

grant delete on table "public"."advocate_master" to "anon";

grant insert on table "public"."advocate_master" to "anon";

grant references on table "public"."advocate_master" to "anon";

grant select on table "public"."advocate_master" to "anon";

grant trigger on table "public"."advocate_master" to "anon";

grant truncate on table "public"."advocate_master" to "anon";

grant update on table "public"."advocate_master" to "anon";

grant delete on table "public"."advocate_master" to "authenticated";

grant insert on table "public"."advocate_master" to "authenticated";

grant references on table "public"."advocate_master" to "authenticated";

grant select on table "public"."advocate_master" to "authenticated";

grant trigger on table "public"."advocate_master" to "authenticated";

grant truncate on table "public"."advocate_master" to "authenticated";

grant update on table "public"."advocate_master" to "authenticated";

grant delete on table "public"."advocate_master" to "service_role";

grant insert on table "public"."advocate_master" to "service_role";

grant references on table "public"."advocate_master" to "service_role";

grant select on table "public"."advocate_master" to "service_role";

grant trigger on table "public"."advocate_master" to "service_role";

grant truncate on table "public"."advocate_master" to "service_role";

grant update on table "public"."advocate_master" to "service_role";

grant delete on table "public"."application_document" to "anon";

grant insert on table "public"."application_document" to "anon";

grant references on table "public"."application_document" to "anon";

grant select on table "public"."application_document" to "anon";

grant trigger on table "public"."application_document" to "anon";

grant truncate on table "public"."application_document" to "anon";

grant update on table "public"."application_document" to "anon";

grant delete on table "public"."application_document" to "authenticated";

grant insert on table "public"."application_document" to "authenticated";

grant references on table "public"."application_document" to "authenticated";

grant select on table "public"."application_document" to "authenticated";

grant trigger on table "public"."application_document" to "authenticated";

grant truncate on table "public"."application_document" to "authenticated";

grant update on table "public"."application_document" to "authenticated";

grant delete on table "public"."application_document" to "service_role";

grant insert on table "public"."application_document" to "service_role";

grant references on table "public"."application_document" to "service_role";

grant select on table "public"."application_document" to "service_role";

grant trigger on table "public"."application_document" to "service_role";

grant truncate on table "public"."application_document" to "service_role";

grant update on table "public"."application_document" to "service_role";

grant delete on table "public"."application_forward_log" to "anon";

grant insert on table "public"."application_forward_log" to "anon";

grant references on table "public"."application_forward_log" to "anon";

grant select on table "public"."application_forward_log" to "anon";

grant trigger on table "public"."application_forward_log" to "anon";

grant truncate on table "public"."application_forward_log" to "anon";

grant update on table "public"."application_forward_log" to "anon";

grant delete on table "public"."application_forward_log" to "authenticated";

grant insert on table "public"."application_forward_log" to "authenticated";

grant references on table "public"."application_forward_log" to "authenticated";

grant select on table "public"."application_forward_log" to "authenticated";

grant trigger on table "public"."application_forward_log" to "authenticated";

grant truncate on table "public"."application_forward_log" to "authenticated";

grant update on table "public"."application_forward_log" to "authenticated";

grant delete on table "public"."application_forward_log" to "service_role";

grant insert on table "public"."application_forward_log" to "service_role";

grant references on table "public"."application_forward_log" to "service_role";

grant select on table "public"."application_forward_log" to "service_role";

grant trigger on table "public"."application_forward_log" to "service_role";

grant truncate on table "public"."application_forward_log" to "service_role";

grant update on table "public"."application_forward_log" to "service_role";

grant delete on table "public"."application_status_history" to "anon";

grant insert on table "public"."application_status_history" to "anon";

grant references on table "public"."application_status_history" to "anon";

grant select on table "public"."application_status_history" to "anon";

grant trigger on table "public"."application_status_history" to "anon";

grant truncate on table "public"."application_status_history" to "anon";

grant update on table "public"."application_status_history" to "anon";

grant delete on table "public"."application_status_history" to "authenticated";

grant insert on table "public"."application_status_history" to "authenticated";

grant references on table "public"."application_status_history" to "authenticated";

grant select on table "public"."application_status_history" to "authenticated";

grant trigger on table "public"."application_status_history" to "authenticated";

grant truncate on table "public"."application_status_history" to "authenticated";

grant update on table "public"."application_status_history" to "authenticated";

grant delete on table "public"."application_status_history" to "service_role";

grant insert on table "public"."application_status_history" to "service_role";

grant references on table "public"."application_status_history" to "service_role";

grant select on table "public"."application_status_history" to "service_role";

grant trigger on table "public"."application_status_history" to "service_role";

grant truncate on table "public"."application_status_history" to "service_role";

grant update on table "public"."application_status_history" to "service_role";

grant delete on table "public"."case_type_document_map" to "anon";

grant insert on table "public"."case_type_document_map" to "anon";

grant references on table "public"."case_type_document_map" to "anon";

grant select on table "public"."case_type_document_map" to "anon";

grant trigger on table "public"."case_type_document_map" to "anon";

grant truncate on table "public"."case_type_document_map" to "anon";

grant update on table "public"."case_type_document_map" to "anon";

grant delete on table "public"."case_type_document_map" to "authenticated";

grant insert on table "public"."case_type_document_map" to "authenticated";

grant references on table "public"."case_type_document_map" to "authenticated";

grant select on table "public"."case_type_document_map" to "authenticated";

grant trigger on table "public"."case_type_document_map" to "authenticated";

grant truncate on table "public"."case_type_document_map" to "authenticated";

grant update on table "public"."case_type_document_map" to "authenticated";

grant delete on table "public"."case_type_document_map" to "service_role";

grant insert on table "public"."case_type_document_map" to "service_role";

grant references on table "public"."case_type_document_map" to "service_role";

grant select on table "public"."case_type_document_map" to "service_role";

grant trigger on table "public"."case_type_document_map" to "service_role";

grant truncate on table "public"."case_type_document_map" to "service_role";

grant update on table "public"."case_type_document_map" to "service_role";

grant delete on table "public"."case_type_master" to "anon";

grant insert on table "public"."case_type_master" to "anon";

grant references on table "public"."case_type_master" to "anon";

grant select on table "public"."case_type_master" to "anon";

grant trigger on table "public"."case_type_master" to "anon";

grant truncate on table "public"."case_type_master" to "anon";

grant update on table "public"."case_type_master" to "anon";

grant delete on table "public"."case_type_master" to "authenticated";

grant insert on table "public"."case_type_master" to "authenticated";

grant references on table "public"."case_type_master" to "authenticated";

grant select on table "public"."case_type_master" to "authenticated";

grant trigger on table "public"."case_type_master" to "authenticated";

grant truncate on table "public"."case_type_master" to "authenticated";

grant update on table "public"."case_type_master" to "authenticated";

grant delete on table "public"."case_type_master" to "service_role";

grant insert on table "public"."case_type_master" to "service_role";

grant references on table "public"."case_type_master" to "service_role";

grant select on table "public"."case_type_master" to "service_role";

grant trigger on table "public"."case_type_master" to "service_role";

grant truncate on table "public"."case_type_master" to "service_role";

grant update on table "public"."case_type_master" to "service_role";

grant delete on table "public"."district_master" to "anon";

grant insert on table "public"."district_master" to "anon";

grant references on table "public"."district_master" to "anon";

grant select on table "public"."district_master" to "anon";

grant trigger on table "public"."district_master" to "anon";

grant truncate on table "public"."district_master" to "anon";

grant update on table "public"."district_master" to "anon";

grant delete on table "public"."district_master" to "authenticated";

grant insert on table "public"."district_master" to "authenticated";

grant references on table "public"."district_master" to "authenticated";

grant select on table "public"."district_master" to "authenticated";

grant trigger on table "public"."district_master" to "authenticated";

grant truncate on table "public"."district_master" to "authenticated";

grant update on table "public"."district_master" to "authenticated";

grant delete on table "public"."district_master" to "service_role";

grant insert on table "public"."district_master" to "service_role";

grant references on table "public"."district_master" to "service_role";

grant select on table "public"."district_master" to "service_role";

grant trigger on table "public"."district_master" to "service_role";

grant truncate on table "public"."district_master" to "service_role";

grant update on table "public"."district_master" to "service_role";

grant delete on table "public"."document_master" to "anon";

grant insert on table "public"."document_master" to "anon";

grant references on table "public"."document_master" to "anon";

grant select on table "public"."document_master" to "anon";

grant trigger on table "public"."document_master" to "anon";

grant truncate on table "public"."document_master" to "anon";

grant update on table "public"."document_master" to "anon";

grant delete on table "public"."document_master" to "authenticated";

grant insert on table "public"."document_master" to "authenticated";

grant references on table "public"."document_master" to "authenticated";

grant select on table "public"."document_master" to "authenticated";

grant trigger on table "public"."document_master" to "authenticated";

grant truncate on table "public"."document_master" to "authenticated";

grant update on table "public"."document_master" to "authenticated";

grant delete on table "public"."document_master" to "service_role";

grant insert on table "public"."document_master" to "service_role";

grant references on table "public"."document_master" to "service_role";

grant select on table "public"."document_master" to "service_role";

grant trigger on table "public"."document_master" to "service_role";

grant truncate on table "public"."document_master" to "service_role";

grant update on table "public"."document_master" to "service_role";

grant delete on table "public"."legal_aid_application" to "anon";

grant insert on table "public"."legal_aid_application" to "anon";

grant references on table "public"."legal_aid_application" to "anon";

grant select on table "public"."legal_aid_application" to "anon";

grant trigger on table "public"."legal_aid_application" to "anon";

grant truncate on table "public"."legal_aid_application" to "anon";

grant update on table "public"."legal_aid_application" to "anon";

grant delete on table "public"."legal_aid_application" to "authenticated";

grant insert on table "public"."legal_aid_application" to "authenticated";

grant references on table "public"."legal_aid_application" to "authenticated";

grant select on table "public"."legal_aid_application" to "authenticated";

grant trigger on table "public"."legal_aid_application" to "authenticated";

grant truncate on table "public"."legal_aid_application" to "authenticated";

grant update on table "public"."legal_aid_application" to "authenticated";

grant delete on table "public"."legal_aid_application" to "service_role";

grant insert on table "public"."legal_aid_application" to "service_role";

grant references on table "public"."legal_aid_application" to "service_role";

grant select on table "public"."legal_aid_application" to "service_role";

grant trigger on table "public"."legal_aid_application" to "service_role";

grant truncate on table "public"."legal_aid_application" to "service_role";

grant update on table "public"."legal_aid_application" to "service_role";

grant delete on table "public"."legal_aid_category" to "anon";

grant insert on table "public"."legal_aid_category" to "anon";

grant references on table "public"."legal_aid_category" to "anon";

grant select on table "public"."legal_aid_category" to "anon";

grant trigger on table "public"."legal_aid_category" to "anon";

grant truncate on table "public"."legal_aid_category" to "anon";

grant update on table "public"."legal_aid_category" to "anon";

grant delete on table "public"."legal_aid_category" to "authenticated";

grant insert on table "public"."legal_aid_category" to "authenticated";

grant references on table "public"."legal_aid_category" to "authenticated";

grant select on table "public"."legal_aid_category" to "authenticated";

grant trigger on table "public"."legal_aid_category" to "authenticated";

grant truncate on table "public"."legal_aid_category" to "authenticated";

grant update on table "public"."legal_aid_category" to "authenticated";

grant delete on table "public"."legal_aid_category" to "service_role";

grant insert on table "public"."legal_aid_category" to "service_role";

grant references on table "public"."legal_aid_category" to "service_role";

grant select on table "public"."legal_aid_category" to "service_role";

grant trigger on table "public"."legal_aid_category" to "service_role";

grant truncate on table "public"."legal_aid_category" to "service_role";

grant update on table "public"."legal_aid_category" to "service_role";

grant delete on table "public"."legal_aid_category_document_map" to "anon";

grant insert on table "public"."legal_aid_category_document_map" to "anon";

grant references on table "public"."legal_aid_category_document_map" to "anon";

grant select on table "public"."legal_aid_category_document_map" to "anon";

grant trigger on table "public"."legal_aid_category_document_map" to "anon";

grant truncate on table "public"."legal_aid_category_document_map" to "anon";

grant update on table "public"."legal_aid_category_document_map" to "anon";

grant delete on table "public"."legal_aid_category_document_map" to "authenticated";

grant insert on table "public"."legal_aid_category_document_map" to "authenticated";

grant references on table "public"."legal_aid_category_document_map" to "authenticated";

grant select on table "public"."legal_aid_category_document_map" to "authenticated";

grant trigger on table "public"."legal_aid_category_document_map" to "authenticated";

grant truncate on table "public"."legal_aid_category_document_map" to "authenticated";

grant update on table "public"."legal_aid_category_document_map" to "authenticated";

grant delete on table "public"."legal_aid_category_document_map" to "service_role";

grant insert on table "public"."legal_aid_category_document_map" to "service_role";

grant references on table "public"."legal_aid_category_document_map" to "service_role";

grant select on table "public"."legal_aid_category_document_map" to "service_role";

grant trigger on table "public"."legal_aid_category_document_map" to "service_role";

grant truncate on table "public"."legal_aid_category_document_map" to "service_role";

grant update on table "public"."legal_aid_category_document_map" to "service_role";

grant delete on table "public"."modules" to "anon";

grant insert on table "public"."modules" to "anon";

grant references on table "public"."modules" to "anon";

grant select on table "public"."modules" to "anon";

grant trigger on table "public"."modules" to "anon";

grant truncate on table "public"."modules" to "anon";

grant update on table "public"."modules" to "anon";

grant delete on table "public"."modules" to "authenticated";

grant insert on table "public"."modules" to "authenticated";

grant references on table "public"."modules" to "authenticated";

grant select on table "public"."modules" to "authenticated";

grant trigger on table "public"."modules" to "authenticated";

grant truncate on table "public"."modules" to "authenticated";

grant update on table "public"."modules" to "authenticated";

grant delete on table "public"."modules" to "service_role";

grant insert on table "public"."modules" to "service_role";

grant references on table "public"."modules" to "service_role";

grant select on table "public"."modules" to "service_role";

grant trigger on table "public"."modules" to "service_role";

grant truncate on table "public"."modules" to "service_role";

grant update on table "public"."modules" to "service_role";

grant delete on table "public"."notifications" to "anon";

grant insert on table "public"."notifications" to "anon";

grant references on table "public"."notifications" to "anon";

grant select on table "public"."notifications" to "anon";

grant trigger on table "public"."notifications" to "anon";

grant truncate on table "public"."notifications" to "anon";

grant update on table "public"."notifications" to "anon";

grant delete on table "public"."notifications" to "authenticated";

grant insert on table "public"."notifications" to "authenticated";

grant references on table "public"."notifications" to "authenticated";

grant select on table "public"."notifications" to "authenticated";

grant trigger on table "public"."notifications" to "authenticated";

grant truncate on table "public"."notifications" to "authenticated";

grant update on table "public"."notifications" to "authenticated";

grant delete on table "public"."notifications" to "service_role";

grant insert on table "public"."notifications" to "service_role";

grant references on table "public"."notifications" to "service_role";

grant select on table "public"."notifications" to "service_role";

grant trigger on table "public"."notifications" to "service_role";

grant truncate on table "public"."notifications" to "service_role";

grant update on table "public"."notifications" to "service_role";

grant delete on table "public"."profiles" to "anon";

grant insert on table "public"."profiles" to "anon";

grant references on table "public"."profiles" to "anon";

grant select on table "public"."profiles" to "anon";

grant trigger on table "public"."profiles" to "anon";

grant truncate on table "public"."profiles" to "anon";

grant update on table "public"."profiles" to "anon";

grant delete on table "public"."profiles" to "authenticated";

grant insert on table "public"."profiles" to "authenticated";

grant references on table "public"."profiles" to "authenticated";

grant select on table "public"."profiles" to "authenticated";

grant trigger on table "public"."profiles" to "authenticated";

grant truncate on table "public"."profiles" to "authenticated";

grant update on table "public"."profiles" to "authenticated";

grant delete on table "public"."profiles" to "service_role";

grant insert on table "public"."profiles" to "service_role";

grant references on table "public"."profiles" to "service_role";

grant select on table "public"."profiles" to "service_role";

grant trigger on table "public"."profiles" to "service_role";

grant truncate on table "public"."profiles" to "service_role";

grant update on table "public"."profiles" to "service_role";

grant delete on table "public"."role_permissions" to "anon";

grant insert on table "public"."role_permissions" to "anon";

grant references on table "public"."role_permissions" to "anon";

grant select on table "public"."role_permissions" to "anon";

grant trigger on table "public"."role_permissions" to "anon";

grant truncate on table "public"."role_permissions" to "anon";

grant update on table "public"."role_permissions" to "anon";

grant delete on table "public"."role_permissions" to "authenticated";

grant insert on table "public"."role_permissions" to "authenticated";

grant references on table "public"."role_permissions" to "authenticated";

grant select on table "public"."role_permissions" to "authenticated";

grant trigger on table "public"."role_permissions" to "authenticated";

grant truncate on table "public"."role_permissions" to "authenticated";

grant update on table "public"."role_permissions" to "authenticated";

grant delete on table "public"."role_permissions" to "service_role";

grant insert on table "public"."role_permissions" to "service_role";

grant references on table "public"."role_permissions" to "service_role";

grant select on table "public"."role_permissions" to "service_role";

grant trigger on table "public"."role_permissions" to "service_role";

grant truncate on table "public"."role_permissions" to "service_role";

grant update on table "public"."role_permissions" to "service_role";

grant delete on table "public"."roles" to "anon";

grant insert on table "public"."roles" to "anon";

grant references on table "public"."roles" to "anon";

grant select on table "public"."roles" to "anon";

grant trigger on table "public"."roles" to "anon";

grant truncate on table "public"."roles" to "anon";

grant update on table "public"."roles" to "anon";

grant delete on table "public"."roles" to "authenticated";

grant insert on table "public"."roles" to "authenticated";

grant references on table "public"."roles" to "authenticated";

grant select on table "public"."roles" to "authenticated";

grant trigger on table "public"."roles" to "authenticated";

grant truncate on table "public"."roles" to "authenticated";

grant update on table "public"."roles" to "authenticated";

grant delete on table "public"."roles" to "service_role";

grant insert on table "public"."roles" to "service_role";

grant references on table "public"."roles" to "service_role";

grant select on table "public"."roles" to "service_role";

grant trigger on table "public"."roles" to "service_role";

grant truncate on table "public"."roles" to "service_role";

grant update on table "public"."roles" to "service_role";

grant delete on table "public"."state_master" to "anon";

grant insert on table "public"."state_master" to "anon";

grant references on table "public"."state_master" to "anon";

grant select on table "public"."state_master" to "anon";

grant trigger on table "public"."state_master" to "anon";

grant truncate on table "public"."state_master" to "anon";

grant update on table "public"."state_master" to "anon";

grant delete on table "public"."state_master" to "authenticated";

grant insert on table "public"."state_master" to "authenticated";

grant references on table "public"."state_master" to "authenticated";

grant select on table "public"."state_master" to "authenticated";

grant trigger on table "public"."state_master" to "authenticated";

grant truncate on table "public"."state_master" to "authenticated";

grant update on table "public"."state_master" to "authenticated";

grant delete on table "public"."state_master" to "service_role";

grant insert on table "public"."state_master" to "service_role";

grant references on table "public"."state_master" to "service_role";

grant select on table "public"."state_master" to "service_role";

grant trigger on table "public"."state_master" to "service_role";

grant truncate on table "public"."state_master" to "service_role";

grant update on table "public"."state_master" to "service_role";

grant delete on table "public"."taluka_master" to "anon";

grant insert on table "public"."taluka_master" to "anon";

grant references on table "public"."taluka_master" to "anon";

grant select on table "public"."taluka_master" to "anon";

grant trigger on table "public"."taluka_master" to "anon";

grant truncate on table "public"."taluka_master" to "anon";

grant update on table "public"."taluka_master" to "anon";

grant delete on table "public"."taluka_master" to "authenticated";

grant insert on table "public"."taluka_master" to "authenticated";

grant references on table "public"."taluka_master" to "authenticated";

grant select on table "public"."taluka_master" to "authenticated";

grant trigger on table "public"."taluka_master" to "authenticated";

grant truncate on table "public"."taluka_master" to "authenticated";

grant update on table "public"."taluka_master" to "authenticated";

grant delete on table "public"."taluka_master" to "service_role";

grant insert on table "public"."taluka_master" to "service_role";

grant references on table "public"."taluka_master" to "service_role";

grant select on table "public"."taluka_master" to "service_role";

grant trigger on table "public"."taluka_master" to "service_role";

grant truncate on table "public"."taluka_master" to "service_role";

grant update on table "public"."taluka_master" to "service_role";

grant delete on table "public"."user_roles" to "anon";

grant insert on table "public"."user_roles" to "anon";

grant references on table "public"."user_roles" to "anon";

grant select on table "public"."user_roles" to "anon";

grant trigger on table "public"."user_roles" to "anon";

grant truncate on table "public"."user_roles" to "anon";

grant update on table "public"."user_roles" to "anon";

grant delete on table "public"."user_roles" to "authenticated";

grant insert on table "public"."user_roles" to "authenticated";

grant references on table "public"."user_roles" to "authenticated";

grant select on table "public"."user_roles" to "authenticated";

grant trigger on table "public"."user_roles" to "authenticated";

grant truncate on table "public"."user_roles" to "authenticated";

grant update on table "public"."user_roles" to "authenticated";

grant delete on table "public"."user_roles" to "service_role";

grant insert on table "public"."user_roles" to "service_role";

grant references on table "public"."user_roles" to "service_role";

grant select on table "public"."user_roles" to "service_role";

grant trigger on table "public"."user_roles" to "service_role";

grant truncate on table "public"."user_roles" to "service_role";

grant update on table "public"."user_roles" to "service_role";


  create policy "admin_manage_admin_scope"
  on "public"."admin_scope"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "users_read_own_admin_scope"
  on "public"."admin_scope"
  as permissive
  for select
  to authenticated
using ((auth.uid() = user_id));



  create policy "advocates_insert_case_action_logs"
  on "public"."advocate_case_action_log"
  as permissive
  for insert
  to public
with check ((public.is_admin() OR (advocate_id IN ( SELECT a.id
   FROM public.advocate_master a
  WHERE (a.user_id = auth.uid())))));



  create policy "advocates_read_case_action_logs"
  on "public"."advocate_case_action_log"
  as permissive
  for select
  to public
using ((public.is_admin() OR (advocate_id IN ( SELECT a.id
   FROM public.advocate_master a
  WHERE (a.user_id = auth.uid())))));



  create policy "admin_manage_advocate_change_requests"
  on "public"."advocate_change_request"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "citizens_create_advocate_change_requests"
  on "public"."advocate_change_request"
  as permissive
  for insert
  to public
with check ((requested_by_citizen_id = auth.uid()));



  create policy "citizens_manage_own_advocate_change_requests"
  on "public"."advocate_change_request"
  as permissive
  for select
  to public
using (((requested_by_citizen_id = auth.uid()) OR public.is_admin()));



  create policy "admin_manage_advocate_district_mapping"
  on "public"."advocate_district_mapping"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_advocate_district_mapping"
  on "public"."advocate_district_mapping"
  as permissive
  for select
  to public
using (true);



  create policy "admin_delete_advocates"
  on "public"."advocate_master"
  as permissive
  for delete
  to public
using (public.is_admin());



  create policy "admin_insert_advocates"
  on "public"."advocate_master"
  as permissive
  for insert
  to public
with check (public.is_admin());



  create policy "advocates_update_own_profile"
  on "public"."advocate_master"
  as permissive
  for update
  to public
using (((user_id = auth.uid()) OR public.is_admin()))
with check (((user_id = auth.uid()) OR public.is_admin()));



  create policy "public_view_active_advocates"
  on "public"."advocate_master"
  as permissive
  for select
  to public
using (((is_active = true) OR public.is_admin() OR (user_id = auth.uid())));



  create policy "access_documents_linked_to_authorized_applications"
  on "public"."application_document"
  as permissive
  for select
  to public
using ((public.is_admin() OR (EXISTS ( SELECT 1
   FROM public.legal_aid_application a
  WHERE (a.id = application_document.application_id)))));



  create policy "admin_delete_application_documents"
  on "public"."application_document"
  as permissive
  for delete
  to public
using (public.is_admin());



  create policy "admin_update_application_documents"
  on "public"."application_document"
  as permissive
  for update
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "insert_documents_for_authorized_applications"
  on "public"."application_document"
  as permissive
  for insert
  to anon, authenticated
with check ((public.is_admin() OR public.application_exists_for_link(application_id)));



  create policy "admin_insert_forward_logs"
  on "public"."application_forward_log"
  as permissive
  for insert
  to public
with check (public.is_geo_admin());



  create policy "admin_read_forward_logs"
  on "public"."application_forward_log"
  as permissive
  for select
  to public
using ((public.is_admin() OR (EXISTS ( SELECT 1
   FROM public.legal_aid_application a
  WHERE (a.id = application_forward_log.application_id))) OR (public.is_geo_admin() AND (EXISTS ( SELECT 1
   FROM public.admin_scope s
  WHERE ((s.user_id = auth.uid()) AND (s.district_id = application_forward_log.from_district_id)))))));



  create policy "admin_insert_status_history"
  on "public"."application_status_history"
  as permissive
  for insert
  to public
with check (public.is_geo_admin());



  create policy "admin_read_status_history"
  on "public"."application_status_history"
  as permissive
  for select
  to public
using ((public.is_admin() OR (EXISTS ( SELECT 1
   FROM public.legal_aid_application a
  WHERE (a.id = application_status_history.application_id)))));



  create policy "admin_manage_case_type_document_map"
  on "public"."case_type_document_map"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_case_type_document_map"
  on "public"."case_type_document_map"
  as permissive
  for select
  to public
using (true);



  create policy "admin_manage_case_type_master"
  on "public"."case_type_master"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_case_type_master"
  on "public"."case_type_master"
  as permissive
  for select
  to public
using (true);



  create policy "admin_manage_district_master"
  on "public"."district_master"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_district_master"
  on "public"."district_master"
  as permissive
  for select
  to public
using (true);



  create policy "admin_manage_document_master"
  on "public"."document_master"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_document_master"
  on "public"."document_master"
  as permissive
  for select
  to public
using (true);



  create policy "advocates_view_assigned_cases"
  on "public"."legal_aid_application"
  as permissive
  for select
  to public
using ((assigned_advocate_id IN ( SELECT a.id
   FROM public.advocate_master a
  WHERE (a.user_id = auth.uid()))));



  create policy "anyone_submit_applications"
  on "public"."legal_aid_application"
  as permissive
  for insert
  to anon, authenticated
with check (((applicant_id IS NULL) OR (applicant_id = auth.uid()) OR public.is_admin()));



  create policy "citizens_view_own_cases"
  on "public"."legal_aid_application"
  as permissive
  for select
  to public
using (((applicant_id = auth.uid()) OR (applicant_phone_number = ( SELECT p.phone_number
   FROM public.profiles p
  WHERE (p.id = auth.uid())))));



  create policy "citizens_withdraw_own_application"
  on "public"."legal_aid_application"
  as permissive
  for update
  to public
using ((applicant_id = auth.uid()))
with check (((applicant_id = auth.uid()) AND (is_withdrawn_by_citizen = true) AND (status = 'WITHDRAWN'::text)));



  create policy "district_admin_delete_district_applications"
  on "public"."legal_aid_application"
  as permissive
  for delete
  to public
using (public.is_district_admin(current_district_id));



  create policy "district_admin_forward_district_applications"
  on "public"."legal_aid_application"
  as permissive
  for update
  to public
using (public.is_district_admin(current_district_id))
with check (public.is_geo_admin());



  create policy "district_admin_insert_district_applications"
  on "public"."legal_aid_application"
  as permissive
  for insert
  to public
with check (public.is_district_admin(current_district_id));



  create policy "district_admin_view_district_applications"
  on "public"."legal_aid_application"
  as permissive
  for select
  to public
using ((public.is_district_admin(current_district_id) OR public.is_district_admin(applicant_district_id) OR public.is_district_forward_party(id)));



  create policy "state_and_super_admin_manage_applications"
  on "public"."legal_aid_application"
  as permissive
  for all
  to public
using ((public.is_admin() OR (public.current_profile_user_type() = ANY (ARRAY['STATE_ADMIN'::public.user_type_enum, 'SUPER_ADMIN'::public.user_type_enum]))))
with check ((public.is_admin() OR (public.current_profile_user_type() = ANY (ARRAY['STATE_ADMIN'::public.user_type_enum, 'SUPER_ADMIN'::public.user_type_enum]))));



  create policy "admin_manage_legal_aid_category"
  on "public"."legal_aid_category"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_legal_aid_category"
  on "public"."legal_aid_category"
  as permissive
  for select
  to public
using (true);



  create policy "admin_manage_category_document_map"
  on "public"."legal_aid_category_document_map"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_category_document_map"
  on "public"."legal_aid_category_document_map"
  as permissive
  for select
  to public
using (true);



  create policy "admin_manage_modules"
  on "public"."modules"
  as permissive
  for all
  to authenticated
using (public.is_admin())
with check (public.is_admin());



  create policy "read_visible_modules"
  on "public"."modules"
  as permissive
  for select
  to authenticated
using (((is_active = true) OR public.is_admin()));



  create policy "Citizens can update own notifications"
  on "public"."notifications"
  as permissive
  for update
  to authenticated
using ((auth.uid() = user_id))
with check ((auth.uid() = user_id));



  create policy "Citizens can view own notifications"
  on "public"."notifications"
  as permissive
  for select
  to authenticated
using ((auth.uid() = user_id));



  create policy "admin_delete_profiles"
  on "public"."profiles"
  as permissive
  for delete
  to public
using (public.is_admin());



  create policy "admin_insert_profiles"
  on "public"."profiles"
  as permissive
  for insert
  to public
with check (public.is_admin());



  create policy "users_update_own_profile_without_role_escalation"
  on "public"."profiles"
  as permissive
  for update
  to public
using (((auth.uid() = id) OR public.is_admin()))
with check ((public.is_admin() OR ((auth.uid() = id) AND (user_type = public.current_profile_user_type()) AND (status = public.current_profile_status()))));



  create policy "users_view_own_profile"
  on "public"."profiles"
  as permissive
  for select
  to public
using (((auth.uid() = id) OR public.is_admin() OR (public.current_profile_user_type() = ANY (ARRAY['DISTRICT_ADMIN'::public.user_type_enum, 'STATE_ADMIN'::public.user_type_enum, 'SUPER_ADMIN'::public.user_type_enum, 'ADMIN'::public.user_type_enum]))));



  create policy "admin_manage_role_permissions"
  on "public"."role_permissions"
  as permissive
  for all
  to authenticated
using (public.is_admin())
with check (public.is_admin());



  create policy "read_visible_role_permissions"
  on "public"."role_permissions"
  as permissive
  for select
  to authenticated
using ((public.is_admin() OR (EXISTS ( SELECT 1
   FROM public.roles r
  WHERE ((r.id = role_permissions.role_id) AND (r.is_active = true))))));



  create policy "admin_manage_roles"
  on "public"."roles"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_active_roles"
  on "public"."roles"
  as permissive
  for select
  to public
using ((is_active = true));



  create policy "admin_manage_state_master"
  on "public"."state_master"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_state_master"
  on "public"."state_master"
  as permissive
  for select
  to public
using (true);



  create policy "admin_manage_taluka_master"
  on "public"."taluka_master"
  as permissive
  for all
  to public
using (public.is_admin())
with check (public.is_admin());



  create policy "public_read_taluka_master"
  on "public"."taluka_master"
  as permissive
  for select
  to public
using (true);



  create policy "admin_manage_user_roles"
  on "public"."user_roles"
  as permissive
  for all
  to authenticated
using (public.is_admin())
with check (public.is_admin());



  create policy "user_roles_self_read"
  on "public"."user_roles"
  as permissive
  for select
  to authenticated
using ((user_id = auth.uid()));



  create policy "users_read_own_roles"
  on "public"."user_roles"
  as permissive
  for select
  to authenticated
using (((auth.uid() = user_id) OR public.is_admin()));


CREATE TRIGGER trg_sync_user_type_from_admin_scope AFTER INSERT OR UPDATE OF is_global_super_admin, state_id, district_id, scope_level ON public.admin_scope FOR EACH ROW EXECUTE FUNCTION public.sync_user_type_from_admin_scope();

CREATE TRIGGER set_advocate_updated_at BEFORE UPDATE ON public.advocate_master FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER case_type_master_code_immutable BEFORE UPDATE ON public.case_type_master FOR EACH ROW EXECUTE FUNCTION public.enforce_master_code_immutable('case_type_code');

CREATE TRIGGER district_master_code_immutable BEFORE UPDATE ON public.district_master FOR EACH ROW EXECUTE FUNCTION public.enforce_master_code_immutable('district_code');

CREATE TRIGGER document_master_code_immutable BEFORE UPDATE ON public.document_master FOR EACH ROW EXECUTE FUNCTION public.enforce_master_code_immutable('document_code');

CREATE TRIGGER set_legal_aid_application_updated_at BEFORE UPDATE ON public.legal_aid_application FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trg_application_district_transfer BEFORE UPDATE OF current_district_id ON public.legal_aid_application FOR EACH ROW WHEN ((old.current_district_id IS DISTINCT FROM new.current_district_id)) EXECUTE FUNCTION public.log_application_district_transfer();

CREATE TRIGGER trg_application_status_notification_insert AFTER INSERT ON public.legal_aid_application FOR EACH ROW WHEN (((new.status IS NOT NULL) AND (new.applicant_id IS NOT NULL))) EXECUTE FUNCTION public.fn_handle_application_status_change();

CREATE TRIGGER trg_application_status_notification_update AFTER UPDATE OF status ON public.legal_aid_application FOR EACH ROW WHEN ((old.status IS DISTINCT FROM new.status)) EXECUTE FUNCTION public.fn_handle_application_status_change();

CREATE TRIGGER trigger_set_tracking_number BEFORE INSERT ON public.legal_aid_application FOR EACH ROW WHEN (((new.tracking_number IS NULL) OR (new.tracking_number = ''::text))) EXECUTE FUNCTION public.generate_tracking_number();

CREATE TRIGGER legal_aid_category_code_immutable BEFORE UPDATE ON public.legal_aid_category FOR EACH ROW EXECUTE FUNCTION public.enforce_master_code_immutable('category_code');

CREATE TRIGGER set_modules_updated_at BEFORE UPDATE ON public.modules FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER send_notification_webhook AFTER INSERT ON public.notifications FOR EACH ROW EXECUTE FUNCTION supabase_functions.http_request('https://rzcubveosldxzcbvzidu.supabase.co/functions/v1/send-fcm-notification', 'POST', '{"Content-type":"application/json","Authorization":"Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InJ6Y3VidmVvc2xkeHpjYnZ6aWR1Iiwicm9sZSI6InNlcnZpY2Vfcm9sZSIsImlhdCI6MTc4NjUxMzg2NSwiZXhwIjoyMTAyMDg5ODY1fQ.dWZ03X2tKGdRkRWNc2ksXtxu6JHmQ17MPjRTfu2aXJk"}', '{}', '1000');

CREATE TRIGGER set_profiles_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER trigger_link_guest_applications AFTER INSERT OR UPDATE OF phone_number ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.link_guest_applications_on_profile();

CREATE TRIGGER set_roles_updated_at BEFORE UPDATE ON public.roles FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER state_master_code_immutable BEFORE UPDATE ON public.state_master FOR EACH ROW EXECUTE FUNCTION public.enforce_master_code_immutable('state_code');

CREATE TRIGGER taluka_master_code_immutable BEFORE UPDATE ON public.taluka_master FOR EACH ROW EXECUTE FUNCTION public.enforce_master_code_immutable('taluka_code');

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user_signup();


  create policy "anon_update_draft_documents"
  on "storage"."objects"
  as permissive
  for update
  to anon, authenticated
using (((bucket_id = 'legal-documents'::text) AND (name ~~ 'draft-uploads/%'::text)))
with check (((bucket_id = 'legal-documents'::text) AND (name ~~ 'draft-uploads/%'::text)));



  create policy "anon_upload_draft_documents"
  on "storage"."objects"
  as permissive
  for insert
  to anon, authenticated
with check (((bucket_id = 'legal-documents'::text) AND (name ~~ 'draft-uploads/%'::text)));



