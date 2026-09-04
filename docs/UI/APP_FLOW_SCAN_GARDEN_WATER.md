# AiPlant — Scan Flow (Short Points)

> Developer + client dono ke liye. Scan se le kar garden / water tak.

---

## 1. User scan karta hai — kya hota hai?

**Start:** Scan tab **ya** Home → Plant/Disease/Tree tool → photo (camera / gallery)

**Process (automatic):**
1. Photo check — plant hai ya nahi
2. **Identify** — plant ka naam + care info (AI)
3. Fail → retry screen | Success → **Result screen**

**Note:** Scan par sirf **Identify** hota hai. Issue fix alag step hai.

---

## 2. Scan ke baad user kya dekhta hai? (Result Screen)

- Plant **photo + name** (name edit kar sakta hai)
- **Care tips** — light, water, soil
- **Health card** — issue check ke liye
- **Similar matches** — galat naam ho to change
- **Toxicity** — agar data ho
- **Guide** — overview, requirements, FAQ

**3 buttons (neeche):**
| Button | Kya hota hai |
|--------|--------------|
| **Save to garden** | Plant garden mein save |
| **Save to wishlist** | Sirf wishlist, garden nahi |
| **Not now** | Band, save nahi |

**Extra options (scroll par):**
- **Diagnose & fix** → issue + solution
- **Ask Botanist** → chat

---

## 3. Image / data kahan save hoti hai?

| Action | Kahan save |
|--------|------------|
| Scan success (garden save na ho) | **Snap History** (Garden tab → Snap History) |
| **Save to garden** | **My Garden** (local phone storage) |
| **Save to wishlist** | **Wishlist** (local) |
| Plant photo | App ke andar local file |

*Abhi sab local hai — backend sync baad mein.*

---

## 4. Issue solve kaise hota hai?

**Identify ≠ Diagnose** (alag step, alag API)

```
Result screen → "Diagnose & fix" tap
        ↓
Diagnose screen (AI)
        ↓
User dekhta hai:
  • Issue kya hai (disease / problem)
  • Symptoms
  • What to do (steps 1, 2, 3...)
  • Prevention / caution
        ↓
End par: Ask Botanist (extra help)
```

- Diagnose **save se pehle bhi** ho sakta hai
- Garden save **zaroori nahi** diagnose ke liye

---

## 5. Save to Garden ke baad — kya hota hai?

```
Save to garden tap
        ↓
Plant save (name, photo, care, group)
        ↓
App → Garden tab khul jata hai
        ↓
Snackbar: "Added to garden"
```

**Garden tab — 3 parts:**
| Tab | Kya hai |
|-----|---------|
| **My Garden** | Saved plants + daily care |
| **Tasks** | Water/care calendar |
| **Snap History** | Purani scans |

Plant card tap → **Plant Detail** (care edit, water, delete)

---

## 6. Water flow (save ke baad)

**Schedule kahan se:** Identify ki care info → water har X din

**User water kahan se mark kare:**
- Home → Daily Care / Water Meter
- Garden → Daily Care card
- Garden → plant card (quick water)
- Tasks tab → water task
- Plant Detail → Mark watered / Water Meter

**Mark watered ke baad:**
- Next water date update
- Streak update
- Tasks + Daily Care update

---

## 7. Poora flow — ek line mein

```
Photo → Identify → Result
              ↓
    ┌─────────┼─────────┐
    ↓         ↓         ↓
 Diagnose  Botanist  Save garden
 (issue)   (chat)         ↓
                      Garden tab
                           ↓
                    Water / Tasks / Detail
```

---

## 8. Developer — key files

| Step | File |
|------|------|
| Scan + photo | `plant_scan_controller.dart` |
| Identify process | `identify_flow.dart`, `identify_processing_view.dart` |
| Result UI | `identify_result_view.dart` |
| Diagnose | `identify_disease_view.dart` |
| Save garden | `my_garden_controller.dart` → `addPickedPlant()` |
| Snap history | `addIdentifySnap()` |
| Water | `water_meter_view.dart`, `daily_care_summary.dart` |
| API swap | `plant_scan_binding.dart` |

**APIs (live):**
- `POST /ai/identify` — scan par
- `POST /ai/diagnose` — diagnose tap par

**Demo flags (test):**
- `plant_scene_gate.dart` → `enabled = false`
- `plant_identify_repository.dart` → `demoUiSuccess = true`

---

*Short doc — Sep 2026*
