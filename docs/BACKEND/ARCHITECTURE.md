# Flutter → Backend Architecture

Related: [Project Overview](PROJECT_OVERVIEW.md) · [Authentication](AUTHENTICATION.md) · [AI & Images](AI_AND_IMAGES.md) · [Data & APIs](DATA_AND_APIS.md) · [Phases](IMPLEMENTATION_PHASES.md)

Older scan-only notes: [BACKEND_MASHWARA.md](BACKEND_MASHWARA.md) · [BACKEND_SETUP.md](BACKEND_SETUP.md)

---

## 1. Target architecture

Adjusted to **what is actually in the project** + the requested stack (Node.js + Express + MongoDB + Firebase Auth):

```
Flutter App (GetX UI — this repo)
    │  Firebase Auth SDK (email / Google / Apple)
    │  HTTPS + Bearer ID token
    ▼
Node.js + Express REST API  (new repo)
    │
    ├─► MongoDB
    │     users, garden, scans, chats, subscriptions, catalogs
    │
    ├─► Firebase Admin
    │     verify ID token, delete user, optional FCM, optional claims
    │
    ├─► Plant.id / Pl@ntNet
    │     POST /ai/identify
    │     POST /ai/diagnose
    │
    ├─► Gemini (chat only)
    │     POST /ai/chat
    │
    └─► Cloudinary or S3
          plant / garden / avatar / chat images
```

**On-device (keep):** photo quality, scene gate, preprocess, light meter, care-interval math, app lock, quiz (until CMS).

**Existing older docs** described only FastAPI → Plant API. That is still the **scan** slice. The rest of the UI needs the broader Node API above. Identify/diagnose JSON contracts stay locked.

**Connect point already reserved in Flutter:** swap `LocalPlantIdentifyRepository` for `ApiPlantIdentifyRepository` in `plant_scan_binding.dart`, set `demoUiSuccess = false`. Chat has no repository interface yet.

**Alag repo (recommended):**

```
AiPlant_App/        ← this Flutter repo — UI only
AiPlant_Backend/    ← Node.js + Express — new repo, do not create inside Flutter
```

---

## 2. Third-party APIs / services

Only services that match **this** app:

| Service/API | Purpose | Required? | Recommended option | Reason |
|---|---|---|---|---|
| Firebase Authentication | Login / signup / reset / social | **Yes** | Firebase Auth | UI already has email + social |
| Plant identification API | Species + similar + care + toxicity | **Yes** for live scan | **Plant.id** (or Pl@ntNet if budget-only ID) | App already designed for this |
| Plant disease API | Diagnose | **Yes** for live diagnose | Plant.id disease module | Separate from identify |
| Text/vision LLM | Ask Botanist | **Yes** for live chat | **Gemini Flash** | Multimodal + cost; must not replace Plant API |
| Image storage | Garden / avatar / chat / scan images | **Yes** if cloud sync | **Cloudinary** (or S3) | Transforms + CDN |
| Firebase Admin SDK | Verify tokens, delete users | **Yes** with Firebase Auth | firebase-admin on Node | Backend must trust ID tokens |
| Push notifications | Care / quiz / plan / scan / chat toggles | Later | **FCM** | Prefs exist; delivery does not |
| Payment / subscription | Trial / $4.99 / $29.99 | Later | **RevenueCat** + Play/App Store | Mobile IAP UI; “nothing billed yet” |
| Weather API | Watering | **No** | — | No weather UI; engine uses month only |
| Maps / Places API | Location | **No** | — | Location is a typed city string |
| OpenAI (primary ID) | Species ID | **No** | — | Dedicated plant APIs are more suitable |
| Twilio / SMS | Phone login | **No** | — | No phone auth UI |

---

## 3. Security requirements (future)

- **Firebase ID token verification** on every user/garden/AI route
- Optional `X-App-Key` only as a weak extra, never instead of user auth
- **Env vars only** for Plant.id, Gemini, Mongo, Firebase service account, Cloudinary
- **Never** put AI keys in Flutter / `--dart-define` production secrets
- **Image upload:** JPEG/PNG only, 8 MB, size checks, signed URLs, strip EXIF if needed
- **Rate limits:** `/ai/*` especially (paid upstream)
- **Validation:** `categoryId`, `symptomId`, care enums, OTP length
- **Timeouts:** 45s identify/diagnose; max **1 retry**
- HTTPS, CORS locked to the app, no `*` in production
- Account delete: Firebase user + Mongo + stored images
- Toxicity / mushroom / treatment: provider data only; show “unavailable” if null
- Do not log raw images or full tokens
- Premium gates later: check subscription before unlimited scans

---

## 4. Recommended Node.js + Express folder structure

Do **not** create this inside the Flutter repo.

```
AiPlant_Backend/
  src/
    config/                 # env, mongo, firebase-admin, cors
    routes/
      health.routes.js
      user.routes.js
      garden.routes.js
      scan.routes.js
      identify.routes.js    # POST /ai/identify
      diagnose.routes.js    # POST /ai/diagnose
      chat.routes.js
      catalog.routes.js     # plants, diseases, articles, toxicity
      quiz.routes.js
      subscription.routes.js
      upload.routes.js
      notification.routes.js
    controllers/
    services/
      plantId.service.js    # Plant.id / Pl@ntNet client
      gemini.service.js     # chat only
      storage.service.js
      fcm.service.js
      subscription.service.js
    mappers/
      identify.mapper.js    # provider → PlantIdentifyResult
      diagnose.mapper.js    # provider → PlantDiseaseHint
    models/                 # mongoose
      user.model.js
      gardenPlant.model.js
      gardenGroup.model.js
      gardenSnap.model.js
      gardenWishlist.model.js
      gardenDiary.model.js
      plantScan.model.js
      diseaseDetection.model.js
      chatThread.model.js
      article.model.js
      subscription.model.js
      deviceToken.model.js
    middleware/
      auth.middleware.js    # verify Firebase token
      upload.middleware.js
      rateLimit.middleware.js
      error.middleware.js
      validate.middleware.js
    repositories/
    utils/
    jobs/                   # optional reminder cron
  tests/
  Dockerfile
  .env.example
  README.md
```

---

## 5. Final backend plan checklist

### A. Features found in current app

Splash, onboarding, login/signup/forgot/OTP/reset, 5-tab home, plant/mushroom/weed/tree/disease scan, multi-angle identify, diagnose-by-symptom, toxicity list, My Garden (groups, care, water, tasks, diary, snaps, wishlist), water meter, light meter, plant finder, plant statistics, Ask Botanist + voice call, search, weekly quiz, suggestion articles, home catalogs, subscription UI, profile/privacy/app lock/FAQ/legal, local notification toggles.

### B. Backend modules required

Health, Auth/User, Identify, Diagnose, Garden, Uploads, Chat, Notifications (later), Catalog (optional), Quiz (optional), Subscription (later).

### C. MongoDB models required

User, GardenPlant, GardenGroup, GardenSnap, GardenWishlist, GardenDiary, PlantScan, DiseaseDetection, ChatThread/ChatMessage; later Subscription, DeviceToken, Article/PlantCatalog/DiseaseCatalog/Quiz if content leaves the app.

### D. API modules required

`/health`, `/v1/users`, `/ai/identify`, `/ai/diagnose`, `/ai/chat`, `/v1/garden/*`, `/v1/scans`, `/v1/chats`, `/v1/uploads`; later notifications, catalog, subscription.

### E. Firebase services required

**Auth (yes).** Admin SDK (yes). FCM (later). Storage (optional). Firestore (**no** as primary DB).

### F. AI APIs recommended

- **Plant.id** (or Pl@ntNet) for identify + diagnose
- **Gemini Flash** for Ask Botanist
- **Not** Gemini/OpenAI as the species identifier

### G. Storage recommendation

**Cloudinary** (default) or **S3**. Device store stays for offline. Firebase Storage optional.

### H. Third-party APIs required

Firebase Auth, Plant.id/Pl@ntNet, Gemini, Cloudinary/S3, Firebase Admin; later FCM + RevenueCat. **Not** weather or maps.

### I. Recommended Node.js/Express architecture

Flutter → Express → MongoDB + Firebase Admin + Plant.id + Gemini + Cloudinary/S3. Separate backend repo. Flutter stays UI-only.

### J. Recommended implementation phases

See [IMPLEMENTATION_PHASES.md](IMPLEMENTATION_PHASES.md).

---

[← Backend index](README.md)
