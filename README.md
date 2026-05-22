<div align="center">

# UniVolunteer

**Turn volunteer work into verified career credentials — powered by AI**


![iOS 17+](https://img.shields.io/badge/iOS-17%2B-black?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![SwiftUI](https://img.shields.io/badge/UI-SwiftUI-blue)
![Claude AI](https://img.shields.io/badge/AI-Claude%20API-purple)

</div>

---

## The Problem

Students volunteer. They show up, face pressure, adapt under fire, and grow in ways that never make it onto a CV. At best, a two-year commitment becomes a single line: *"Member, AIESEC Club, 2024."*

The experience happened. The growth happened. The proof just... didn't exist.

**UniVolunteer fixes this** by turning a student's own written reflection into specific, evidence-backed, institutionally verified life skills — ready to share on their CV.

---

## How It Works

```
Student logs activity
        ↓
Answers 3 guided reflection questions
        ↓
Claude AI extracts specific, evidence-backed skills
        ↓
Club supervisor reviews & verifies each skill
        ↑
Supervisor was provisioned by University Admin
(this is the trust chain that makes verification credible)
        ↓
Verified skills appear on the student's shareable CV
```

### The Three Reflection Questions

After every volunteer activity, the student answers:

1. **What did you specifically do?** — Walk us through a concrete moment.
2. **What was the hardest part? How did you handle it?**
3. **What would you do differently next time?**

These questions are deliberately designed to elicit specifics. Vague answers produce fewer skills; detailed ones produce precise, defensible credentials.

### The Trust Chain

The verification layer is what makes UniVolunteer credible rather than self-reported:

```
University Admin
      │  provisions supervisors per club
      ▼
Club Supervisor (authenticated, university-sanctioned)
      │  reviews extracted skills & evidence quotes
      ▼
Verified Skill (appears on student CV with verifier's name + club)
```

University admins onboard supervisors through a web dashboard. Supervisors can only verify skills for their authorized clubs. This institutional chain means employers can trust the credential wasn't self-awarded.

---

## Features

### Volunteer (Student) Flow

| Screen | What it does |
|---|---|
| **Onboarding** | 3-slide intro explaining the log → extract → verify loop |
| **Login** | Role selection (Volunteer or Supervisor) |
| **Activities** | List of all logged volunteer activities with status |
| **Add New** | Multi-step form: activity info → reflection → AI extraction → review |
| **Reflection** | 3 guided text prompts + optional photo attachment |
| **Extracting Skills** | Animated waiting screen while Claude API processes the reflection |
| **Skills Review** | Staggered card reveal of extracted skills; shows which supervisor will verify |
| **My CV** | Full profile: verified skills, pending skills, activity history, stats, share button |
| **Activity Detail** | Per-activity breakdown of skills and verification status |

### Supervisor Flow

| Screen | What it does |
|---|---|
| **Supervisor Home** | Dashboard of pending verifications filtered to authorized clubs |
| **Verification View** | Review individual skills with evidence quotes; approve, reject, or rename |
| **Recently Verified** | Log of recently completed verifications |

### AI Skill Extraction

- Calls **Claude** (`claude-sonnet-4-20250514`) via the Anthropic `/v1/messages` API
- Extracts **3–6 skills** per activity — specific, not generic
  - ✅ `"Bilingual Workshop Design"` — backed by: *"switching languages mid-sentence wasn't a weakness — it was actually keeping both groups engaged"*
  - ❌ ~~`"Communication"`~~
- Each skill includes:
  - **Name** — precise and defensible
  - **Evidence quote** — exact substring from the student's reflection
  - **Confidence level** — `Introduced` / `Practiced` / `Proficient`
- Gracefully falls back to curated mock skills when no API key is set (full demo still works)
- Enforces a minimum response delay for consistent UX feel

---

## Tech Stack

| Layer | Technology |
|---|---|
| Platform | iOS 17+ |
| Language | Swift 5.9 |
| UI Framework | SwiftUI |
| Architecture | MVVM-R with `@Observable` |
| Navigation | `NavigationStack` + `NavigationPath` |
| AI | Anthropic Claude API (`/v1/messages`) |
| Persistence | `JSONEncoder/Decoder` → `UserDefaults` |
| Project spec | [XcodeGen](https://github.com/yonaskolb/XcodeGen) via `app.yml` |
| Photos | `PhotosUI` (`PhotosPicker`) |

---

## Project Structure

```
ios/
├── app.yml                              # XcodeGen project spec
└── Sources/App/
    ├── UniVolunteerApp.swift            # Entry point; launch → onboarding → login → app flow
    ├── ContentView.swift                # Tab bar: Activities | Add New | My CV
    │
    ├── Models/
    │   ├── AppState.swift               # @Observable global state (user, activities, tabs)
    │   ├── User.swift                   # User + UserRole (volunteer / supervisor)
    │   ├── Club.swift                   # Club with authorized supervisor IDs
    │   ├── University.swift             # University with brand colors & gradients
    │   ├── ClubActivity.swift           # Core record: club, role, hours, reflections, skills
    │   └── ExtractedSkill.swift         # Skill with confidence level + verification status
    │
    ├── Services/
    │   ├── SkillExtractionService.swift # Claude API integration, prompt engineering, parsing
    │   ├── MockSkillProvider.swift      # Curated demo skills for API-less mode
    │   ├── ClubService.swift            # Static registry: universities, clubs, users
    │   └── HapticService.swift          # UIImpactFeedbackGenerator wrappers
    │
    ├── Storage/
    │   ├── PersistenceService.swift     # JSON encode/decode to UserDefaults
    │   └── SeedDataService.swift        # Pre-built demo activities across 3 universities
    │
    ├── Resources/
    │   ├── Color+Brand.swift            # Brand palette extension on Color
    │   └── Typography.swift             # ViewModifier helpers for consistent type styles
    │
    └── Views/
        ├── LaunchView.swift
        ├── OnboardingView.swift
        ├── LoginView.swift
        ├── ActivitiesView.swift
        ├── ActivityCardView.swift
        ├── ActivityDetailView.swift
        ├── ActivityInfoView.swift        # Step 1 of Add New: club, role, hours, date
        ├── AddNewView.swift              # NavigationStack orchestrating the add flow
        ├── ReflectionView.swift          # Step 2: 3 guided prompts + photo picker
        ├── ExtractingSkillsView.swift    # Step 3: animated loading while API runs
        ├── SkillsReviewView.swift        # Step 4: review extracted skills before saving
        ├── MyCVView.swift                # Full CV: profile, verified/pending skills, share
        ├── SupervisorHomeView.swift
        ├── SupervisorVerificationView.swift
        └── Components/
            └── ComboBoxField.swift       # Searchable dropdown used in activity info form
```

---

## Getting Started

### Prerequisites

- Xcode 15 or later
- iOS 17+ simulator or physical device
- [XcodeGen](https://github.com/yonaskolb/XcodeGen) (optional — only needed to regenerate the `.xcodeproj`)

### Installation

```bash
git clone https://github.com/RoaaAlsham/UniVoluteer.git
cd UniVoluteer/ios

# Optional: regenerate the Xcode project from app.yml
xcodegen generate

open UniVolunteer.xcodeproj
```

### Configuring AI Skill Extraction

The app calls the Anthropic Claude API for skill extraction. Find the `Config` struct (referenced in `SkillExtractionService.swift`) and set your key:

```swift
static let anthropicAPIKey = "sk-ant-..."
```

**Without a key**, the app automatically falls back to curated mock skills — the entire flow (log → extract → verify) is fully demoable without an API key.

**To force demo mode** regardless of key presence:

```swift
static let useCachedDemoResponse = true
```

---

## Demo Data

The app ships with seed activities pre-populated for a fictional student (**Ayşe Kaya**, Boğaziçi University, Class of 2026), with volunteer experiences spanning three Istanbul universities:

| University | Club | Role | Skills |
|---|---|---|---|
| Boğaziçi University | AIESEC Boğaziçi | Workshop Facilitator | Bilingual Workshop Design, Improvised Facilitation, Cross-Cultural Calibration |
| Fatih Sultan Mehmet Vakıf University | FSMVÜ Sosyal Sorumluluk Kulübü | Community Outreach Coordinator | Stakeholder Navigation, Venue Crisis Recovery, Program Sustainability Design |
| Altınbaş University | *(cross-university activity)* | — | — |

The seed data also includes multiple supervisors per university and a full set of clubs across all three institutions, making it straightforward to demo the full verification flow from both the volunteer and supervisor perspectives.

**To reset demo data:** triple-tap the avatar on the My CV screen.

---

## Design System

| Token | Value | Usage |
|---|---|---|
| `brandPrimary` | `#5B2C91` | Primary actions, verified skills, headings |
| `brandAccent` | `#F5B700` | Pending states, supervisor role |
| `brandSuccess` | `#2E7D5B` | Verified badges, confirmation states |
| `brandBg` | `#FAFAF7` | App background |

Colors are defined in `Color+Brand.swift` as `Color` extensions. Typography is handled via `ViewModifier` helpers in `Typography.swift` (`.largeTitleStyle()`, `.captionStyle()`, `.headlineStyle()`, etc.) for consistent styling across views.

---

## User Roles

| Role | Access | Provisioned by |
|---|---|---|
| **Volunteer** | Log activities, trigger AI extraction, view & share CV | Self-serve (any university email) |
| **Supervisor** | Verify/reject skills for authorized clubs | University Admin via web dashboard |

Supervisors are scoped to specific clubs — they can only act on verifications for clubs they've been explicitly authorized for. This scoping is enforced in `AppState` and displayed in the supervisor dashboard header.

---

## Limitations & Roadmap

The app was built for a hackathon. Known limitations for a production build:

- **Static data** — clubs, universities, and users are hardcoded in `ClubService`. A production version would replace this with a backend API.
- **Local persistence** — `UserDefaults` works for demo but doesn't sync across devices or users. Real cross-device verification would need a shared backend (e.g. CloudKit or a custom API).
- **No PDF export** — the CV view is shareable via a link string, but a proper PDF export is not yet implemented.
- **Single student demo** — the current seed data is scoped to one volunteer account. Multi-user support requires the backend layer.


**Team**
- [Roaa Alsham](https://www.linkedin.com/in/roaa-shalab-alsham-796415338/)
- [Tabarak Alsheikh](https://www.linkedin.com/in/tabarak-alsheikh)
