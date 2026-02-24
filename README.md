# cinemawala

Cinemawal.in

## Pushing to the repo (no secrets)

This repo is **safe to push** to a public or private repo. Secrets are **not** committed:

- **Backend (Node):** Service account keys are in `.gitignore`. Use **env vars** in CI/production (see below).
- **Flutter client:** `google-services.json` and `GoogleService-Info.plist` are in `.gitignore`. Use the **.example** files and fill locally, or generate from env in CI.
- **Web / Firebase / .firebaserc:** Only placeholders are committed. Replace locally or inject from env at build time.

So you **push the code and placeholders**; each environment (your machine, CI, teammates) provides its own keys.

---

## How to run locally (two options)

### Option A: Local secret files (simplest for dev)

1. **Backend** – Keep `b1d668fbd6.json` in `cinemawala_apis/functions/` and `cinemawala_aws/` (they are gitignored). The app will load them automatically. No env needed.
2. **Android** – Copy `android/app/google-services.json.example` → `android/app/google-services.json` and fill in your Firebase config.
3. **iOS** – Copy `ios/Runner/GoogleService-Info.plist.example` → `ios/Runner/GoogleService-Info.plist` and fill in your Firebase config.
4. **Web** – Edit `web/index.html` and replace the placeholder Firebase config with your real web config.
5. **Firebase deploy** – Run `firebase use your-project-id` or edit `cinemawala_apis/.firebaserc` (this file is committed with a placeholder).

### Option B: Environment variables (good for CI and production)

1. **Backend** – Set one of:
   - `GOOGLE_APPLICATION_CREDENTIALS` = path to your service account JSON, or  
   - `FIREBASE_SERVICE_ACCOUNT_JSON` = full JSON string of the service account.  
   Optional: `FIREBASE_STORAGE_BUCKET` = `your-project.appspot.com`.
2. Copy `.env.example` to `.env`, fill in the values, and load `.env` when starting the Node apps (e.g. `dotenv` or your shell `export`). Never commit `.env`.

Flutter (Android/iOS/Web) still needs the config files or a build step that injects keys; env is mainly for the Node backends.

---

## Summary: what to push vs what stays local

| Item | Push to repo? | How to run / deploy |
|------|----------------|---------------------|
| Code + `.example` files | ✅ Yes | — |
| `b1d668fbd6.json` | ❌ No (gitignored) | Keep locally **or** set `FIREBASE_SERVICE_ACCOUNT_JSON` / `GOOGLE_APPLICATION_CREDENTIALS` |
| `google-services.json`, `GoogleService-Info.plist` | ❌ No (gitignored) | Copy from .example and fill **or** generate in CI from secrets |
| `web/index.html` (with placeholders) | ✅ Yes | Replace placeholders locally or inject in build from env |
| `.firebaserc` (with placeholder) | ✅ Yes | Run `firebase use <project-id>` or edit locally |
| `.env` | ❌ No (gitignored) | Copy from `.env.example`, fill, use for Node backends |

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://flutter.dev/docs/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://flutter.dev/docs/cookbook)

For help getting started with Flutter, view our
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
