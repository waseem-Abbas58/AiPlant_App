# Data Models & API Requirements

> **Recommendations only.** Do not create Mongo models or implement these endpoints in this Flutter repo.

Related: [Project Overview](PROJECT_OVERVIEW.md) · [AI & Images](AI_AND_IMAGES.md) · [Architecture](ARCHITECTURE.md)

Auth default: Firebase **ID token** in `Authorization: Bearer <idToken>` unless noted.

---

## 1. MongoDB collections (based on existing UI)

| Collection | Why it appears necessary | Source in UI |
|---|---|---|
| **User** | Name, email, garden name, location, photo, local user id | Profile |
| **GardenPlant** | Saved plants + care schedule | `GardenPlant`, `GardenCareSchedule` |
| **GardenGroup** | Groups / rooms | `GardenGroup` |
| **GardenSnap** | Successful identify history | `GardenSnap` |
| **GardenWishlist** | “Save for later” | `GardenWishlistItem` |
| **GardenDiary** | Photo + note per plant | `GardenDiaryEntry` |
| **GardenTask** | Water/mist/fertilizer/rotate/cut completions | `GardenTask` + `completedKeys` |
| **PlantScan** | Identify request/result, `scanId`, fail reasons | Identify models |
| **DiseaseDetection** | Diagnose request/result, `symptomId` | `PlantDiseaseHint` |
| **ChatThread / ChatMessage** | History, pin, archive, plant context | Chat models |
| **Article** | Suggestion articles if moved off assets | `SuggestionArticle` |
| **PlantCatalog** | Trending, categories, finder, toxicity list | Home / finder models |
| **DiseaseCatalog** | Home disease encyclopedia | `PlantDisease` |
| **Tip / Remedy** | Home tips & remedies | Hardcoded catalogs |
| **Quiz / QuizAttempt** | Weekly quiz if server-driven | `WeeklyQuiz` |
| **Subscription** | Trial / monthly / yearly | Subscription UI + notify prefs |
| **NotificationPreference** | Toggle map already defined | `ProfileNotifications` |
| **DeviceToken** | Only if FCM is added | Notify UI implies it |

**NOT needed from current UI:** Weather, MapPlace, SocialPost, Order, FarmField.

Care math (`PlantCareEngine`) can stay on-device; persist the schedule fields, not every derived date.

### Garden plant fields already in the app

`id`, `name`, `imagePath`, `scientificName`, `groupId`, `notes`, `status`, `createdAt`, plus care: `waterDays`, `mistDays`, `fertilizerMonths`, `rotateMonths`, `cutMonths`, `waterAmount`, `location` (Indoor/Outdoor/Patio), `potSize`, `lightLevel`, `syncCalendar`, `autoReminders`, `waterTime`, `lastWateredAt`, `nextWaterOn`.

---

## 2. Locked AI response shapes

Backend **must** map third-party output to these Dart models (`plant_identify_result.dart`).

### Identify — `PlantIdentifyResult`

```json
{
  "commonName": "Peace Lily",
  "scientificName": "Spathiphyllum wallisii",
  "confidence": 0.82,
  "careHighlights": ["When top soil is dry", "Bright, indirect"],
  "similarMatches": [
    { "commonName": "...", "scientificName": "...", "confidence": 0.61 }
  ],
  "kind": "plant",
  "toxicity": {
    "toxicToPets": true,
    "toxicToKids": false,
    "summary": "..."
  },
  "care": {
    "waterDays": 7,
    "lightLevel": "Bright indirect",
    "waterAmount": "Moderate",
    "syncCalendar": true
  },
  "isIdentified": true,
  "failReason": "none",
  "isLocalPreview": false
}
```

`imagePath` is set on the app side. `kind`: `plant` | `tree` | `mushroom` | `weed` | `disease` | `unknown`.

### Diagnose — `PlantDiseaseHint`

```json
{
  "healthy": false,
  "title": "Leaf spots — possible fungal issue",
  "diseaseName": "Leaf spot",
  "summary": "...",
  "confidence": 0.74,
  "kind": "Fungus",
  "severity": "Moderate",
  "symptoms": ["..."],
  "steps": ["..."],
  "prevention": "...",
  "caution": "...",
  "isLocalPreview": false,
  "failReason": "none"
}
```

Do **not** merge species ID and leaf disease into one response.

---

## 3. Suggested endpoints

### System

| Method | Example | Purpose | Auth |
|---|---|---|---|
| GET | `/health` | Liveness | No |

### Auth / User

| Method | Example | Purpose | Request | Response | Auth |
|---|---|---|---|---|---|
| POST | `/v1/users/sync` | Create/update Mongo user after Firebase login | `{ displayName? }` | User | Firebase |
| GET | `/v1/users/me` | Profile | — | User | Yes |
| PATCH | `/v1/users/me` | Edit name, gardenName, location, photoUrl | profile fields | User | Yes |
| DELETE | `/v1/users/me` | Delete account + data | — | `{ ok }` | Yes |
| POST | `/v1/auth/password-reset/otp` | If you keep 6-digit OTP UI | `{ email }` | `{ sent: true }` | No |
| POST | `/v1/auth/password-reset/verify` | Verify OTP | `{ email, otp }` | `{ resetToken }` | No |

### Plants / catalog (optional CMS)

| Method | Example | Purpose | Auth |
|---|---|---|---|
| GET | `/v1/plants/trending` | Home trending | Optional |
| GET | `/v1/plants/:id` | Plant detail | Optional |
| GET | `/v1/plants/finder` | Filter light/soil/ph/type | Optional |
| GET | `/v1/diseases` | Disease encyclopedia | Optional |
| GET | `/v1/articles` | Suggestions | Optional |
| GET | `/v1/toxicity?q=` | Toxicity search | Optional |
| GET | `/v1/search?q=` | Tools + catalog + user garden | Yes |

### Plant identification

| Method | Example | Purpose | Request | Response | Auth |
|---|---|---|---|---|---|
| POST | `/ai/identify` | Species ID | multipart `image`×N, `categoryId`, `scanId` | `PlantIdentifyResult` | Yes |
| GET | `/v1/scans` | User scan history | query | list | Yes |

Upload: JPEG/PNG, max **8 MB** each, field name **`image`** (repeat for multiple angles). Timeout **45s**.

### Disease detection

| Method | Example | Purpose | Request | Response | Auth |
|---|---|---|---|---|---|
| POST | `/ai/diagnose` | Leaf disease | `image`×N, `plantName`, `symptomId` | `PlantDiseaseHint` | Yes |

### AI questions

| Method | Example | Purpose | Request | Response | Auth |
|---|---|---|---|---|---|
| POST | `/ai/chat` | Botanist reply | `{ threadId?, plantId?, text, imageUrl? }` | `{ reply, threadId }` | Yes |
| GET | `/v1/chats` | Threads | — | list | Yes |
| GET | `/v1/chats/:id` | Messages | — | messages | Yes |
| PATCH/DELETE | `/v1/chats/:id` | Pin / archive / delete | flags | thread | Yes |

### My Garden

| Method | Example | Purpose | Auth |
|---|---|---|---|
| GET/PUT | `/v1/garden` | Full snapshot sync | Yes |
| POST | `/v1/garden/plants` | Add plant | Yes |
| PATCH/DELETE | `/v1/garden/plants/:id` | Edit / remove | Yes |
| POST | `/v1/garden/groups` | Create group | Yes |
| POST | `/v1/garden/plants/:id/water` | Mark watered | Yes |
| POST | `/v1/garden/plants/:id/diary` | Diary entry | Yes |
| GET | `/v1/garden/snaps` | Snap history | Yes |
| GET | `/v1/garden/wishlist` | Wishlist | Yes |

### Reminders

| Method | Example | Purpose | Auth |
|---|---|---|---|
| GET/PUT | `/v1/users/me/notifications` | Preference map | Yes |
| POST | `/v1/devices` | FCM token | Yes |

Scheduling can be backend cron + FCM, or local notifications. UI only has toggles + a reminder time.

### Subscription

| Method | Example | Purpose | Auth |
|---|---|---|---|
| GET | `/v1/subscription` | Current plan | Yes |
| POST | `/v1/subscription/webhook` | Store/RevenueCat webhook | Secret |
| POST | `/v1/subscription/restore` | Restore | Yes |

---

## 4. Error mapping (scan)

| Backend | App `IdentifyFailReason` |
|---|---|
| Timeout | `timeout` |
| 503 / upstream down | `serverError` |
| No network (client) | `offline` (app detects) |
| Not a plant | Prefer app local gate; API `noMatch` if unsure |

API down ≠ “No plant detected” — the app already has separate UI copy.

---

[← Backend index](README.md)
