# Authentication & Firebase Plan

> **Do not implement now.** This document describes the **EXISTING** auth UI and the **RECOMMENDED** Firebase Authentication plan.

Related: [Project Overview](PROJECT_OVERVIEW.md) · [Architecture](ARCHITECTURE.md)

---

## Screens that already exist

| Screen | Route | Fields / actions | Wired to real auth? |
|---|---|---|---|
| Login | `/authentication` | Email, password, Forgot, Sign up, Google/Apple/Facebook | **No** — `AppSession.markLoggedIn()` then Home |
| Signup | `/signup` | Name, email, password, same social buttons | **No** — `formKey.validate()` only; **does not navigate or create a user** |
| Forgot password | `/forgot-password` | Email | **No** — goes to OTP |
| OTP | `/otp-verification` | 6-digit code, 45s resend | **No** — accepts demo `123456` |
| Reset password | `/reset-password` | New + confirm | **No** — timer then success |
| Reset success | `/password-reset-success` | Continue to login | Local only |
| Change password | Profile → Personal data | Current / new / confirm | **No** — snackbar “Password updated.” |

**NOT PRESENT:** Email-verification screen, phone OTP login, guest/skip login, “remember me”, terms checkbox on signup.

Social buttons exist on Login and Signup. Handlers are empty (`onGoogleLogin()`, `onAppleLogin()`, `onFacebookLogin()`).

---

## Flow the current UI expects

```
Splash
  → Onboarding (first time)
  → Login
       ├─ valid form → Home (local flag)
       ├─ Forgot → OTP (123456) → Reset → Success → Login
       ├─ Sign up → validate only (incomplete)
       └─ Google / Apple / Facebook → empty handlers
Home / Profile
  → Log out → Login
  → Delete account → wipe local prefs → Login
  → Change password → fake success
```

OTP is **password-reset only**, not signup verification. Comment in code: *not generated/verified by a server, Firebase, or API*.

`AppStrings.skip` exists but is **not used**. There is no guest mode.

---

## Session today (EXISTING)

`AppSession` uses SharedPreferences:

- `onboarding_seen`
- `session_logged_in` (boolean only)

Login does **not** verify credentials. Signup does **not** write profile fields. Profile name/email are edited separately in Profile and stored under `profile_*` keys.

Local profile fields: display name, email, garden name, location (typed city), photo path, random 20-char `userId`, notification toggles, reminder time, passcode hash, biometric flag.

Location is **manual autocomplete** from `ProfileLocations` (Pakistan-first city list). **No GPS.**

App lock (6-digit + optional fingerprint) is **device-only**. Do not store the passcode in Mongo.

---

## Firebase Authentication methods (RECOMMENDED)

Authentication should be handled with **Firebase Authentication**.

| Method | Why |
|---|---|
| **Email/password** | Login + signup fields exist |
| **Password reset** (email or custom OTP) | Forgot + 6-digit OTP UI exists |
| **Google** | Button exists |
| **Apple** | Button exists (required on iOS if Google is offered) |
| **Facebook** | Button exists — optional; can hide later if unused |
| **Email verification** | **NOT in UI today.** Optional later |
| Phone auth | **NOT in UI** — skip |

**OTP mapping:** keep the 6-digit screen; backend can send a reset OTP, **or** switch that screen later to “check your email” and use Firebase `sendPasswordResetEmail`. Do not implement in this Flutter repo until the backend task starts.

Login/signup themselves should hit the **Firebase client SDK**, not a custom password store.

---

## What to store in MongoDB alongside Firebase Auth (RECOMMENDED)

Firebase holds identity (`uid`, email, providers). Mongo should hold **app profile**:

- `firebaseUid` (unique)
- `displayName`, `gardenName`, `location` (string city, not lat/lng)
- `email` (denormalized)
- `photoUrl`
- `plan` / subscription status
- notification preference map (ids already in `ProfileNotifications`)
- `createdAt`, `updatedAt`, `lastLoginAt`
- soft-delete flag

**Do not store:** raw password, passcode hash, biometric secrets.

Suggested first user API:

| Method | Route | Purpose |
|---|---|---|
| POST | `/v1/users/sync` | Create/update Mongo user after Firebase login |
| GET | `/v1/users/me` | Profile |
| PATCH | `/v1/users/me` | Edit name, gardenName, location, photoUrl |
| DELETE | `/v1/users/me` | Delete Firebase user + Mongo + images |

---

## Current Firebase configuration — NOT PRESENT

- No `firebase_core` / `firebase_auth` / `cloud_firestore` / `firebase_storage` / `firebase_messaging` in `pubspec.yaml`
- No `google-services.json` / `GoogleService-Info.plist`
- No `Firebase.initializeApp`
- Only mention: OTP comment saying Firebase is **not** used

`dio` is listed in `pubspec.yaml` but unused. Ready for later HTTP.

---

## Other Firebase services

| Service | Verdict |
|---|---|
| **Firebase Authentication** | **Required** for the planned backend |
| **Firebase Admin SDK** (Node) | **Required** — verify ID tokens, delete users, optional FCM / custom claims |
| **Firebase Cloud Messaging** | Later — UI has toggles, no FCM package |
| **Firebase Storage** | Optional. Prefer Cloudinary or S3 for plant images |
| **Firestore / Realtime DB** | **Not recommended** as primary DB (use MongoDB) |

---

## App lock vs account security

| Concern | Where it lives |
|---|---|
| Email / password / social | Firebase Auth |
| Profile fields | MongoDB |
| 6-digit passcode + fingerprint | **On device only** |
| Change password screen | Firebase `updatePassword` later |

---

[← Backend index](README.md)
