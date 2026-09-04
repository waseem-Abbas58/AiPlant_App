# AI PlantApp — Backend

REST API foundation for **AI PlantApp**, a Flutter plant identification and care application.

Phase 2 is in place: health check plus Plant.id identify and diagnose. Flutter is not connected yet.

## Purpose

Provide a production-ready backend entry point so later phases (database, auth, plant scanning, AI, storage, garden, and billing) can be added independently without changing this foundation.

The Flutter app stays on local/demo behavior until a later phase connects it.

## Technology stack

- Node.js
- Express.js
- dotenv for environment variables
- CORS
- nodemon (development)

Wired now:

- Plant.id identify and diagnose (key in `.env`)

Planned later:

- MongoDB / Mongoose
- Firebase Authentication
- Gemini / AI APIs
- Image storage
- Garden, profile, scan, reminder, and subscription APIs

## Project structure

```text
backend/
├── src/
│   ├── config/          # Environment and future service config
│   ├── controllers/     # Route handlers (health only for now)
│   ├── routes/          # Versioned API routes (/api/v1)
│   ├── services/        # Reserved for later phases
│   ├── models/          # Reserved for later phases
│   ├── middleware/      # 404 and centralized error handling
│   ├── utils/           # Standard API response helpers
│   ├── validators/      # Reserved for later phases
│   └── app.js           # Express application
├── server.js            # HTTP server entry point
├── .env.example         # Placeholder environment variables
├── package.json
└── README.md
```

## Install dependencies

From the `backend` folder:

```bash
npm install
```

## Environment variable setup

1. Copy the example file:

   ```bash
   copy .env.example .env
   ```

   On macOS / Linux:

   ```bash
   cp .env.example .env
   ```

2. Set at least:

   ```env
   PORT=3000
   NODE_ENV=development
   ```

3. Leave the remaining keys empty until their phase:

   - `MONGODB_URI` — Phase 2
   - `FIREBASE_*` — Phase 3
   - `PLANT_ID_API_KEY` — Phase 4
   - `GEMINI_API_KEY` — Phase 6

Do not commit `.env`.

## Run development server

```bash
npm run dev
```

Nodemon restarts the process when files change.

## Run production server

```bash
npm start
```

## Health endpoint

```http
GET /api/v1/health
```

Example response:

```json
{
  "success": true,
  "message": "AI PlantApp backend is running",
  "data": {
    "status": "ok",
    "service": "ai-plant-app-backend",
    "version": "v1",
    "environment": "development",
    "timestamp": "2026-09-03T00:00:00.000Z"
  }
}
```

## Plant.id endpoints

These return the Flutter scan models directly (not the health envelope), so Phase 3 can parse them as-is.

```http
POST /api/v1/ai/identify
Content-Type: multipart/form-data

image: JPEG or PNG file (repeat field for more angles, max 5, 8 MB each)
categoryId: optional (plant, tree, mushroom, weed)
```

```http
POST /api/v1/ai/diagnose
Content-Type: multipart/form-data

image: JPEG or PNG file (repeat field for more photos)
plantName: optional
symptomId: optional
```

Unknown routes return:

```json
{
  "success": false,
  "message": "Route not found: GET /api/v1/unknown",
  "error": {}
}
```

## Current status

Phase 2 — Plant.id APIs are in place:

- Health check at `/api/v1/health`
- Identify at `POST /api/v1/ai/identify`
- Diagnose at `POST /api/v1/ai/diagnose`
- Plant.id key stays in `.env`

Flutter is not connected yet.

## Future planned integrations

| Phase | Work |
| --- | --- |
| 2 | MongoDB / Mongoose connection and models |
| 3 | Firebase Authentication and token verification |
| 4 | Plant scanning / Plant.id |
| 5 | Disease / health diagnosis |
| 6 | Ask Botanist / Gemini |
| 7 | Image storage |
| 8 | My Garden / Profile / Scan History APIs |
| 9 | Reminders / notifications |
| 10 | Subscriptions |

Each phase will be added separately after review.
