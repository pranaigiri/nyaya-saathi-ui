# Nyaya Saathi — Sikkim SLSA Legal Aid App

**Nyaya Saathi** (न्याय साथी — "Companion of Justice") is a cross-platform Flutter application built for the **Sikkim State Legal Services Authority (SLSA)**. It enables citizens of Sikkim to discover their eligibility, apply for free legal aid, upload supporting documents, track application status in real time, and communicate with SLSA authorities — all in a multilingual, accessibility-first interface.

---

## 🎯 Purpose

Under the **Legal Services Authorities Act, 1987**, Sikkim SLSA provides free legal services to eligible citizens (persons with annual income below ₹3,00,000, women & children, SC/ST members, persons with disabilities, and victims of disasters/ethnic violence). Nyaya Saathi digitises the application journey end-to-end, replacing paper forms (A/B/C/D) with a guided mobile-first experience.

---

## ✨ Key Features

### 🏠 Citizen Public Experience

- **One-tap Eligibility Check** — Browse legal aid categories with income limits and descriptions.
- **Apply for Legal Aid** — A guided 5-step wizard:
  1. **Eligibility & Category** selection (General, Women & Children, SC/ST, Differently Abled, Disaster/Violence victims)
  2. **Applicant Details** (name, gender, DOB, address, district, email, phone)
  3. **Case & Grievance** (case type, grievance summary, relief sought)
  4. **Document Upload** — Identity, income, caste, disability, FIR, death certificate etc. via file picker or **in-app camera scanner** (with image cropping)
  5. **Review & Submit** — auto-generates a formatted **A4 PDF Form** (Form A/B/C/D) reflecting the Sikkim State Legal Services Regulations
- **Application Tracking** — Track an application _without an account or OTP_ using the application number + DOB (or last 4 digits of phone).
- **Draft Resumption** — In-progress applications are auto-saved locally; users can resume from exactly where they left off.

### 👤 Citizen Dashboard (logged in)

- **Home tab** — Overview of applications and quick actions.
- **My Applications** — List of submitted applications with live status badges (e.g., `SUBMITTED`, `APPROVED_SLSA`, `CASE_IN_PROGRESS`).
- **Notifications** — Status updates and SLSA announcements.
- **Chat** — Direct messaging with the SLSA helpdesk with simulated assistant responses.
- **Profile** — View and manage profile settings.

### ⚖️ Advocate Dashboard

- Assigned case list and detailed case view (applicant, category, case type, documents).

### 🌍 Accessibility & Localisation

- **Bilingual** — English 🇬🇧 and **Nepali 🇳🇵** (i18n via `assets/translations/`).
- **Light / Dark themes** (Material 3) with **adjustable font scaling** (small / medium / large) for better readability.

---

## 🏗️ Architecture

```
lib/
├── main.dart                     # App entry, provider wiring, Supabase init
├── core/
│   ├── constants/app_colors.dart # Design tokens (primary blue, gold, semantic colors)
│   ├── localization/             # Custom AppLocalizations (en/ne delegates)
│   ├── services/
│   │   ├── supabase_service.dart # Backend client + in-memory mock fallback
│   │   ├── hive_draft_service.dart # Local persistence (SharedPreferences + draft store)
│   │   └── pdf_generator_service.dart # A4 legal aid form PDF generation
│   └── theme/app_theme.dart      # Material 3 light/dark themes with Google Fonts
├── models/                       # Data models (application, category, case type, document, draft, notification, chat)
├── providers/                    # ChangeNotifiers (Auth, Draft, Theme, Language)
├── screens/
│   ├── splash/                   # Splash + first-launch language/info modals
│   ├── onboarding/               # Language selection, SLSA info
│   ├── auth/                     # Citizen / Advocate login (simulated)
│   ├── citizen/                  # Landing, dashboard shell + tabs (home, applications, notifications, chat), tracking, profile, app detail
│   ├── apply_flow/               # 5-step application wizard + success screen
│   └── advocate/                 # Advocate dashboard + case details
└── widgets/                      # Reusable widgets (status badge, stat card, document picker/scanner, draft resumption card, image crop)
```

### Backend (Supabase)

The `supabase/migrations/` directory contains the PostgreSQL schema for:

- **Master data** — `state_master`, `district_master`, `legal_aid_category`, `case_type_master`, `document_master`, plus `category_document_map` / `case_type_document_map` mapping tables.
- **Users & roles** — `roles`, `profiles`, `citizen_details`, `advocate_master`.
- **Applications** — `legal_aid_application` with full status lifecycle (`DRAFT → SUBMITTED → UNDER_SCRUTINY → ACTION_REQUIRED → REJECTED → APPROVED_SLSA → ASSIGNED_TO_ADVOCATE → ADVOCATE_ACCEPTED → CASE_IN_PROGRESS → CLOSED → WITHDRAWN`).
- **Tracking & messaging** — `tracking_attempt_log`, notification and chat infrastructure.

> 💡 **Note:** When no live Supabase client is available, the app gracefully falls back to a seeded in-memory mock dataset so it can run standalone for development/demo purposes.

---

## 🛠️ Tech Stack

| Layer                 | Technology                                                                                    |
| --------------------- | --------------------------------------------------------------------------------------------- |
| **Framework**         | Flutter (Dart SDK ^3.12.2)                                                                    |
| **State Management**  | Provider                                                                                      |
| **Backend / Auth**    | Supabase (`supabase_flutter`)                                                                 |
| **Local Persistence** | SharedPreferences, Hive                                                                       |
| **PDF Generation**    | `pdf`, `printing`, `share_plus`                                                               |
| **Document Capture**  | `file_picker`, `camera`, `image`                                                              |
| **Localisation**      | `flutter_localizations`, `intl`, custom JSON assets                                           |
| **Theming & Fonts**   | Material 3, `google_fonts` (Inter / Outfit)                                                   |
| **Misc**              | `uuid`, `path_provider`, `flutter_spinkit`, `flutter_launcher_icons`, `flutter_native_splash` |

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK `^3.12.2` (or compatible)
- A Supabase project (optional — app runs with mock data without it)

### Installation

```bash
# 1. Clone the repository
git clone https://github.com/pranaigiri/nyaya-saathi-ui.git
cd nyaya-saathi-ui

# 2. Install dependencies
flutter pub get

# 3. (Optional) Configure Supabase
#    Update Supabase URL / anon key in your environment or init code.

# 4. Run the app
flutter run
```

### Platform Targets

The app is configured for **Android**, **iOS**, **Web**, **Windows**, **Linux**, and **macOS**.

---

## 🧪 Testing

```bash
flutter test
```

Tests cover the draft persistence and basic widget rendering (`test/draft_provider_test.dart`, `test/widget_test.dart`).

---

## 📁 Project Assets & Scripts

- `assets/images/` — app logo, splash logo, and other branding assets.
- `assets/translations/` — `en.json` and `ne.json` locale strings.
- `scripts/update_logo.py` — utility for regenerating app icons.
- `supabase/migrations/` — SQL schema for the SLSA backend.

---

## 📄 License

This project is for internal / government use by the Sikkim State Legal Services Authority.  
_Legal Services Authorities Act, 1987_ — Free legal aid for the citizens of Sikkim.
