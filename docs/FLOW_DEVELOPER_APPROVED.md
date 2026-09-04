# AiPlant — Final Flow (Developer Approved + Additions)

> **Docs split:** UI → [`docs/UI/README.md`](UI/README.md) · Backend → [`docs/BACKEND/README.md`](BACKEND/README.md) · Index → [`docs/README.md`](README.md)

> **Developer verdict:** Flow ~**90–92%** correct. P0 + real testing → **95%+**  
> **Rule:** AI ko answer dena zaroori nahi — **correct answer** dena zaroori hai.

---

## Approved Flow (maintain exactly)

```
Camera / Gallery
      ↓
Photo Quality Validation
      ↓
Supported plant subject?
      ↓
Live Identify API
      ↓
Confidence Rules
      ↓
Identification Result
      ↓
Optional separate Diagnose flow
```

**Result ke baad (separate from identify pipeline):** Garden / Wishlist / Botanist / Snap History

---

## P0 — Must Fix Before Production

| # | Item |
|---|------|
| 1 | Live API only — demo/fake band |
| 2 | Image quality — blur, dark, too small |
| 3 | Non-plant rejection — species name kabhi nahi |
| 4 | Confidence rules — High / Medium / Low |
| 5 | Multiple Angles — **ONE request, all photos** (see below) |
| 6 | Network/API error states (alag from "no plant") |
| 7 | **Secure backend API proxy** — keys app mein nahi |

---

## Developer ne 5 rules add kiye (P0/P1 mein shamil)

### A. Image preprocessing (API se pehle)
- Orientation fix
- Reasonable resize/compression
- Aspect ratio preserve
- Over-compress mat karo

### B. Duplicate-angle check
Same photo 3 baar → *"Try a different angle for better accuracy."*

### C. Confidence thresholds — blind mat karo
Example 90/60 fix mat karo abhi. **100–500 real scans** se calibrate karo (har API alag hoti hai).

### D. Cancel/retry state
- Har scan ko unique `scan_id` / `request_id`
- Back ya second request → purana result naye scan par overwrite na kare

### E. Result source separation
| Source | Data |
|--------|------|
| **Plant API** | Species, scientific name, confidence, toxicity, care |
| **LLM (optional)** | Explanation only — species/toxicity **invent na kare** |

---

## Multiple Angles — KEEP (disable mat karo)

APIs support karti hain (Plant.id/Kindwise, Pl@ntNet up to 5 images same plant).

**Correct:**
```
Photo 1 + Photo 2 + Photo 3 → ONE identify request → ONE result
```

**Wrong (abhi app mein ye bug hai):**
```
Photo 1 → API → Result A  (sirf first photo jati hai)
```

**Ship tab jab:** saari selected photos ek request mein jayein.

**Same-plant check:** API par blind trust na karo — app/backend validation.

**Recommended UI:**
```
Multiple Angles
1. Whole plant       ✓
2. Leaf close-up     ✓
3. Flower / stem     +

2 photos added
For best accuracy, use photos of the same plant.
[ Identify with 2 photos ]
```
3 photos mandatory nahi.

---

## Architecture — 6 decisions (abhi fix karo)

| # | Decision |
|---|----------|
| 1 | **API keys** → Flutter → Your Backend → Plant API (never in app) |
| 2 | **Pipeline order** → cheap validation first → paid Identify API last |
| 3 | **Timeouts** → max 1 controlled retry, phir error screen |
| 4 | **Snap History** → sirf successful identify. NOT: API error, rejected, low-confidence unfinished, cancelled |
| 5 | **Models separate** → `PlantIdentification` ≠ `PlantDiagnosis` |
| 6 | **Safety** → toxicity, mushroom, treatment = authoritative data only. Show warnings when data uncertain |

---

## P1 — After P0 + Real Device Testing

1. Better processing UX (generic steps)
2. Multi-plant in frame handling
3. Confirm/correct result buttons
4. Dedicated diagnosis capture (symptoms + new photos)

---

## Go Flows — Unchanged

- Save to Garden → Garden tab → Water / Tasks / Detail
- Wishlist / Not now
- Ask Botanist
- Identify ≠ Diagnose
- Failed scans ≠ Snap History

---

## Implementation Phases

```
Phase 1 — P0 Core
  Live API proxy, quality, non-plant, confidence, preprocessing,
  Multiple Angles ONE-request fix, API errors, scan_id, secure backend

Phase 2 — Real Device Testing
  100+ scans, threshold calibration, edge cases

Phase 3 — Go Flows Verify
  Save → Garden → Water → Snap paths

Phase 4 — P1 Polish
  Processing UX, confirm buttons, multi-plant, diagnose capture flow

Phase 5 — P1+ Safety & Sources
  LLM explanation separate, toxicity authoritative only
```

---

## Developer Sign-Off Checklist

```
☐ Approved flow implemented as diagram above
☐ Image preprocessing before API
☐ Duplicate-angle detection
☐ Confidence thresholds calibrated on real data (not hard-coded)
☐ Unique scan_id per request, no overwrite on cancel/retry
☐ Plant API data ≠ LLM invention
☐ Multiple Angles → one request, all photos
☐ Backend proxy for API keys
☐ Cheap validation before paid API
☐ Max 1 retry on timeout
☐ Snap History = success only
☐ PlantIdentification ≠ PlantDiagnosis models
☐ Go flows working after save
```

---

*Developer approved — Sep 2026*
