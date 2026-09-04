# AiPlant — Documentation Index

> **Client / naya developer:** Pehle ye file dekho — UI aur Backend **alag tracks** hain.

---

## Status (Sep 2026)

| Track | Status | Kahan se shuru karein |
|-------|--------|------------------------|
| **UI (Flutter app)** | ✅ UI Phase 1–4 complete | [`UI/README.md`](UI/README.md) |
| **Backend (full plan)** | 📋 Documented — not built | [`BACKEND/README.md`](BACKEND/README.md) · start [`BACKEND/PLAN_URDU.md`](BACKEND/PLAN_URDU.md) |

**Abhi app:** Demo mode ON (`demoUiSuccess = true`) — UI test ke liye. Live AI abhi connected nahi.

---

## Do alag tracks — confuse mat karo

```
┌─────────────────────────────────────┐
│  UI TRACK (Flutter — ye repo)       │
│  Screens, flows, local validation   │
│  Garden, scan, water, snap          │
│  📁 docs/UI/                        │
└─────────────────────────────────────┘

┌─────────────────────────────────────┐
│  BACKEND TRACK (alag setup)         │
│  Node + Express + Mongo + Firebase  │
│  Plant.id, Gemini, Cloudinary/S3    │
│  POST /ai/identify, /ai/diagnose    │
│  📁 docs/BACKEND/                   │
└─────────────────────────────────────┘
```

**Rule:** UI developer sirf `docs/UI/` + `lib/` dekhe. Backend developer sirf `docs/BACKEND/` + apna backend repo.

---

## Quick links

### UI (complete)

| Doc | Purpose |
|-----|---------|
| [UI/README.md](UI/README.md) | UI track overview |
| [UI/UI_PHASES.md](UI/UI_PHASES.md) | UI-1 … UI-4 checklist (done) |
| [UI/APP_FLOW_SCAN_GARDEN_WATER.md](UI/APP_FLOW_SCAN_GARDEN_WATER.md) | Scan → Garden → Water flow |
| [UI/FLOW_CHECKLIST_URDU.md](UI/FLOW_CHECKLIST_URDU.md) | Urdu flow summary |

### Backend (next)

| Doc | Purpose |
|-----|---------|
| [BACKEND/README.md](BACKEND/README.md) | Backend track index |
| [BACKEND/PLAN_URDU.md](BACKEND/PLAN_URDU.md) | Short Urdu summary |
| [BACKEND/PROJECT_OVERVIEW.md](BACKEND/PROJECT_OVERVIEW.md) | App + saari features |
| [BACKEND/AUTHENTICATION.md](BACKEND/AUTHENTICATION.md) | Firebase Auth plan |
| [BACKEND/AI_AND_IMAGES.md](BACKEND/AI_AND_IMAGES.md) | Plant.id / Gemini / storage |
| [BACKEND/DATA_AND_APIS.md](BACKEND/DATA_AND_APIS.md) | Mongo + APIs |
| [BACKEND/ARCHITECTURE.md](BACKEND/ARCHITECTURE.md) | Stack + security + folders |
| [BACKEND/IMPLEMENTATION_PHASES.md](BACKEND/IMPLEMENTATION_PHASES.md) | Phase 1–13 |
| [BACKEND/BACKEND_MASHWARA.md](BACKEND/BACKEND_MASHWARA.md) | Plant API provider mashwara |
| [BACKEND/BACKEND_SETUP.md](BACKEND/BACKEND_SETUP.md) | Locked identify/diagnose contract |

### Shared (architecture — dono padhein)

| Doc | Purpose |
|-----|---------|
| [FLOW_DEVELOPER_APPROVED.md](FLOW_DEVELOPER_APPROVED.md) | Locked product rules (Identify ≠ Diagnose) |
| [SCANNER_PRODUCTION_CHECKLIST.md](SCANNER_PRODUCTION_CHECKLIST.md) | Production P0/P1 (live API ke baad) |

---

## App mein backend connect kahan hota hai

| Step | File |
|------|------|
| Repository swap | `lib/features/plant_scan/bindings/plant_scan_binding.dart` |
| Local demo | `lib/features/plant_scan/data/plant_identify_repository.dart` |
| API models (locked) | `lib/features/plant_scan/model/plant_identify_result.dart` |
| Upload rules | `lib/core/helpers/plant_image_upload.dart` |

Live connect ke baad: `demoUiSuccess = false`, `ApiPlantIdentifyRepository` register karo.

---

*Sep 2026 — UI alag, Backend alag.*
