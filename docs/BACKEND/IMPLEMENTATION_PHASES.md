# Backend Implementation Phases

> Customized to **this** app. Do not start coding in the Flutter repo until a phase explicitly says so.

Related: [Architecture](ARCHITECTURE.md) · [Data & APIs](DATA_AND_APIS.md) · [Authentication](AUTHENTICATION.md)

Older scan-proxy phases (B-0 … B-5) remain in [BACKEND_MASHWARA.md](BACKEND_MASHWARA.md). Those cover **only** identify/diagnose. The table below is the **full** professional backend order.

---

## Phase order

| Phase | Name | What |
|---|---|---|
| **1** | Backend foundation | New repo, Express, `/health`, Mongo, Docker, env, CORS, logging |
| **2** | Firebase Authentication | Admin verify token; `/users/sync` + `/users/me`; FlutterFire later |
| **3** | User / Profile | Name, garden name, location, photo URL, delete account |
| **4** | Identify API | `POST /ai/identify` matching `PlantIdentifyResult`; multi-image; turn off demo |
| **5** | Diagnose API | `POST /ai/diagnose` matching `PlantDiseaseHint` + all health photos + `symptomId` |
| **6** | Image storage | Cloudinary/S3; garden/avatar/diary; scan temp images |
| **7** | Garden sync | Plants, groups, care, water, snaps, wishlist, diary |
| **8** | Ask Botanist | `POST /ai/chat` via Gemini; persist threads |
| **9** | Notifications | FCM + preference API (only after garden schedules exist) |
| **10** | Catalog CMS (optional) | Articles, trending, diseases, finder, toxicity — or keep assets |
| **11** | Subscriptions | RevenueCat/store + Mongo plan + scan limits |
| **12** | Testing | Contract tests vs Dart JSON; 100+ real scans; calibrate 0.75 / 0.55 |
| **13** | Deployment | Staging URL first; then production HTTPS |

**P0 (must ship before production scan):** Phases 1, 4, 5, and 12 (scan slice). Product rules: [FLOW_DEVELOPER_APPROVED.md](../FLOW_DEVELOPER_APPROVED.md).

Do **Identify + Diagnose** before chat/premium.

---

## Phase 1 — Backend foundation

- Create **separate** `AiPlant_Backend` git repo
- Express app, `GET /health`
- Mongo connection
- Docker + `.env.example`
- CORS, request logging, 45s timeout config
- No Flutter changes

## Phase 2 — Firebase Authentication

- Firebase project + Admin SDK on Node
- `verifyIdToken` middleware
- `POST /v1/users/sync`, `GET /v1/users/me`
- FlutterFire (email/password, Google, Apple) is a **later Flutter task**, not this docs-only work

## Phase 3 — User / Profile

- PATCH profile fields already in the UI
- Photo URL (after Phase 6, or placeholder)
- DELETE account → Firebase + Mongo cleanup

## Phase 4 — Identify API

- `POST /ai/identify` — **all images, one request**
- Map provider → `PlantIdentifyResult` (`isLocalPreview: false`)
- Flutter: add `ApiPlantIdentifyRepository`, set `demoUiSuccess = false`

## Phase 5 — Diagnose API

- `POST /ai/diagnose` — health photos + `plantName` + `symptomId`
- Map → `PlantDiseaseHint`
- Flutter follow-up: send **all** diagnose photos + `symptomId` (today only first photo is used)

## Phase 6 — Image storage

- Cloudinary or S3
- Signed uploads for garden / avatar / diary
- Short-lived storage for AI request images

## Phase 7 — Garden sync

- Snapshot or REST matching `GardenLocalSnapshot`
- Keep `PlantCareEngine` on-device unless you later want server-side next-water dates

## Phase 8 — Ask Botanist

- `POST /ai/chat` with Gemini
- Persist threads (today history is RAM only)
- Ground replies with plant context; do not invent species/toxicity

## Phase 9 — Notifications

- Save preference map (`ProfileNotifications` ids)
- FCM device tokens
- Care reminders at `reminderTime`

## Phase 10 — Catalog CMS (optional)

Only if you want to edit home content without an app release. App already ships static catalogs.

## Phase 11 — Subscriptions

- Plans already in UI: 7-day trial, $4.99 / month, $29.99 / year
- No billing SDK in the app yet
- Add `isPremium` gates after store integration

## Phase 12 — Testing

- Contract tests: response parses as `PlantIdentifyResult.fromJson` / `PlantDiseaseHint.fromJson`
- Offline / timeout / server error ≠ “no plant”
- 100+ real phone scans; calibrate confidence
- Multi-angle: 2–3 photos, one result

## Phase 13 — Deployment

- Staging URL first (`https://api-staging...`)
- Production HTTPS
- Flutter `--dart-define=API_BASE_URL=...`

---

## Client decisions still open

```
☐ Plant API provider: Plant.id / Pl@ntNet / hybrid
☐ Hosting: Railway / Render / Fly / AWS / VPS
☐ Image storage: Cloudinary / S3 / Firebase Storage
☐ Chat LLM: Gemini (recommended) / OpenAI
☐ Diagnose in first launch or phase 2
☐ Keep 6-digit OTP UI vs Firebase reset email
☐ Facebook login: keep or hide
☐ Backend alag repo: Haan (recommended)
```

---

[← Backend index](README.md)
