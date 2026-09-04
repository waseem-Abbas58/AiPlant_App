# UI Track — Flutter App (Complete)

> **Ye folder:** Sirf **UI / Flutter** documentation.  
> **Backend / API:** [`../BACKEND/README.md`](../BACKEND/README.md) — alag track.

---

## Status: ✅ UI Phase 1–4 Done

Demo mode se poora flow test ho chuka hai. Live API abhi connected nahi.

**Demo flags (abhi):**
```dart
// lib/features/plant_scan/data/plant_identify_repository.dart
static const demoUiSuccess = true;

// lib/features/plant_scan/data/plant_scene_gate.dart
static const enabled = true;
```

---

## UI documents

| File | Kya hai |
|------|---------|
| [UI_PHASES.md](UI_PHASES.md) | UI-1 … UI-4 phases + acceptance |
| [APP_FLOW_SCAN_GARDEN_WATER.md](APP_FLOW_SCAN_GARDEN_WATER.md) | Scan → Result → Garden → Water |
| [FLOW_CHECKLIST_URDU.md](FLOW_CHECKLIST_URDU.md) | Urdu flow checklist |

---

## Locked UI architecture (backend se independent)

```
Photo → Quality check → Non-plant gate → Identify → Confidence → Result
                                              ↓
                              Optional Diagnose (alag flow, alag photos)
```

- **Identify ≠ Diagnose** — kabhi merge mat karo
- Failed scans → Snap History **nahi**
- Successful identify → Snap History **haan**
- Save → Garden → Water / Tasks

---

## Key Flutter files (UI developer)

| Area | Files |
|------|-------|
| Scan camera | `plant_scan_view.dart`, `plant_scan_controller.dart` |
| Identify flow | `identify_flow.dart`, `identify_processing_view.dart`, `identify_failed_view.dart` |
| Result | `identify_result_view.dart` |
| Diagnose UI | `diagnose_flow.dart`, `diagnose_symptom_view.dart`, `diagnose_capture_view.dart` |
| Garden / Water | `my_garden_controller.dart`, `garden_snap_history_view.dart`, `water_meter_view.dart` |

---

## UI developer ko backend ki zaroorat nahi

- Local validation, fail screens, confidence UI — sab app mein hai
- `LocalPlantIdentifyRepository` fake "Demo plant" deta hai
- Backend aane par sirf **repository swap** — UI screens change nahi hongi

**Connect point:** `plant_scan_binding.dart` (backend team karegi)

---

## Next (UI team ke liye)

- Client demo / polish bugs
- Backend team jab API ready kare → smoke test with `demoUiSuccess = false`

---

[← Documentation index](../README.md) · [Backend track →](../BACKEND/README.md)
