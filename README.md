# Nyaya Saathi — Sikkim SLSA Legal Aid App

**Nyaya Saathi** (न्याय साथी — "Companion of Justice") is a cross-platform Flutter application for the **Sikkim State Legal Services Authority (SLSA)**. It lets citizens apply for free legal aid, upload supporting documents, track their application status in real time, receive push notifications on status changes, and read legal-aid FAQs — in a bilingual (English / Nepali), accessibility-first interface.

The app is **citizen-facing only**: non-citizen accounts (advocates/officials) are signed out automatically. Advocate- and admin-side tooling is out of scope for this codebase.

---

## 🎯 Project Overview

Under the **Legal Services Authorities Act, 1987**, SLSA provides free legal aid to eligible citizens (e.g. women, children, SC/ST members, persons with disabilities, disaster/trafficking victims, and those with annual income below ₹3,00,000). Nyaya Saathi digitises the application journey end-to-end, replacing paper Forms A/B/C/D with a guided, mobile-first experience.

---

## ✨ Key Features

### Public experience (no login required)

- **One-Tap Eligibility Check** — an 11-question yes/no screening based on Section 12 criteria that maps the result to a legal-aid category and feeds it straight into the application.
- **Apply for Legal Aid** — a guided **5-step wizard** with CAPTCHA-verified submission and an auto-generated **A4 legal-aid form PDF**.
- **Application Tracking** — track any application **without an account** using the **Application (Tracking) Number + registered phone number**.
- **Draft Resumption** — the in-progress application auto-saves locally (Hive) after every step and reopens on the correct step, even after an app restart.
- **Bilingual onboarding** — English 🇬🇧 / Nepali 🇳🇵 selection on first launch.

### Citizen account & dashboard

- **Email/password authentication** (Supabase Auth) with **citizen-only role gating** — non-citizen accounts are auto-signed-out; suspended accounts are blocked.
- **Registration CAPTCHA** to prevent automated sign-ups.
- **Dashboard tabs** — Home, My Applications (live status badges), Notifications, Chat (SLSA FAQ), plus a Profile screen.
- **Realtime updates** — the application list, detail view, and notifications refresh instantly via Supabase Realtime (Postgres Change Streams).
- **Push Notifications** — Firebase Cloud Messaging (FCM) with deep-linking: tapping a status notification opens the exact application detail screen.

### Advocate change request (citizen-facing)

- From the application detail screen, a citizen can raise an **advocate change request** (`advocate_change_request`, status `PENDING`) for SLSA to review.

### Documents

- Upload via **file picker** or an **in-app camera scanner** with image cropping.
- Files stream directly to **Supabase Storage** (`legal-documents` bucket) during the wizard and are linked to the application on submit.

### Accessibility & localisation

- **Bilingual** — English & Nepali (custom `AppLocalizations` + `assets/translations/`).
- **Light / Dark themes** (Material 3, Google Fonts — Inter/Outfit) with adjustable font scaling (small/medium/large).

---

## 🔄 Application Workflow

### 1. Launch & routing (`main.dart` → `splash_screen.dart`)

1. `main()` loads environment variables from `.env` (`flutter_dotenv`) and initialises Supabase (`SUPABASE_URL` + publishable key).
2. Firebase is initialised inside a `try/catch` (the app runs without it, minus push notifications); `NotificationService` is started in the background.
3. Six providers are wired: Theme, Language, ApplyData, Draft, Auth, Application.
4. `SplashScreen` plays a ~1.4s logo animation while running initialisation in parallel (font preload, language init, draft load from Hive, session restore), enforcing a minimum visible splash time.
5. On first launch, a non-dismissible **LanguageSelectionModal** (English / Nepali) is shown.
6. Routing by session result:
   - `citizen` → `CitizenDashboardShell` (then consume any pending notification deep-link).
   - `non_citizen` → silent sign-out → `UnauthHomeScreen`.
   - `none` / error → `UnauthHomeScreen`.

### 2. Guest Home (`unauth_home_screen.dart`)

The hub for unauthenticated users (auto-redirects to the dashboard if a session already exists):

- **Draft Resumption Card** — shown when a saved draft exists (resume or discard).
- **One-Tap Eligibility Check** → `EligibilityCheckModal`.
- **Apply for Legal Aid** → starts/resumes the wizard.
- **Track Application** → guest tracking.
- **Register / Sign In** → auth screens.

### 3. Eligibility check & "who is this for" (`eligibility_check_modal.dart`, `apply_choice_modal.dart`)

1. The user answers up to 11 statutory questions; the first "Yes" marks them eligible and records the matching category.
2. On **Proceed**:
   - **Guest** → goes straight to Step 2 with the eligibility category preselected as the Step 1 category.
   - **Logged-in user** → sees a **Self / Others** chooser. **Self** auto-fills the form from the user's profile; **Others** opens a blank form.

### 4. Legal Aid Application Wizard (`apply_flow/`, 5 steps)

Hosted in `ApplyWizardScreen` with an animated progress bar and an `IndexedStack` of steps. The current `stepIndex` is persisted after every navigation.

| Step | Screen | What happens |
| ---- | ------ | ------------ |
| 1 | `Step1CategoryScreen` — *Eligibility Criteria* | Categories are fetched live from `legal_aid_category`. Selecting the **Women & Children** category auto-sets gender to *Female*. |
| 2 | `Step2ApplicantDetailsScreen` — *Applicant Details* | Full name, gender, DOB (wheel picker), village/town, district (`district_master`), and phone. For logged-in users these are **prefilled from the `profiles` row** (via `startNewDraft(profile: ...)`). |
| 3 | `Step3CaseTypeScreen` — *Case & Grievance* | Case type from `case_type_master`, plus grievance summary and relief sought. |
| 4 | `Step4DocumentUploadScreen` — *Document Upload* | Required documents = union of `legal_aid_category_document_map` + `case_type_document_map` for the chosen category/case type. Each document is captured via file picker or the camera scanner modal (`document_scanner_modal.dart` + `image_crop_editor.dart`) and **uploaded immediately** to the `legal-documents` bucket at `draft-uploads/{draftUuid}/{docCode}.jpg` (upsert). |
| 5 | `Step5ReviewSubmitScreen` — *Review & Submit* | Full review, a **declaration checkbox**, and an in-app **CAPTCHA**. On submit the app inserts into `legal_aid_application` (a DB trigger generates the tracking number), then links each uploaded file into `application_document`. |

**Submission detail:** logged-in users insert directly; **guests** call the `submit_legal_aid_application` SECURITY DEFINER RPC (so anonymous rows pass row-level security). After submit, `application_success_screen.dart` shows the generated **Tracking Number** (copy & share via `share_plus`) and links to tracking / dashboard.

**PDF:** `PdfGeneratorService.generateA4FormPdf(draft)` renders the application as a formatted **A4 legal-aid form** (Form A/B/C/D style, per Sikkim SLSA regulations) that can be printed/shared.

### 5. Draft lifecycle (`DraftProvider` + `HiveDraftService`)

```
"Apply" tapped ─→ create draft (uuid) ─→ every field edit auto-saves to Hive
       │                                  (category, applicant, case, grievance, docs, stepIndex)
       ├─ app killed/restarted ─→ loadDraft() at splash ─→ resume card on guest home
       ├─ successful submit ─→ draft cleared
       └─ discard ─→ Hive clearDraft()
```

Drafts with no user-entered data are purged on load so they never trigger a "resume" prompt.

### 6. Authentication (`auth_provider.dart`)

- **Register** (`register_screen.dart`): name, email, phone, password + **CAPTCHA** → Supabase `signUp`. Returns `citizen`, `confirmation_required`, or `error`; the CAPTCHA refreshes on failure.
- **Login** (`login_screen.dart`): Supabase password sign-in → fetch profile via the `get_my_profile()` RPC → role gate:
  - `user_type != CITIZEN` → error + **forced silent sign-out** ("Only citizens may use this application").
  - `status != ACTIVE` → "account suspended" error.
  - otherwise → profile cached, FCM token synced, routed to dashboard.
- **Session restore** at splash uses the same gate.
- **Auth listener**: on `signedIn`/`tokenRefreshed` → sync FCM token; on `signedOut` → clear profile.
- **Profile updates** (name, phone, email, DOB, gender, village/town, district) from `ProfileScreen` write back to `profiles`.

### 7. Citizen Dashboard (`citizen_dashboard_shell.dart`)

Bottom navigation with 4 tabs + a Profile entry:

| Tab | Details |
| --- | ------- |
| **Home** | Active/Resolved stat cards, draft resumption, One-Tap Eligibility Check, Apply, and Track actions. |
| **My Applications** | Submitted applications with status badges (`status_badge.dart`); a **Realtime channel** on `legal_aid_application` refreshes the list instantly. Tap → `ApplicationDetailScreen`: status timeline from `application_status_history` (also Realtime-subscribed), documents, and **advocate change request**. |
| **Notifications** | In-app list from the `notifications` table (rows created by the DB trigger on every status change), with unread tracking and tap-through to the application. |
| **Chat** | A static SLSA FAQ (8 Q&A on eligibility, cost, documents, Lok Adalat, etc.) plus SLSA contact/helpline info (Toll-free **15100 / 03592-205377**, `sikkim_slsa@live.com`, Gangtok address). |

An in-app changelog sheet is shown automatically after an app-version update.

### 8. Guest Tracking (`tracking_screen.dart`)

1. Choose a mode — **by district** (select district + enter remaining digits) or **direct** (enter the full Application Number).
2. Enter the **registered phone number**.
3. `ApplicationRepository.trackApplication()` calls the `track_application` RPC (with district-alias/number normalisation fallbacks) → shows a status badge + the full `ApplicationDetailScreen`. **No account, no OTP.**
4. Recent lookups are cached locally (SharedPreferences) for one-tap re-tracking.

### 9. Notifications & push pipeline

```
SLSA staff change an application status (Supabase dashboard / ops tool)
  └─ DB trigger fn_handle_application_status_change
       ├─ inserts a row into application_status_history
       └─ inserts a row into notifications (for the applicant)
            └─ row insert fires a Database Webhook → send-fcm-notification Edge Function (Deno;
               signs an FCM OAuth token from service-account secrets)
                 └─ Firebase Cloud Messaging → device
                      ├─ Foreground  → local heads-up notification
                      └─ Background/Terminated → system notification
                           └─ Tap → payload application_id / tracking number
                                → navigatorKey deep-link → ApplicationDetailScreen
                                (queued as pending if the navigator isn't ready yet)
```

### 10. Application status lifecycle

Stored on `legal_aid_application.status` (enforced by a `CHECK` constraint) and recorded in `application_status_history`:

```
SUBMITTED ─→ UNDER_REVIEW ─→ ADVOCATE_ASSIGNED ─→ RESOLVED
                   │
                   ├──→ REJECTED
                   └──→ WITHDRAWN
```

### 11. Guest → account linking

When a citizen registers (or a profile's phone number is set), the `link_guest_applications_on_profile` trigger links any previously-submitted anonymous applications to the new profile by matching phone number.

---

## 👤 User Roles & Permissions

This app supports a single end-user role: **Citizen**.

| Aspect | Behaviour |
| ------ | --------- |
| **Citizen** | Full access: apply, track, view own applications, receive notifications, manage profile, request advocate change. |
| **Non-citizen** (ADVOCATE / ADMIN / STAFF / DISTRICT_ADMIN / STATE_ADMIN / SUPER_ADMIN) | Blocked. On login or session restore, a non-citizen `profiles.user_type` triggers an automatic silent sign-out with an "Only citizens may use this application" message. |
| **Suspended** (`status != ACTIVE`) | Blocked with an "account suspended" message. |

Row-Level Security and the `roles` / `user_roles` / `role_permissions` / `admin_scope` tables exist in the schema to support the wider SLSA system (including official-side workflows), but this Flutter app only gates on `profiles.user_type == 'CITIZEN'` and `status == 'ACTIVE'`.

---

## 🛠️ Technology Stack

| Layer | Technology |
| ----- | ---------- |
| **Framework** | Flutter (Dart SDK `^3.12.2`) |
| **State Management** | Provider (`ChangeNotifier` + `ChangeNotifierProxyProvider`) |
| **Backend / Auth** | Supabase (`supabase_flutter`) — Auth, Postgres, Storage, Realtime, Edge Functions |
| **Push Notifications** | Firebase (`firebase_core`, `firebase_messaging`) + `flutter_local_notifications` |
| **Local Persistence** | Hive (drafts), SharedPreferences (preferences, recent searches, changelog) |
| **PDF Generation** | `pdf`, `printing`, `share_plus` |
| **Document Capture** | `file_picker`, `camera`, `image` (cropping) |
| **Configuration** | `flutter_dotenv` (`.env`) |
| **Localisation** | `flutter_localizations`, `intl`, custom JSON assets |
| **Theming & Fonts** | Material 3, `google_fonts` (Inter / Outfit) |
| **Misc** | `uuid`, `path_provider`, `flutter_spinkit`, `package_info_plus`, `pub_semver`, `flutter_launcher_icons`, `flutter_native_splash` |

---

## 📁 Project Structure

```
lib/
├── main.dart                          # Entry: dotenv, Supabase, Firebase init, provider wiring
├── core/
│   ├── config/supabase_config.dart    # Reads SUPABASE_URL / SUPABASE_ANON_KEY from .env
│   ├── constants/app_colors.dart      # Design tokens (primary blue, gold, semantic colors)
│   ├── localization/                  # Custom AppLocalizations (en/ne delegates)
│   ├── services/
│   │   ├── hive_draft_service.dart    # Local draft persistence (Hive + uuid)
│   │   ├── notification_service.dart  # FCM + local notifications + deep-link routing
│   │   └── pdf_generator_service.dart # A4 legal-aid form PDF generation
│   ├── theme/app_theme.dart           # Material 3 light/dark themes with Google Fonts
│   └── utils/                         # Tracking-number, district, date, phone & string helpers
├── data/
│   ├── local/                         # Static fallback option lists
│   ├── models/                        # District, taluka, document mapping, gender option
│   └── repositories/
│       ├── apply_repository.dart      # Master-data interface
│       ├── supabase_apply_repository.dart
│       ├── local_apply_repository.dart # Static/fallback implementation (not used at runtime)
│       └── application_repository.dart # Submit / track / upload / realtime subscriptions
├── models/                            # Application, draft, profile, notification, advocate…
├── providers/                         # ChangeNotifiers: Auth, Application, ApplyData, Draft, Theme, Language
├── screens/
│   ├── splash/                        # Animated splash + routing
│   ├── onboarding/                    # Language selection modal, SLSA info modal
│   ├── auth/                          # Login, Register (email/password + CAPTCHA)
│   ├── apply_flow/                    # Wizard shell, 5 step screens, success screen
│   └── citizen/                       # Dashboard shell, 4 tabs, profile, tracking, detail screens
└── widgets/                           # CAPTCHA box, eligibility & choice modals, document
                                       # picker/scanner, crop editor, status badge, etc.

assets/
├── images/                            # app logo, splash logo, SLSA emblem, branding assets
└── translations/                      # en.json and ne.json locale strings

supabase/
├── migrations/                        # Incremental SQL (remote schema)
└── functions/send-fcm-notification/   # Deno Edge Function that fans push notifications out

supabase-backup/
├── schema.sql                         # Full database schema (tables, functions, triggers, RLS)
└── data.sql                           # Seed/reference data

scripts/update_logo.py                 # Regenerates app icons, splash, and notification icons
```

---

## ☁️ Backend (Supabase + Firebase)

### Supabase (`supabase-backup/schema.sql`, `supabase-backup/data.sql`, `supabase/migrations/`)

- **Master data** — `state_master`, `district_master`, `taluka_master`, `legal_aid_category`, `case_type_master`, `document_master`, plus `legal_aid_category_document_map` / `case_type_document_map` mapping tables.
- **Users & roles** — `profiles` (citizen role + active flag used for login gating), `roles`, `user_roles`, `role_permissions`, `modules`, `admin_scope`, `advocate_master`, `advocate_district_mapping`.
- **Applications** — `legal_aid_application` (tracking number generated by a DB trigger; `applicant_id` auto-linked when logged in), `application_document`, `application_status_history`, `application_forward_log`, `advocate_case_action_log`.
- **Citizen requests** — `advocate_change_request` (raised from the application detail screen).
- **Messaging** — `notifications` (created by the status-change trigger; a row insert fires a Database Webhook to the FCM Edge Function).
- **Storage** — bucket `legal-documents` (`draft-uploads/{draftUuid}/{docCode}.jpg`).
- **Realtime** — Postgres Change Streams on `legal_aid_application`, `application_status_history`, and `notifications`.
- **Key functions/triggers** — `generate_tracking_number` (builds `SK-[DISTRICT]-[YY]-[SEQUENCE]`), `fn_handle_application_status_change` (writes status history + notifications), `submit_legal_aid_application` (guest submit RPC), `track_application` (guest tracking RPC), `get_my_profile`, `link_guest_applications_on_profile`, `handle_new_user_signup`.
- **Edge Function** — `supabase/functions/send-fcm-notification/` (Deno) signs FCM OAuth tokens from service-account secrets and delivers status-change notifications to devices.

> 💡 Firebase init is wrapped in a `try/catch`, so the app still runs (without push notifications) if Firebase isn't configured.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (Dart `^3.12.2` or compatible).
- A **Supabase project** with the schema applied. Use `supabase-backup/schema.sql` for the full schema and `supabase-backup/data.sql` for seed data (or the incremental files in `supabase/migrations/`).
- A **Firebase project** with FCM enabled (optional — the app runs without it, minus push notifications).

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/pranaigiri/nyaya-saathi-ui.git
cd nyaya-saathi-ui

# 2. Install dependencies
flutter pub get

# 3. Configure environment — create a .env file in the project root
#    (it is already listed as an asset in pubspec.yaml):
#      SUPABASE_URL=<your-supabase-project-url>
#      SUPABASE_ANON_KEY=<your-supabase-publishable-anon-key>

# 4. (Optional) Configure Firebase for push notifications:
#    - Android: place google-services.json in android/app/  (already present in this repo)
#    - iOS:     add GoogleService-Info.plist to ios/Runner/  (not present in this repo)

# 5. Run the app
flutter run
```

### Regenerating icons / splash

```bash
python scripts/update_logo.py   # regenerates app icons, native splash, and notification icons
```

### Platform Targets

Configured for **Android, iOS, Web, Windows, Linux, and macOS** (push notifications currently target Android/iOS).

---

## ⚙️ Configuration & Environment Variables

The app reads its backend configuration from a `.env` file in the project root (bundled as an asset):

| Variable | Description |
| -------- | ----------- |
| `SUPABASE_URL` | Your Supabase project URL. |
| `SUPABASE_ANON_KEY` | Your Supabase publishable (anon) key. |

> ⚠️ Do not commit real secrets. The checked-in `.env` in this repository contains a live Supabase URL and publishable key — rotate/replace them before sharing the project. Never expose the Supabase **service-role** key or Firebase service-account credentials in the app; those belong only to the Edge Function's server-side secrets.

---

## 🧪 Testing

```bash
flutter test
```

Tests cover draft persistence, application status handling, the tracking-number formatter, the icon resolver, and basic widget rendering (see the `test/` directory).

---

## 📜 Legal & Compliance Documents

- [PRIVACY_POLICY.md](PRIVACY_POLICY.md)
- [TERMS_OF_SERVICE.md](TERMS_OF_SERVICE.md)

---

## 📄 License

This project is for internal / government use by the Sikkim State Legal Services Authority.
_Legal Services Authorities Act, 1987_ — free legal aid for the citizens of Sikkim.

---

## ⚠️ Implementation Notes & Limitations

These reflect the **current** codebase (verified against source, not planned features):

- **Taluka selection is not in the applicant form.** The `taluka_master` table, `Taluka` model, and repository/provider `getTalukas(...)` exist, but the Step 2 UI does not collect a taluka, and the draft's `talukaId` is never populated by the form.
- **Preferred-advocate selection is not in the applicant form.** `getAdvocatesForDistrict(...)` and the `preferred_advocate_id` column exist in the data layer, but no screen lets a citizen pick a preferred advocate while applying. The only advocate-related action exposed to citizens is the **advocate change request** on the application detail screen.
- **Withdrawal is not exposed in the UI.** `ApplicationRepository.withdrawApplication(...)` exists, but no screen calls it; the `WITHDRAWN` status is only displayed, not citizen-triggerable from this app.
- **Step 2 has no email input.** Applicant details are name, gender, DOB, village/town, district, and phone. Email is taken from the signed-in user's profile only.
- **Chat is static.** The Chat tab shows hard-coded FAQ content and SLSA contact details — there is no backend or AI assistant behind it.
- **Push notifications.** Android Firebase config (`android/app/google-services.json`) is present; the iOS `GoogleService-Info.plist` is **not** in the repo, so iOS push is not configured out of the box. Firebase is optional and failure-safe.
- **Drafts are local only.** Draft auto-save uses on-device Hive and is not synced across devices or users.
- **Schema location.** The database schema lives in `supabase-backup/` (full schema + seed) and `supabase/migrations/` (incremental). There is no `supabase/v3/` directory.

