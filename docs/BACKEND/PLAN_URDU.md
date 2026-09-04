# Backend Plan — Short Urdu Summary

> Poori English detail: [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) se shuru karo.

---

## Abhi app kya hai

Flutter **UI complete** hai. GetX use ho raha hai. **Live backend nahi**, **Firebase nahi**, **live AI nahi**.

- Scan / diagnose: demo (`demoUiSuccess = true`) — “Demo plant”
- Login: koi bhi valid email + password → Home (local flag)
- Signup: sirf validate — user create nahi hota
- OTP: `123456`
- Chat: keyword replies
- Garden / profile: phone pe SharedPreferences

## Agela backend (recommended)

```
Flutter
  → Node.js + Express
  → MongoDB
  → Firebase Authentication
  → Plant.id (identify + diagnose)
  → Gemini (Ask Botanist only)
  → Cloudinary / S3 (images)
```

**Alag repo:** `AiPlant_Backend` — is Flutter repo mein server code mat daalo.

## Pehle kya banana hai

1. Express + Mongo + `/health`
2. Firebase Auth + user profile
3. `POST /ai/identify` (saari photos ek request)
4. `POST /ai/diagnose` (nayi health photos + symptom)
5. Garden sync
6. Chat (Gemini)
7. Baad mein: FCM, Premium billing

## Zaroori rules

- API keys **app mein nahi** — sirf backend env
- Identify ≠ Diagnose
- LLM se species / toxicity invent **mat** karo
- Weather / Maps ki zaroorat **nahi** (UI mein nahi)
- App lock (6-digit) device pe rahe — Mongo mein nahi

## Docs (padhne ka order)

1. [PROJECT_OVERVIEW.md](PROJECT_OVERVIEW.md) — app kya hai, features
2. [AUTHENTICATION.md](AUTHENTICATION.md) — Firebase Auth plan
3. [AI_AND_IMAGES.md](AI_AND_IMAGES.md) — Plant.id + Gemini + storage
4. [DATA_AND_APIS.md](DATA_AND_APIS.md) — Mongo + endpoints
5. [ARCHITECTURE.md](ARCHITECTURE.md) — stack + security + folder
6. [IMPLEMENTATION_PHASES.md](IMPLEMENTATION_PHASES.md) — Phase 1–13

Purane scan-proxy notes (FastAPI): [BACKEND_MASHWARA.md](BACKEND_MASHWARA.md) · [BACKEND_SETUP.md](BACKEND_SETUP.md)  
Identify/diagnose JSON contract **wahi locked** hai — stack Node/Express ho ya FastAPI.

---

[← Backend index](README.md)
