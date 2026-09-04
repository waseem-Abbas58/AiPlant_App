# Backend Track

> **Ye folder:** Sirf **Backend / API** documentation.  
> **UI / Flutter:** [`../UI/README.md`](../UI/README.md) — alag track, already complete.  
> **Code:** Is Flutter repo mein backend implement **mat** karo. Alag repo: `AiPlant_Backend`.

---

## Status: ⏳ Not started (plan documented)

Flutter app **ready hai** UI se. Live AI / Firebase / Mongo **connected nahi**.

**Abhi app:** Demo mode ON (`demoUiSuccess = true`).

---

## Padhne ka order (full professional backend)

Client ne **Node.js + Express + MongoDB + Firebase Authentication** maanga. Poori UI ke hisaab se plan yahan hai:

| # | File | Kya milega |
|---|------|------------|
| 0 | [PLAN_URDU.md](PLAN_URDU.md) | Short Urdu summary |
| 1 | [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) | App kya hai, structure, **saari features** |
| 2 | [AUTHENTICATION.md](AUTHENTICATION.md) | Auth UI + Firebase Auth + Mongo user |
| 3 | [AI_AND_IMAGES.md](AI_AND_IMAGES.md) | Identify / diagnose / chat + storage |
| 4 | [DATA_AND_APIS.md](DATA_AND_APIS.md) | Mongo collections + endpoints |
| 5 | [ARCHITECTURE.md](ARCHITECTURE.md) | Stack, security, folder structure, final checklist |
| 6 | [IMPLEMENTATION_PHASES.md](IMPLEMENTATION_PHASES.md) | Phase 1–13 |

---

## Purane scan-proxy notes (abhi bhi valid contract)

Pehle sirf 2 AI endpoints sochay gaye thay (FastAPI). **Identify/diagnose JSON contract locked hai** — stack Node ho ya FastAPI.

| File | Kya milega |
|------|------------|
| [BACKEND_MASHWARA.md](BACKEND_MASHWARA.md) | Plant.id vs Pl@ntNet, hosting, cost |
| [BACKEND_SETUP.md](BACKEND_SETUP.md) | `POST /ai/identify`, `POST /ai/diagnose`, env, Flutter swap |
| [../FLOW_DEVELOPER_APPROVED.md](../FLOW_DEVELOPER_APPROVED.md) | Identify ≠ Diagnose, keys app mein nahi |

---

## Target architecture (recommended)

```
Flutter App
    ↓  Firebase Auth + HTTPS Bearer token
Node.js + Express
    ↓
MongoDB
    +  Firebase Admin
    +  Plant.id / Pl@ntNet     →  POST /ai/identify, /ai/diagnose
    +  Gemini                  →  POST /ai/chat
    +  Cloudinary / S3         →  images
```

**App mein keys kabhi nahi.**

---

## App contract (locked — scan)

| Endpoint | App model | File |
|----------|-----------|------|
| `POST /ai/identify` | `PlantIdentifyResult` | `plant_identify_result.dart` |
| `POST /ai/diagnose` | `PlantDiseaseHint` | `plant_identify_result.dart` |

Upload: JPEG/PNG, max **8 MB**, multipart field **`image`** (identify: multiple files allowed).

Flutter connect: `plant_scan_binding.dart` + `demoUiSuccess = false`.

---

## Alag repo

```
AiPlant_App/          ← Flutter (ye repo) — UI + docs
AiPlant_Backend/      ← Node.js + Express — naya repo
```

---

[← Documentation index](../README.md) · [UI track →](../UI/README.md)
