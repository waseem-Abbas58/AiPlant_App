# AiPlant — Poora Flow + Production Checklist (Urdu)

> **Developer se confirm karwana hai:** Kya ye flow theek hai? Agar **Yes** → isi hisaab se **Phase** banayenge aur implement karenge.

---

## Pehle kya missing thi? (Go flows)

Scanner checklist mein sirf **camera → identify → result → diagnose** tha.  
Ham ne add kiya ke **scan ke baad user kahan jata hai** — ye pehle missing thi:

| Go flow | Kya hota hai |
|---------|--------------|
| **Save to Garden** | Plant save → Garden tab khul jata hai |
| **Save to Wishlist** | Wishlist mein, garden nahi |
| **Not now** | Band, save nahi |
| **Snap History** | Successful scan ki copy (save na ho to bhi) |
| **Ask Botanist** | Chat, plant ke sath |
| **Water / Daily Care** | Save ke baad Home/Garden se water track |
| **Tasks calendar** | Garden → Tasks tab care tasks |
| **Plant Detail** | Garden card tap → care edit, water |

**Zaroori baat:** Failed / non-plant scan **Snap History mein nahi jana chahiye** — ye checklist mein hai.

---

## Final rule (sab ko yaad rakho)

```
Sahi photo → Plant confirm → Confidence check → Result
```

**Kabhi nahi:**
```
Koi bhi photo → Zabardasti plant ka naam
```

**Trust:** Galat confident jawab se **"Pakka nahi" / "I'm not sure"** behtar hai.

---

## P0 — Production se pehle (zaroori fix)

### 1. Demo / Fake AI band
- Saari demo responses aur bypass hatao
- Sirf **live production API** use ho

### 2. Photo quality check (API se pehle)
- Blur / dhundla
- Bohot andhera / kam light
- Plant chota ya door hai

**Kharab photo identify ke liye na bhejo.**

### 3. Non-plant protection
- Laptop, keyboard, furniture → **kabhi plant result na mile**
- Flow ruko → "Dubara scan karo"

### 4. Confidence handling
| Level | Kya dikhao |
|-------|------------|
| **High** | Normal result — naam + care |
| **Medium** | **"Possible match"** + doosre options |
| **Low** | Final naam **mat dikhao** — clear / extra photo mangao |

### 5. "Multiple" rename
- **"Multiple Angles"** likho
- Helper: *"Behtar result ke liye same plant ki 2–3 photos lo."*

### 6. Multiple Angles fix
- **Saari photos** API ko jayein
- Same plant verify karo
- API support na ho → feature **band** rakho jab tak theek na ho

### 7. Fail screen — 2 options
- **Scan Again** (dubara camera)
- **Choose from Gallery** (gallery se photo)

### 8. API / Network fail (alag message)
Invalid photo se **alag** ho:

> "Abhi analyze nahi ho saka."  
> Aap ki photo theek lag rahi hai, lekin identification service filhal available nahi hai.

**Actions:** Try Again | Back

*(No internet, timeout, rate limit, server error — ye sab yahan)*

---

## P1 — Agle improvements (polish)

### 1. Processing text (generic)
"Looking at the leaf" **mat likho**. Use karo:
1. Checking photo quality
2. Looking for a plant
3. Analyzing plant features
4. Comparing possible matches
5. Preparing result

### 2. Ek photo mein kai plants
> "Kai plants nazar aa rahe hain. Behtar result ke liye ek par focus karo."

**Action:** Retake Photo  
*(Baad mein: user tap karke choose kare)*

### 3. Result par confirm
- **Yes, this is my plant** (Haan, ye meri plant hai)
- **Not the right plant** (Galat hai)

Galat ho → similar matches ya nayi photo

### 4. Diagnose alag flow (identify photo reuse na ho)

```
Plant Result
    ↓
Check Health / Diagnose & Fix
    ↓
Kya masla hai?
    ↓
  Pile patte | Brown spots | Murjhana | Ched / kaat
  Safed coating | Keere | Other / Pakka nahi
    ↓
Nayi health photos lo
    ↓
  Poori plant | Close-up affected area | Neeche ka patta (optional)
    ↓
Disease API
    ↓
Diagnosis result
```

---

## Go flows — design jaisa rakho (change mat karo)

### Scan se Result tak
```
Scan tab / Home tool → Photo (camera / gallery)
    ↓
Processing → Identify (sirf naam + care)
    ↓
Result screen
```

### Result par user kya kar sakta hai
- Naam edit
- Care tips, health card, similar matches, toxicity
- **Diagnose & Fix** (alag step)
- **Ask Botanist**
- **Save to garden** | **Wishlist** | **Not now**

### Save to Garden ke baad (Go)
```
Save to garden
    ↓
Plant local save (name, photo, care, group)
    ↓
App → Garden tab
    ↓
Snackbar: "Added to garden"
```

### Garden ke andar (Go)
| Tab | Kaam |
|-----|------|
| **My Garden** | Plants + Daily Care (streak, water today) |
| **Tasks** | Calendar — water/care |
| **Snap History** | Purani scans (sirf **successful** identify) |

### Water flow (Go — save ke baad)
- Home → Daily Care / Water Meter
- Garden → Daily Care card
- Plant card → quick water
- Tasks → water task
- Plant Detail → Mark watered / Water Meter

**Mark watered ke baad:** next date update, streak, tasks update

### Identify ≠ Diagnose (locked)
- Pehle species/name (Identify)
- Phir user khud **Diagnose & Fix** tap kare
- Dono alag API

### Ye cheezein result par rahein
- Care info
- Similar matches
- Toxicity (data na ho → "Data unavailable")
- Health entry / Check Health
- Diagnose & Fix (manual)

---

## Developer ne confirm kiya (Sep 2026)

**Verdict:** Flow **~90–92% sahi**. P0 + real testing ke baad **95%+**.

**5 naye rules:**
- A. Image preprocessing (orientation, resize, over-compress na karo)
- B. Duplicate-angle check
- C. Confidence thresholds real scans se calibrate — blind 90/60 mat karo
- D. Har scan unique `scan_id` — cancel/retry par overwrite na ho
- E. Plant API data alag, LLM sirf explanation — species/toxicity invent na kare

**Multiple Angles:** **Rakhna hai** — disable mat karo. Lekin **ONE request mein saari photos**. Abhi bug: sirf pehli photo jati hai — fix zaroori.

**Architecture:** API keys backend par, cheap validation pehle / paid API baad, max 1 retry, Snap = success only, `PlantIdentification` ≠ `PlantDiagnosis`

Detail: [`FLOW_DEVELOPER_APPROVED.md`](FLOW_DEVELOPER_APPROVED.md)

---

## Phase plan (developer approved)

| Phase | Kya hoga |
|-------|----------|
| **Phase 1 — P0 Core** | Live API proxy, quality, non-plant, confidence, preprocessing, Multiple Angles one-request fix, scan_id, API errors |
| **Phase 2 — Real Device Testing** | 100+ scans, threshold calibration |
| **Phase 3 — Go flows verify** | Save → Garden → Water → Snap |
| **Phase 4 — P1 Polish** | Processing UX, confirm buttons, multi-plant, diagnose capture |
| **Phase 5 — Safety** | LLM separate, toxicity authoritative only |

---

## Score

| Abhi | P0 ke baad | P0 + P1 + Go |
|------|------------|--------------|
| ~82% | Production testing ready | ~95% polished |

Baqi quality **API accuracy** aur **real phone testing** par depend karegi.

---

*Urdu handoff doc — Sep 2026*
