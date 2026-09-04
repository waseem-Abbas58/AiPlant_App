# AI Features & Image Processing

> **Do not integrate any AI API now.** This document analyzes what the UI already expects and recommends services for later.

Related: [Project Overview](PROJECT_OVERVIEW.md) · [Data & APIs](DATA_AND_APIS.md) · [Architecture](ARCHITECTURE.md)

Locked product rule ([FLOW_DEVELOPER_APPROVED.md](../FLOW_DEVELOPER_APPROVED.md)):

> **Plant API = species / toxicity / disease. LLM = explanation only. Do not invent species or toxicity.**

---

## 1. Plant identification — EXISTING UI, demo AI

| | |
|---|---|
| Function | Species ID from 1–5 photos + category |
| Input | JPEG/PNG images (max 8 MB), `categoryId`, `scanId` |
| Output | `PlantIdentifyResult`: names, confidence, similar matches, kind, toxicity, care |
| Vision? | **Yes** |
| Text AI? | No (optional explanation later) |
| Best service | **Plant.id / Kindwise** (or Pl@ntNet for ID-only) |
| Gemini / OpenAI? | **Not as primary ID** |

**Recommendation:** Plant.id (or Pl@ntNet) behind the Node backend. Gemini/OpenAI must not be the source of the plant name.

Identify already sends **all** captured angles in one `identifyFromImages()` call. Backend must forward **all** images in **one** upstream request.

Confidence tiers in the app: high ≥ 0.75, medium ≥ 0.55, low otherwise. Calibrate after 100+ real scans.

---

## 2. Disease diagnosis — EXISTING UI, demo AI

| | |
|---|---|
| Function | Leaf/health diagnosis from new photos + optional `symptomId` + plant name |
| Input | Health photos, `plantName`, `symptomId` |
| Output | `PlantDiseaseHint`: healthy, diseaseName, confidence, symptoms, steps, prevention, caution |
| Vision? | **Yes** |
| Text AI? | Optional rewrite of steps; disease name must stay provider-sourced |
| Best service | **Plant.id disease module** |

Identify photo is **not** reused. Diagnose flow:

```
Identify result → symptom pick → new health photos → disease result
```

Health photo steps in UI: whole plant (required), affected close-up (required), leaf underside (optional).

**Known Flutter gap:** repository method is `diagnoseFromImage(String imagePath)` — one path. Result screen uses the first photo. `symptomId` is collected but not passed to the repository. When live API is wired, extend the Flutter repository to send **all photos + `symptomId`**.

---

## 3. Ask Botanist chat — EXISTING UI, local keywords

| | |
|---|---|
| Function | Care Q&A, optional garden context + leaf photo |
| Input | Text, optional image, plant name/id |
| Output | Care advice text |
| Vision? | **Yes, optional** |
| Text AI? | **Yes** |
| Best service | **Gemini 1.5/2.x Flash** (or OpenAI GPT-4.1-mini) |

**Recommendation: Gemini** for chat — lower cost, native image+text. **Ground it** with garden plant name + identify/diagnose facts. Never let it invent a species or toxicity fact.

Current replies: `BotanistChat.replyFor()` keyword templates + 700ms fake typing. Chat history is **RAM only**.

---

## 4. Botanist voice call — EXISTING UI, on-device STT/TTS

Uses `speech_to_text` + `flutter_tts` and the same local replies. **No extra AI vendor.** Speech stays on-device unless a real-time voice API is added later (not required by current UI).

---

## 5. Toxicity — EXISTING local list + identify field

Home tool “Toxicity Identifier” uses a hardcoded list. Identify results also show `PlantToxicity` (pets/kids). Authoritative toxicity should come from **Plant.id**, not an LLM.

---

## 6. Not AI

Light meter, water meter, plant finder, weekly quiz, home catalogs — on-device or static data.

---

## AI recommendation summary

| Feature | Primary API | LLM role |
|---|---|---|
| Identify | Plant.id (or Pl@ntNet) | Optional explanation only |
| Diagnose | Plant.id disease | Optional wording only |
| Chat | Gemini Flash | Primary |
| Voice call | Same as chat | None extra |
| Toxicity | Plant.id | Display only |

---

## Image capture / use (EXISTING)

| Place | How |
|---|---|
| Scan tab | Live camera + gallery; multi-shot up to 5 |
| Garden add | `AddPlantCameraView` / photo review |
| Diagnose | `DiagnoseCaptureView` (new photos) |
| Chat | Camera / gallery / file picker |
| Profile | Avatar from gallery |
| Garden diary | Photo + note |
| Light meter | Camera stream (not uploaded) |

### Upload vs analysis

| Feature | Upload later? | Analyze later? |
|---|---|---|
| Identify | **Yes** (multipart `image` × N) | **Yes** |
| Diagnose | **Yes** | **Yes** |
| Chat photo | **Yes** (to AI proxy) | **Yes** (vision chat) |
| Garden / diary / avatar | **Yes** if cloud sync | No (storage only) |
| Light meter | No | No |
| Home catalogs | No (bundled assets) | No |

---

## On-device pipeline already built (EXISTING)

1. Capture / pick
2. `PlantPhotoQuality` — blur, dark, too small, multiple plants, duplicate angle
3. `PlantSceneGate` — cheap “looks like plant?” (`enabled = true`)
4. `PlantImagePreprocess` — resize/orient (max edge 1600)
5. `PlantImageUpload.prepare` — JPEG/PNG, **8 MB**, field name `image`
6. `IdentifyFlow` — 45s timeout, `scanId`, fail/retry
7. Demo repository if `demoUiSuccess = true` (**currently true**)

Photos kept locally in `{appDocuments}/ai_plant_images/`.

Quality thresholds (`PlantPhotoQuality`):

| Check | Threshold | Fail reason |
|---|---|---|
| Min edge | 400 px | `subjectTooSmall` |
| Mean luminance | < 0.14 | `tooDark` |
| Laplacian variance | < 45 | `tooBlurry` |
| Center subject share | < 8% | `subjectTooSmall` |
| Near-duplicate pair | avg pixel diff < 8 | `duplicateAngle` |

---

## Backend endpoints for images / AI (RECOMMENDED)

- `POST /ai/identify` — already designed; multiple `image` parts
- `POST /ai/diagnose` — already designed; should accept all health photos + `plantName` + `symptomId`
- `POST /ai/chat` — text + optional image
- `POST /uploads` or signed upload — garden/avatar/diary
- `GET /v1/scans` — optional history (app currently stores success snaps locally)

Timeout: **45 seconds**. Max **1 retry** on timeout, then error UI.

---

## Storage recommendation (RECOMMENDED)

| Option | Fit |
|---|---|
| **Cloudinary** | Best default: transforms, size limits, CDN, simple Node SDK |
| **AWS S3 + CloudFront** | Better if already on AWS |
| **Firebase Storage** | Fine if one Google bill; still verify from Node via Admin SDK |
| Local device only | Current state; no multi-device sync |

**Recommendation:** **Cloudinary** (or S3) for plant/garden/chat images. Keep **Firebase Auth** only for identity. Never put Plant.id or Gemini keys in the Flutter app.

Temporary AI images can expire (7–30 days). Garden/avatar images should be durable.

---

## Demo vs live connect (EXISTING)

| File | Role |
|---|---|
| `lib/features/plant_scan/data/plant_identify_repository.dart` | Interface + `LocalPlantIdentifyRepository` (`demoUiSuccess = true`) |
| `lib/features/plant_scan/bindings/plant_scan_binding.dart` | Swap point — currently local repo |
| `lib/features/plant_scan/model/plant_identify_result.dart` | Locked JSON models |
| `lib/core/helpers/plant_image_upload.dart` | Upload rules |

`ApiPlantIdentifyRepository` **does not exist yet**. When backend is ready: implement it, register it in the binding, set `demoUiSuccess = false`.

---

[← Backend index](README.md)
