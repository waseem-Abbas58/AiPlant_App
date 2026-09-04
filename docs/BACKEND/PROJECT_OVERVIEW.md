# AI Plant App — Project Overview

> **Type:** Read-only audit (Sep 2026)  
> **App name in code:** `AI PlantApp` (`AppStrings.appName`)  
> **Package:** `ai_plant_app` v1.0.0  
> **Code changes:** none — documentation only

Legend:

| Label | Meaning |
|---|---|
| **EXISTING** | Present in the current Flutter project |
| **RECOMMENDED** | Suggested for a future Node.js + Express + MongoDB backend |
| **NOT PRESENT** | Not in the current project — do not assume it exists |

Related docs: [Authentication](AUTHENTICATION.md) · [AI & Images](AI_AND_IMAGES.md) · [Data & APIs](DATA_AND_APIS.md) · [Architecture](ARCHITECTURE.md) · [Phases](IMPLEMENTATION_PHASES.md)

---

## 1. What is this application?

**EXISTING:** A Flutter mobile app for plant identification, disease checking, garden care, and plant Q&A. It is a GetX feature-module app with a finished UI, local storage, and demo/fake AI responses.

There is **no live backend**, **no Firebase project wired in**, and **no live AI API**.

### Main purpose

Help a user:

1. Photograph a plant (or mushroom / weed / tree / diseased leaf) and get an identification.
2. Optionally run a **separate** disease diagnosis.
3. Save plants into **My Garden** with watering and care tasks.
4. Ask care questions via **Ask Botanist**.
5. Browse local catalogs (trending plants, diseases, tips, remedies, articles).
6. Optionally move to a **Premium** plan later.

### Problem it solves

*“What plant is this, is it sick, is it toxic, and how do I care for it?”* — then keep that plant on a watering/care schedule.

### Users

Home gardeners and indoor plant owners (Pakistan-first location list: Karachi, Lahore, Islamabad, plus a few international cities). The UI assumes phone camera use, optional pets/kids toxicity concerns, and a mix of free vs premium scans.

**NOT PRESENT:** Farmer/agriculture field mode, marketplace, social feed, weather dashboard, maps.

---

## 2. Current project structure

### Folder structure (EXISTING)

```
AiPlant_App/
  lib/
    main.dart
    app/                 # app shell: theme, routes, bindings, config
    core/                # constants, helpers, validators, services, error
    features/            # feature modules (GetX: view / controller / binding / model / data)
    shared/              # reusable widgets, camera, loaders, snackbars
  assets/                # images, icons, svg, lottie
  docs/
    UI/                  # UI track (marked complete)
    BACKEND/             # backend specs only — no server code
  android/  ios/  macos/ windows/  linux/  web/
```

### Feature folders that exist today

| Folder | Role |
|---|---|
| `splash` | First launch splash |
| `onboarding` | 4 intro pages |
| `authentication` | Login / signup / forgot / OTP / reset |
| `main_navigation` | 5-tab shell |
| `home` | Discover + catalogs + tools |
| `plant_scan` | Camera identify + diagnose |
| `my_garden` | Garden, water, tasks, finder, snaps |
| `chatbot` | Ask Botanist + voice call |
| `search` | In-app search |
| `quiz` | Weekly quiz |
| `suggestions` | Article detail |
| `subscription` | Premium plans UI |
| `profile` | Account, privacy, lock, legal |
| `settings` | Thin wrapper over profile screens |

**Deleted as standalone modules:** `articles`, `disease_detection`, `plant_details`, `reminder`. Their UI was absorbed into Home / Garden / Scan. Do not rebuild those as separate Flutter features.

### Architecture (EXISTING)

**GetX + feature-first.**

```
View  →  Controller (GetxController + .obs)
      →  Binding (Get.lazyPut / Get.put)
      →  Model + local data / repository
```

- App root: `GetMaterialApp` in `lib/app/my_app.dart`
- Initial route: `/splash`
- Global: `InitialBinding` registers `ProfileController` permanently
- `DependencyInjection.init()` is empty — no API client registered

### State management (EXISTING)

**GetX** (`get: ^4.7.2`): `Rx` / `Obx`, `GetxController`, `GetPage` bindings, `Get.find`.

Persistent local state:

- `SharedPreferences` — session, profile, garden snapshot, quiz score, notification toggles, app lock
- App documents folder — plant photos (`PlantImageStore`)

**NOT PRESENT:** Riverpod, Bloc, Provider, Hive, SQLite, remote cache layer.

### Routing / navigation (EXISTING)

**GetX named routes** in `AppPages` + `RouteNames`, plus many unnamed `NavigationHelper.to(() => SomeView())` pushes.

| Route | Screen |
|---|---|
| `/splash` | Splash |
| `/onboarding` | Onboarding |
| `/authentication` | Login |
| `/signup` | Signup |
| `/forgot-password` | Forgot password |
| `/otp-verification` | OTP |
| `/reset-password` | Reset password |
| `/password-reset-success` | Reset success |
| `/home` | Main 5-tab shell |
| `/plant-scan` | Scan (also a tab) |
| `/search` | Search |
| `/my-garden` | Garden (also a tab) |
| `/plant-finder` | Plant finder |
| `/chat` | Chat (also a tab) |
| `/subscription` | Premium |
| `/profile` | Profile (also a tab) |
| `/settings` | Settings (registered, **unused** from UI) |
| `/weekly-quiz` | Quiz welcome |
| `/suggestion-detail` | Article detail |

**Tab shell:** Home · Garden · Scan · Chat · Profile

**Startup:**

```
Splash (3s)
  → if session_logged_in → Home
  → else if onboarding_seen → Login
  → else → Onboarding → Login
```

Session is a boolean in SharedPreferences (`AppSession`). **No JWT / Firebase token.**

### Design system (EXISTING)

Under `lib/app/theme/` and `lib/shared/`:

- Theme tokens: colors, spacing, radius, shadows, sizes, borders, text theme, light + dark
- `flutter_screenutil` (375×812)
- Shared widgets: `CustomText`, `CustomButton`, `CustomTextField`, `CustomPasswordField`, `CustomSearchField`, `CustomContainer`, `CustomCard`, `CustomAppBar`, `CustomBottomNavigation`, images/SVG, snackbars, empty/error/no-internet, loaders, premium camera chrome

---

## 3. All features / modules

### Splash — EXISTING

See splash, then auto-route. No backend.

### Onboarding — EXISTING

4 pages — Identify, Disease, Care, Garden — then continue to login. No backend.

### Authentication — EXISTING (UI only)

Login, signup, forgot, OTP, reset, success. See [AUTHENTICATION.md](AUTHENTICATION.md).

### Home / Discover — EXISTING

Greet by name, search, garden care summary (if plants exist), plant tools, hardcoded catalogs, quiz, suggestions.

**Home tools:** Plant Identifier, Disease Identifier, Tree Identifier, Water Meter, Ask Botanist, Mushroom Identifier, Weed Identifier, Toxicity Identifier, Plant Finder, Plant Statistics.

**Hardcoded catalogs:** Trending plants, browse categories, home remedies, gardening tips, plant diseases, suggestion articles, weekly quiz card.

**NOT on Home:** Premium promo (Profile → Subscription only).

**Backend later:** Optional CMS. Not required for first launch if content stays in the app.

### Plant identification (Scan) — EXISTING (demo AI)

Camera or gallery; categories plant / mushroom / weed / disease / tree; up to 5 angles; quality + non-plant gate; processing; result or fail; save to garden / wishlist; ask botanist; start diagnose.

**Backend later: required.** Locked contract: `POST /ai/identify` → `PlantIdentifyResult`.

### Disease diagnosis — EXISTING (demo AI)

After identify, pick a symptom, take **new** health photos (identify photo is not reused), see disease result.

**Symptoms:** yellow_leaves, brown_spots, drooping, holes, white_coating, pests, other.

**Known Flutter gap:** UI collects 2 required + 1 optional photos and a `symptomId`, but the repository currently accepts **one** image and the result screen uses the **first** photo only. Backend should still accept **all health photos + `symptomId`**.

**Backend later: required.** Locked contract: `POST /ai/diagnose` → `PlantDiseaseHint`.

### Toxicity check — EXISTING (local catalog)

Search a small hardcoded list or scan with toxicity focus. Optional catalog API later. Authoritative toxicity should come from the plant ID provider, not an LLM.

### My Garden — EXISTING (local)

Add plants (scan or camera), groups, notes, care schedule, water/mist/fertilize/rotate/cut tasks, snooze, diary photos + notes, snap history, wishlist.

**Storage:** `GardenLocalStore` → SharedPreferences JSON `garden_local_v1`.

**Snap history note:** Successful **Scan-tab** identifies are recorded. The **Garden add-plant** identify path does **not** call `recordIdentifySnap`.

**Backend later: yes** if accounts should sync across devices.

### Water Meter — EXISTING (local)

Water status / gauge / last watered / next water. Driven by `PlantCareEngine` (location, pot, light, **calendar month**). Optional backend. **NOT PRESENT:** Weather API.

### Light Meter — EXISTING (on-device camera)

Luminance from preview frames. **No backend.**

### Plant Finder — EXISTING (local filter)

Filter by light, soil, pH, type, lifecycle. Optional catalog search later.

### Plant Statistics — EXISTING (derived locally)

Counts of identifies / care / diagnosis over month, 3 months, 6 months, all time. Diagnosis count is currently **0** (no diagnose history store). Optional analytics later.

### Ask Botanist (Chat) — EXISTING (local keyword replies)

Text, garden plant context, attach photo/file, voice-to-text, stickers, hints, history (pin/archive/search), rate replies, share.

Replies: `BotanistChat.replyFor()` keyword templates. Threads are **RAM only** (not written to SharedPreferences).

**Backend later: yes** for real AI + history sync.

### Botanist voice call — EXISTING (local STT + TTS)

Same reply engine. **NOT PRESENT:** real phone/WebRTC call.

### Search — EXISTING (local)

Tools, suggestion articles, garden plants. Voice query from home.

### Weekly Quiz — EXISTING (local)

3 hardcoded questions, score in SharedPreferences, share result. Optional CMS later.

### Suggestions / articles — EXISTING (hardcoded)

Lifestyle/care articles. Optional CMS (`Article` collection).

### Subscription / Premium — EXISTING (UI only)

7-day trial / $4.99 month / $29.99 year. Copy: **“Nothing is billed yet.”** Continue just goes back.

**Perks shown:** Unlimited identification, unlimited disease scans, ad-free, premium care reminders.

**NOT PRESENT:** StoreKit / Play Billing / Stripe / RevenueCat. **No `isPremium` gate** in scan/chat.

### Profile — EXISTING (local)

Name, email, garden name, location, photo; subscription; stats; notifications; privacy; about; copy local user id; log out; delete local data.

### Notifications preferences — EXISTING (toggles only)

Garden reminders (water/mist/fertilizer/rotate/cut), subscription, home tips/quiz, scan results, botanist replies.

**NOT PRESENT:** FCM, local notification scheduling, backend push.

### App lock / privacy — EXISTING (on-device)

6-digit passcode, optional biometric, lockout after failed attempts. Change-password UI is local snackbar only. Lock stays on-device.

### Settings — EXISTING

Same as Profile’s Notifications / Privacy / About. Route registered but **not linked from UI**.

### Standalone Reminder module — NOT PRESENT

Water/mist/etc. live **inside Garden + Profile notification toggles**.

---

## Honest current-state notes

1. `demoUiSuccess = true` — identify/diagnose return fake “Demo plant” / “Demo leaf spot”.
2. Login is a local boolean. Any valid email/password form opens Home.
3. Signup does not create a session.
4. OTP is `123456`.
5. Chat is keyword templates; history is in RAM only.
6. Garden/profile live on the phone only.
7. `dio` is in `pubspec.yaml` but **not imported anywhere**.
8. Existing older docs planned a **FastAPI** thin proxy with 2 AI routes. The full UI needs a larger Node API; those 2 routes are still the locked scan contract.
9. Do not assume weather, maps, live payments, email-verification screens, or Firebase — they are **not** in the project.

---

[← Backend index](README.md)
