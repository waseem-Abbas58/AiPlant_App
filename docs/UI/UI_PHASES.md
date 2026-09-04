# AiPlant — UI Phases (Ab Karne Wale)

> **Rule:** In phases mein **koi backend / API nahi**. Demo mode se test.  
> **Is ke baad:** Backend mashwara + alag setup → phir API connect.

---

## Overview

| Phase | Naam | Focus |
|-------|------|-------|
| **UI-1** | Scanner UI + Validation | Camera flow, processing, fail, result base |
| **UI-2** | Go Flows | Save, Garden, Water, Snap, Tasks |
| **UI-3** | Polish + Diagnose UI | Confirm, symptoms, copy, safety UI ✅ |
| **UI-4** | Full Demo Test | End-to-end walkthrough, fix gaps ✅ |
| **—** | *Break* | Backend mashwara + setup (alag) |
| **B-1** | Backend + API | *Baad mein — ab nahi* |

**Demo flags abhi:**
- `demoUiSuccess = true` — flow test ke liye
- `PlantSceneGate.enabled = true` — non-plant test (UI ke sath)

---

## UI Phase 1 — Scanner UI + Validation

**Goal:** Scan journey smooth dikhe aur local checks kaam karein — bina API.

### Tasks

| # | Task |
|---|------|
| 1 | "Multiple" → **"Multiple Angles"** + helper: *"Same plant ki 2–3 photos for better accuracy"* |
| 2 | Multiple Angles UI — thumbnails, remove, **"Identify with X photos"** CTA |
| 3 | Saari captured photos collect karo (API wire baad mein — ab sirf UI/state) |
| 4 | Photo quality checks (local): blur, dark, plant too small → fail message |
| 5 | Non-plant gate on + clear fail copy |
| 6 | Fail screen: **Scan Again** + **Choose from Gallery** |
| 7 | Processing text generic: Checking quality → Plant detected → Analyzing → Comparing → Preparing |
| 8 | API error **UI copy** alag (service down vs no plant) — demo/offline state se test |
| 9 | Har scan ko unique `scan_id` (cancel par overwrite na ho) |
| 10 | Image preprocess: orientation fix, resize (over-compress na karo) |

### Accept (Phase 1 done jab)

```
☐ Multiple Angles renamed + photos collect hoti hain
☐ Blur/dark/small par fail — identify screen tak na jaye
☐ Non-plant par fail — species result na dikhe (demo off test bhi)
☐ Fail screen par Scan + Gallery dono
☐ Processing steps generic text
☐ Back/cancel par purana result naye scan par na aaye
```

### Key files

`plant_scan_view.dart` · `plant_scan_controller.dart` · `identify_processing_view.dart` · `identify_failed_view.dart` · `plant_scene_gate.dart` · new quality helper

---

## UI Phase 2 — Go Flows

**Goal:** Scan ke baad user sahi jagah jaye — Save se le kar Water tak.

### Tasks

| # | Task |
|---|------|
| 1 | Result → **Save to garden** → Garden tab + snackbar |
| 2 | **Save to wishlist** + **Not now** theek kaam karein |
| 3 | Successful scan → **Snap History** (failed scan na jaye) |
| 4 | Garden tabs: My Garden / Tasks / Snap History |
| 5 | Plant card → **Plant Detail** |
| 6 | **Daily Care** card — streak, "Water X today" |
| 7 | **Water Meter** — mark watered, snooze, next date UI update |
| 8 | **Tasks** calendar — water tasks dikhein |
| 9 | **Ask Botanist** — result se chat open (context ke sath) |
| 10 | Home → Water Meter / Scan tools navigation |

### Accept (Phase 2 done jab)

```
☑ Save → Garden tab → plant list mein dikhe
☑ Water mark → Daily Care + Tasks update
☑ Snap History sirf successful scans
☑ Wishlist / Not now sahi
☑ Home se Water Meter + Scan tools kaam karein
☑ Photos persist locally (restart ke baad bhi)
```

### Key files

`identify_result_view.dart` · `my_garden_controller.dart` · `my_garden_view.dart` · `daily_care_summary.dart` · `water_meter_view.dart` · `garden_tasks_tab.dart` · `garden_snap_history_view.dart`

---

## UI Phase 3 — Polish + Diagnose UI

**Goal:** Result trust + Diagnose alag flow dikhe — demo result OK.

### Tasks

| # | Task |
|---|------|
| 1 | Confidence UI: **High** / **Possible match (Medium)** / **Low — retake** |
| 2 | **"Yes, this is my plant"** + **"Not the right plant"** buttons |
| 3 | Not right → similar matches prominent |
| 4 | Multi-plant in frame message + Retake |
| 5 | Duplicate angle hint: *"Try a different angle"* |
| 6 | Diagnose flow UI: symptom picker (yellow, spots, drooping, pests…) |
| 7 | Diagnose: nayi health photos steps (whole plant, close-up, underside) |
| 8 | Diagnose result screen polish (demo data) |
| 9 | Toxicity — data na ho to **"Data unavailable"** |
| 10 | Low confidence par final name hide / retake CTA |

### Accept (Phase 3 done jab)

```
☑ Confirm / Not right buttons kaam karein
☑ Diagnose: symptoms → photos → result (demo)
☑ Identify photo blindly diagnose mein reuse na ho (UI flow)
☑ Medium = "Possible match" label
☑ Low = no final name + retake
☑ Toxicity unavailable state dikhe
```

### Key files

`identify_result_view.dart` · `identify_disease_view.dart` · new symptom picker / diagnose capture screens

---

## UI Phase 4 — Full Demo Test

**Goal:** Poora app ek user ki tarah test — list bana ke fix karo.

### Test script

```
1. Home → Plant Identifier → photo → result
2. Diagnose & Fix → symptoms → photos → demo result
3. Save to garden → Garden → plant dikhe
4. Mark watered → streak / next date
5. Tasks tab → task dikhe
6. Snap History → scan dikhe
7. Wishlist save test
8. Not now test
9. Non-plant photo → fail (gate on)
10. Blur photo → quality fail
11. Multiple Angles 2 photos → identify
12. Back/cancel mid-scan → no ghost result
13. Ask Botanist from result
```

### Accept (Phase 4 done jab)

```
☑ Test script 13/13 pass (demo mode)
☑ Bug list fix ho chuki
☑ Flow client demo ke liye ready
```

### UI-4 fixes applied

| Issue | Fix |
|-------|-----|
| Snap History empty after garden save | Snaps stay in history with **In garden** badge |
| Cancel mid-scan left gallery thumb | `lastThumbPath` cleared on identify abort |
| Save bypass on low/medium confidence | `_save` / `_saveWishlist` guard with `_canSave` |

### Manual test tips

- **Step 2:** Result screen → **Diagnose & fix** (not Home “Disease Identifier”)
- **Step 9:** Non-plant photo (desk, wall, keyboard)
- **Step 10:** Blurry / dark photo
- **Step 11:** Multiple Angles → 2+ photos → Analyze

---

## Us ke baad — Backend (alag track)

UI complete ✅ — backend ab alag setup:

| Doc | Purpose |
|-----|---------|
| [../BACKEND/BACKEND_MASHWARA.md](../BACKEND/BACKEND_MASHWARA.md) | Provider, hosting, team, phases |
| [../BACKEND/BACKEND_SETUP.md](../BACKEND/BACKEND_SETUP.md) | Endpoints, env, app connect |
| [../BACKEND/README.md](../BACKEND/README.md) | Backend track index |

```
B-0 Mashwara → B-1 FastAPI skeleton → B-2 Identify → B-3 Diagnose → B-4 App connect → B-5 Calibrate
```

Detail: [FLOW_DEVELOPER_APPROVED.md](../FLOW_DEVELOPER_APPROVED.md) — Backend section.

---

## Quick reference

```
UI-1 … UI-4  →  docs/UI/     (complete)
B-0 … B-5    →  docs/BACKEND/ (next)
  ↓
API connect (separate backend repo)
```

Index: [docs/README.md](../README.md)

---

*UI-only phases — Sep 2026. Backend touch mat karo jab tak UI-4 complete na ho.*
