# Scanner — Production Checklist (Final — Hand to Developer)

> **Scope:** Camera/Gallery → validation → identify → result → optional diagnose only.  
> **Final rule:** Good photo → Valid plant → Confidence check → Identification result  
> **Never:** Any photo → Force a plant answer  
> **Trust:** Prefer **"I'm not sure"** over a confident wrong answer.

**Current:** ~82% | **After P0:** strong enough for production testing | **After P1:** polished modern experience (~95%)

---

## P0 — Must Fix Before Production

### 1. Disable Demo / Fake AI
- Remove all demo responses and bypass logic.
- Scanner must use the **live production API only**.
- Files: `plant_scene_gate.dart` (`enabled = true`), `plant_identify_repository.dart` (`demoUiSuccess = false`), `plant_scan_binding.dart`

### 2. Photo Quality Validation
Before identification, check:
- Blurry image
- Too dark / poor lighting
- Plant too small or too far away

**Bad-quality photos should not be sent for identification.**

### 3. Non-Plant Protection
- Non-plant objects must **never** receive a plant/species result.
- Stop the flow and ask the user to scan again.

### 4. Confidence Handling
| Level | Behavior |
|-------|----------|
| **High** | Show normal identification result |
| **Medium** | Show **"Possible match"** + alternative matches |
| **Low** | Do **not** show a final plant name; request a clearer/additional photo |

### 5. Rename Multiple Mode
- Change **"Multiple"** → **"Multiple Angles"**
- Add helper text: *"Add 2–3 photos of the same plant for better accuracy."*

### 6. Fix Multiple Angles
- All captured angles must be sent to the identification API.
- Confirm the photos appear to belong to the **same plant**.
- If the current API does not support this properly, **disable Multiple Angles** until implemented correctly.

### 7. Failure Screen
Provide both:
- **Scan Again**
- **Choose from Gallery**

### 8. API / Network Failure
Keep technical/service failure **separate** from invalid-photo failure.

**Example copy:**
> "We couldn't analyze this photo right now."  
> Your photo looks fine, but the identification service is temporarily unavailable.

**Actions:** Try Again | Back

**Covers:** No internet, API timeout, rate limit, server error — **not** "No plant detected".

---

## P1 — Next Improvements

### 1. Generic Processing Text
Avoid fixed text such as *"Looking at the leaf"*.

Use:
1. Checking photo quality
2. Looking for a plant
3. Analyzing plant features
4. Comparing possible matches
5. Preparing result

### 2. Multiple Plants in One Photo
If several plants are visible:
> "Multiple plants detected. Focus on one plant for a more accurate identification."

**Action:** Retake Photo

*(Later: advanced version — user taps which plant to identify.)*

### 3. Confirm Identification
On the result screen add:
- **Yes, this is my plant**
- **Not the right plant**

If incorrect → show similar matches or allow another photo.

### 4. Diagnose Must Have Its Own Flow
Do **not** automatically diagnose using only the original identification photo.

```
Plant Result
    ↓
Check Health / Diagnose & Fix
    ↓
What are you noticing?
    ↓
  Yellow leaves | Brown spots | Drooping | Holes/bites
  White coating | Pests | Other / Not sure
    ↓
Take new health photos
    ↓
  Whole plant
  Affected area close-up
  Leaf underside / stem (optional)
    ↓
Disease API
    ↓
Diagnosis result
```

---

## Keep Exactly As Designed (Do Not Change)

- Identify ≠ Diagnose (separate APIs, separate user actions)
- Care information on identification result
- Similar matches
- Toxicity (structured data only; show "Data unavailable" if missing)
- Health entry / Check Health
- Diagnose & Fix (manual tap only)
- **Failed scans never enter Snap History**

---

## Developer Sign-Off

```
☐ Demo/fake AI fully removed — live API only
☐ Blur / dark / too-small blocked before API
☐ Non-plant never gets species name
☐ API fail message ≠ "No plant detected"
☐ High / Medium / Low confidence rules implemented
☐ "Multiple Angles" renamed + helper text
☐ All angles sent to API OR feature disabled
☐ Fail screen: Scan Again + Choose from Gallery
☐ P1 processing text generic
☐ P1 result confirm buttons
☐ P1 diagnose: symptoms + new photos
☐ Failed scans not in Snap History
☐ Trust rule: unsure > wrong confident answer
```

---

## Key Files

| Area | File |
|------|------|
| Non-plant gate | `plant_scene_gate.dart` |
| Demo / API | `plant_identify_repository.dart`, `plant_scan_binding.dart` |
| Quality check | `plant_image_upload.dart` + new helper |
| Identify flow | `identify_flow.dart`, `identify_processing_view.dart` |
| Fail / retry | `identify_failed_view.dart` |
| Confidence / result | `identify_result_view.dart`, `plant_identify_result.dart` |
| Multi-angle | `plant_scan_controller.dart`, `plant_scan_view.dart` |
| Diagnose | `identify_disease_view.dart` |
| Snap history | `plant_scan_controller.dart` → `addIdentifySnap()` (success only) |

---

## APIs (Live)

| Endpoint | When |
|----------|------|
| `POST /ai/identify` | After all P0 validation passes |
| `POST /ai/diagnose` | After symptom selection + health photos |

---

*Final version — Sep 2026. Approved for developer handoff.*
