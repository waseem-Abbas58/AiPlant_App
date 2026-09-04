# Backend Mashwara — AiPlant API Setup

> **Audience:** Client, backend developer, tech lead  
> **UI track (alag):** [`../UI/README.md`](../UI/README.md) — UI complete, touch mat karo jab tak mashwara clear na ho

---

## 1. Summary — kya banana hai

**Ek chhota backend proxy** — Flutter app direct Plant API ko call **nahi** karegi.

```
[Flutter App]  →  [Aapka Backend]  →  [Plant.id / Pl@ntNet / etc.]
                      ↑
                 API keys yahan
                 rate limit, logging
                 response → app JSON format
```

**Sirf 2 endpoints chahiye abhi:**

| Endpoint | Kab call hota hai | App screen |
|----------|-------------------|------------|
| `POST /ai/identify` | Scan / gallery → identify | Processing → Result |
| `POST /ai/diagnose` | Diagnose flow → health photos | Disease result |

**Identify aur Diagnose alag** — ek response mein species + disease merge mat karo.

---

## 2. Provider mashwara (Plant API kaun sa?)

### Option A — **Plant.id / Kindwise** (recommended agar budget hai)

| | |
|---|---|
| **Best for** | Identify + disease + toxicity ek ecosystem |
| **Multi-photo** | Haan (same plant, multiple angles) |
| **Pros** | Care, toxicity, disease modules; commercial support |
| **Cons** | Paid; pricing plan choose karna hoga |
| **When pick** | Client ko production quality + disease chahiye, budget OK |

### Option B — **Pl@ntNet**

| | |
|---|---|
| **Best for** | Species identify, cost-sensitive |
| **Multi-photo** | Haan (up to ~5 images, same organ/plant) |
| **Pros** | Strong open dataset; free tier / API options |
| **Cons** | Disease/toxicity alag solution chahiye |
| **When pick** | Pehle sirf identify ship karna, budget kam |

### Option C — **Hybrid**

| Step | Provider |
|------|----------|
| Identify | Pl@ntNet ya Plant.id |
| Diagnose | Plant.id disease module ya dedicated disease API |
| Toxicity / care | Plant.id ya manual curated DB baad mein |

**Hamari recommendation (typical client):**

1. **Phase 1 launch:** Plant.id **ya** Pl@ntNet identify only  
2. **Phase 2:** Diagnose endpoint alag wire (Plant.id disease)  
3. **Confidence thresholds:** 100–500 real phone scans ke baad calibrate — abhi hard-code mat karo

---

## 3. Hosting mashwara

| Option | Cost | Best for |
|--------|------|----------|
| **Railway / Render / Fly.io** | Low start | MVP, small team |
| **AWS / GCP** (Cloud Run, ECS) | Medium | Scale, client enterprise |
| **VPS** (Hetzner, DigitalOcean) | Fixed monthly | Full control, Docker |

**Minimum production setup:**

- HTTPS (Let's Encrypt)
- Env vars for API keys (`PLANT_API_KEY`, etc.)
- Request timeout **45s** (app already expects this)
- Basic logging (request id = app ka `scan_id` bhej sakte ho)
- Rate limit per IP / per user (baad mein auth ke sath)

**Region:** Users agar Pakistan / South Asia hain → EU ya Singapore region latency check karo.

---

## 4. Alag repo — kyun aur kaise

### Kyun alag?

| Flutter repo | Backend repo |
|--------------|--------------|
| UI, GetX, assets | FastAPI, Docker, secrets |
| App Store build | Server deploy |
| UI developer | Backend developer |

Client ko do folders / two PRs clear dikhengi.

### Suggested structure

```
AiPlant_App/                 ← current repo (UI)
  docs/UI/
  docs/BACKEND/              ← specs only; code nahi
  lib/

AiPlant_Backend/             ← NEW repo (create when B-1 starts)
  app/
    main.py
    routes/identify.py
    routes/diagnose.py
    services/plant_api.py
  Dockerfile
  .env.example
  README.md
```

**Is Flutter repo mein backend code mat daalo** — sirf `docs/BACKEND/` specs + app-side `ApiPlantIdentifyRepository`.

---

## 5. Team roles

| Role | Responsibility |
|------|----------------|
| **Flutter dev** | UI done; `ApiPlantIdentifyRepository` implement; `demoUiSuccess = false` |
| **Backend dev** | FastAPI proxy, Plant API mapping, deploy, monitoring |
| **Client / PM** | Provider choice, budget, go-live date |
| **QA** | Real phone scans: blur, non-plant, multi-angle, offline |

---

## 6. Backend phases (B-0 … B-5)

### B-0 — Mashwara (abhi) ✅ doc

- [ ] Provider choose (Plant.id vs Pl@ntNet vs hybrid)
- [ ] Hosting choose
- [ ] Alag backend repo create
- [ ] API budget / monthly estimate sign-off

### B-1 — Skeleton

- [ ] FastAPI + `/health`
- [ ] Docker + `.env.example`
- [ ] CI (lint + test)
- [ ] Staging URL (e.g. `https://api-staging.aiplant.example`)

### B-2 — Identify

- [ ] `POST /ai/identify` — **multiple images one request**
- [ ] Map response → `PlantIdentifyResult` JSON (`isLocalPreview: false`)
- [ ] `categoryId`: plant, tree, mushroom, weed, disease
- [ ] `similarMatches`, `toxicity` (null OK → app shows "Data unavailable")
- [ ] Fail reasons: `noMatch`, server errors — **not** same as `notPlant` (app handles local)

### B-3 — Diagnose

- [ ] `POST /ai/diagnose` — health photos (identify photo reuse nahi)
- [ ] Optional: `symptomId` field for future
- [ ] Map → `PlantDiseaseHint` JSON

### B-4 — App connect

- [ ] `ApiPlantIdentifyRepository` in Flutter
- [ ] `plant_scan_binding.dart` swap
- [ ] `BASE_URL` in app config / flavor
- [ ] `demoUiSuccess = false`
- [ ] `PlantSceneGate.enabled` — production decision (usually `true`)

### B-5 — Calibrate & harden

- [ ] 100+ real scans
- [ ] Confidence tiers tune (high ≥0.75, medium ≥0.55 — starting point)
- [ ] Rate limits, alerts, error tracking (Sentry / similar)

---

## 7. Architecture rules (non-negotiable)

Ye [`FLOW_DEVELOPER_APPROVED.md`](../FLOW_DEVELOPER_APPROVED.md) se — backend **must** follow:

1. **API keys** → backend only, never Flutter APK
2. **Cheap validation first** (app already: blur, dark, gate) → paid API last
3. **Multiple Angles** → ONE request, ALL photos (not first photo only)
4. **Max 1 retry** on timeout, phir error to app
5. **PlantIdentification ≠ PlantDiagnosis** — separate models/endpoints
6. **LLM optional** — sirf explanation; species/toxicity invent mat karo
7. **Snap History** — app sirf success record karti hai; backend failed identify par bhi species name mat bhejo

---

## 8. Cost / timeline (rough estimate)

| Item | Estimate |
|------|----------|
| Backend skeleton + 2 endpoints | 1–2 weeks (1 backend dev) |
| App connect + QA | 3–5 days (Flutter dev) |
| Plant API subscription | Provider plan — client decision |
| Hosting | ~$5–30/mo MVP |

*Exact cost provider plan par depend karta hai.*

---

## 9. Decisions checklist (client sign-off)

```
☐ Plant API provider: _______________
☐ Hosting: _______________
☐ Backend alag repo: Haan / Nahi
☐ Staging URL needed before production: Haan / Nahi
☐ Diagnose Phase 1 mein ya Phase 2: _______________
☐ Budget approved: _______________
```

---

## 10. Agla step

1. Client se **Section 9** fill karwao  
2. Backend dev [`BACKEND_SETUP.md`](BACKEND_SETUP.md) follow kare  
3. Flutter dev B-4 par `ApiPlantIdentifyRepository` likhe  

---

[← Backend index](README.md) · [Technical setup →](BACKEND_SETUP.md) · [UI track →](../UI/README.md)
