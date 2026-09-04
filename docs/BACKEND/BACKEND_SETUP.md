# Backend Setup — Technical Guide

> **Pehle padho:** [BACKEND_MASHWARA.md](BACKEND_MASHWARA.md) (provider + hosting decisions)  
> **UI track (alag):** [`../UI/README.md`](../UI/README.md)

---

## 1. Architecture

```
┌─────────────────────────────────────────────────────────┐
│ Flutter App (AiPlant_App)                               │
│  IdentifyFlow → PlantIdentifyRepository                 │
│  LocalPlantIdentifyRepository  ← demo (abhi)            │
│  ApiPlantIdentifyRepository    ← live (B-4)             │
└───────────────────────────┬─────────────────────────────┘
                            │ HTTPS
                            │ multipart/form-data
                            ▼
┌─────────────────────────────────────────────────────────┐
│ Your Backend (AiPlant_Backend — alag repo)              │
│  POST /ai/identify                                      │
│  POST /ai/diagnose                                      │
│  GET  /health                                           │
└───────────────────────────┬─────────────────────────────┘
                            │ API key in env
                            ▼
┌─────────────────────────────────────────────────────────┐
│ Third-party Plant API (Plant.id / Pl@ntNet / …)        │
└─────────────────────────────────────────────────────────┘
```

---

## 2. Suggested FastAPI layout

```
AiPlant_Backend/
├── app/
│   ├── main.py                 # FastAPI app, CORS, routes
│   ├── config.py               # pydantic-settings, env
│   ├── routes/
│   │   ├── health.py
│   │   ├── identify.py
│   │   └── diagnose.py
│   ├── services/
│   │   └── plant_provider.py   # Plant.id / Pl@ntNet client
│   └── mappers/
│       ├── identify_mapper.py    # provider → PlantIdentifyResult JSON
│       └── diagnose_mapper.py    # provider → PlantDiseaseHint JSON
├── tests/
├── Dockerfile
├── requirements.txt
├── .env.example
└── README.md
```

---

## 3. Environment variables

```bash
# .env.example — copy to .env (never commit .env)

PLANT_API_PROVIDER=plantid          # plantid | plntnet
PLANT_API_KEY=your_secret_key
PLANT_API_BASE_URL=https://...

# Optional app auth (recommended later)
APP_API_KEY=optional_flutter_header

# Server
PORT=8000
ENV=staging
CORS_ORIGINS=*
REQUEST_TIMEOUT_SECONDS=45
```

---

## 4. Endpoints

### `GET /health`

```json
{ "status": "ok", "version": "1.0.0" }
```

### `POST /ai/identify`

**Request:** `multipart/form-data`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `image` | file | yes (1+) | JPEG/PNG, max 8 MB each; **repeat field for multiple angles** |
| `categoryId` | string | no | `plant`, `tree`, `mushroom`, `weed`, `disease` |
| `scanId` | string | no | App logging / tracing |

**Success response:** `200` — body must parse as `PlantIdentifyResult.fromJson`

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

**Note:** `imagePath` app side set karti hai — backend bhej sakta hai ya omit.

**No match / low confidence:** Still `200` with `isIdentified: true` but low `confidence`, **or** `isIdentified: false` + `failReason: "noMatch"`. App dono handle karti hai.

**Server errors:** `502` / `503` — app maps to `serverError` / retry UI.

---

### `POST /ai/diagnose`

**Request:** `multipart/form-data`

| Field | Type | Required | Notes |
|-------|------|----------|-------|
| `image` | file | yes (1+) | Health photos; identify photo alag flow |
| `plantName` | string | no | Context |
| `symptomId` | string | no | e.g. `yellow_leaves`, `brown_spots` |

**Success response:** `200` — `PlantDiseaseHint.fromJson`

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

---

## 5. Upload rules (locked with app)

From `lib/core/helpers/plant_image_upload.dart`:

| Rule | Value |
|------|-------|
| Formats | JPEG, PNG only |
| Max size | 8 MB per file |
| Multipart field name | `image` |
| Multiple files | Same field name repeated (identify) |

App pehle local preprocess karti hai (`PlantImagePreprocess`) — backend ko full-size original bhi mil sakta hai.

---

## 6. Flutter connect (B-4)

### Step 1 — Create `ApiPlantIdentifyRepository`

New file: `lib/features/plant_scan/data/api_plant_identify_repository.dart`

```dart
// Pseudocode — implement with Dio
class ApiPlantIdentifyRepository implements PlantIdentifyRepository {
  ApiPlantIdentifyRepository({required this.baseUrl, this.apiKey});

  final String baseUrl;
  final String? apiKey;

  @override
  Future<PlantIdentifyResult> identifyFromImages(
    List<String> imagePaths, {
    String categoryId = 'plant',
  }) async {
    // 1. PlantImageUpload.prepare each path
    // 2. POST $baseUrl/ai/identify multipart
    // 3. PlantIdentifyResult.fromJson(response) + copyWith(imagePath: first)
  }

  @override
  Future<PlantDiseaseHint> diagnoseFromImage(String imagePath) async {
    // POST $baseUrl/ai/diagnose
  }
}
```

### Step 2 — Swap binding

`lib/features/plant_scan/bindings/plant_scan_binding.dart`:

```dart
Get.lazyPut<PlantIdentifyRepository>(
  () => ApiPlantIdentifyRepository(
    baseUrl: const String.fromEnvironment('API_BASE_URL'),
  ),
  fenix: true,
);
```

### Step 3 — Turn off demo

`lib/features/plant_scan/data/plant_identify_repository.dart`:

```dart
static const demoUiSuccess = false;  // production
```

### Step 4 — Run with dart-define

```bash
flutter run --dart-define=API_BASE_URL=https://api-staging.example.com
```

---

## 7. Multiple angles — backend requirement

App sends **all** captured paths in one `identifyFromImages()` call.

Backend **must** forward all images in **one** upstream Plant API request.

```
❌ Wrong: use only images[0]
✅ Right: images[0..n] → one provider call → one result
```

---

## 8. Error mapping

| Backend | App `IdentifyFailReason` |
|---------|--------------------------|
| Timeout | `timeout` |
| 503 / upstream down | `serverError` |
| No network (client) | `offline` (app detects) |
| Not a plant | Prefer app local gate; API `noMatch` if unsure |

**Important:** API down ≠ "No plant detected" — alag UI copy app mein already hai.

---

## 9. Security checklist

```
☐ API keys only in backend env
☐ HTTPS only in production
☐ Rate limit on /ai/*
☐ Max upload size enforced (8 MB)
☐ Optional: APP_API_KEY header from app
☐ No secrets in Flutter source or git
☐ CORS restricted in production (not *)
```

---

## 10. Testing

| Test | How |
|------|-----|
| Health | `curl https://api.../health` |
| Identify | Postman multipart 1–3 images |
| App smoke | `demoUiSuccess=false` + staging URL |
| Offline | Airplane mode → app fail screen |
| Multi-angle | 2 photos same plant → one result |

---

## 11. Deploy (example Docker)

```dockerfile
FROM python:3.12-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY app ./app
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Deploy to Railway / Render / Cloud Run — staging pehle, phir production.

---

## 12. Related app files

| Purpose | Path |
|---------|------|
| Repository interface | `lib/features/plant_scan/data/plant_identify_repository.dart` |
| Swap point | `lib/features/plant_scan/bindings/plant_scan_binding.dart` |
| Identify JSON model | `lib/features/plant_scan/model/plant_identify_result.dart` |
| Upload helper | `lib/core/helpers/plant_image_upload.dart` |
| Flow + timeout | `lib/features/plant_scan/data/identify_flow.dart` |

---

[← Mashwara](BACKEND_MASHWARA.md) · [Backend index](README.md) · [UI track →](../UI/README.md)
