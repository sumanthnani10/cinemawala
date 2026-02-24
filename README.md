# Cinemawala

**Production management for film & video crews.**

Cinemawala is a cross-platform app for production teams to manage projects, cast, crew, locations, schedules, and daily operations—all in one place. Built with Flutter and Firebase.

---

## What is Cinemawala?

Cinemawala helps film and video production teams:

- **Organize** multiple projects with roles and permissions  
- **Manage** casting, costumes, props, locations, and scenes  
- **Plan** shoot schedules and strip boards  
- **Track** daily budget and generate call sheets / PDF reports  
- **Collaborate** with a personal calendar and project-based access  

The app runs on **Android**, **iOS**, and **Web**, with a shared backend (Firebase + Node.js).

---

## Features

| Feature | Description |
|--------|-------------|
| **Projects** | Create projects, invite members, assign roles (owner/collaborator), and switch between projects. |
| **Casting** | Add and manage artists/cast, link to projects, store photos and details. |
| **Costumes** | Track costumes per project with images and notes. |
| **Art department (props)** | Manage props, attach images, and associate with scenes. |
| **Strip board / Scenes** | Define scenes with locations, cast, costumes, and props; build strip boards. |
| **Roles** | Assign crew roles to users, manage permissions, and handle role requests. |
| **Schedule** | Create and edit shoot schedules, link scenes and dates. |
| **Locations** | Maintain a locations list with photos and reuse across scenes. |
| **Daily budget** | Track daily budget entries per project. |
| **Personal calendar** | Notes and calendar view for your own schedule. |
| **PDF / call sheets** | Generate PDFs (call sheets, scene details) for print or share. |
| **Auth** | Email/password sign-in and registration via Firebase Auth; optional forgot-password flow. |

---

## Tech stack

- **Client:** Flutter (Dart) — Android, iOS, Web  
- **Auth & data:** Firebase (Auth, Firestore)  
- **Backend APIs:**  
  - **Firebase Functions** (`cinemawala_apis/`) — Cloud Functions (Express) for auth, users, projects, validation, uploads  
  - **Node.js server** (`cinemawala_aws/`) — Express + MongoDB for images, projects, scenes, schedules, roles, and other app logic  
- **Storage:** Firebase Storage (e.g. images), optional local storage for exports  

---

## Project structure

```
cinemawala/
├── lib/                    # Flutter app (screens, widgets, utils)
├── android/                # Android app and config
├── ios/                    # iOS app and config
├── web/                    # Web app entry and assets
├── cinemawala_apis/        # Firebase Functions backend
│   ├── functions/           # Node (Express) + Firebase Admin
│   └── .firebaserc         # Firebase project (use placeholder in repo)
├── cinemawala_aws/         # Node.js backend (Express + MongoDB)
├── assets/                 # Images, fonts
├── .env.example            # Example env vars for backends
└── *.example               # Example configs (Firebase, Android, iOS)
```

---

## Prerequisites

- **Flutter** SDK (see [flutter.dev](https://flutter.dev))  
- **Node.js** (for backend and Firebase Functions)  
- **Firebase** project (Auth, Firestore, Storage, Functions)  
- **MongoDB** (for `cinemawala_aws` backend)  
- **Google Cloud / Firebase** service account key (for backend APIs)

---

## How to run

The repo is **safe to push**: no secrets are committed. You provide config and keys locally or via environment variables.

### 1. Backend (APIs)

**Option A – Local JSON key (dev)**  
- Copy `cinemawala_apis/functions/b1d668fbd6.json.example` → `b1d668fbd6.json` in both:
  - `cinemawala_apis/functions/`
  - `cinemawala_aws/`
- Replace placeholders with your Firebase service account JSON (from Firebase Console → Project settings → Service accounts).

**Option B – Environment variables (CI/production)**  
- Set one of:
  - `GOOGLE_APPLICATION_CREDENTIALS` — path to service account JSON, or  
  - `FIREBASE_SERVICE_ACCOUNT_JSON` — full JSON string  
- Optional: `FIREBASE_STORAGE_BUCKET` = `your-project-id.appspot.com`  
- See `.env.example` for a template; copy to `.env` and never commit `.env`.

**Run the backends**  
- **Firebase Functions:** From `cinemawala_apis`: `firebase emulators:start --only functions` or deploy with `firebase deploy --only functions`. Set project first: `firebase use YOUR_PROJECT_ID` (or edit `.firebaserc`).  
- **cinemawala_aws:** From `cinemawala_aws`: `npm install` then `node index.js` (ensure MongoDB is running and configured).

### 2. Flutter client (Android / iOS / Web)

**Firebase config (required for Auth and Firestore)**  
- **Android:** Copy `android/app/google-services.json.example` → `android/app/google-services.json` and fill in your Firebase Android app config.  
- **iOS:** Copy `ios/Runner/GoogleService-Info.plist.example` → `ios/Runner/GoogleService-Info.plist` and fill in your Firebase iOS app config.  
- **Web:** Edit `web/index.html` and replace the placeholder `firebaseConfig` with your Firebase web app config.

**API base URL**  
- The app talks to your backend via `Utils.DOMAIN` and `Utils.URL_PATH` in `lib/utils.dart`. For local dev, point these to your Node/Functions URLs (e.g. emulator or `cinemawala.in` for production).

### 3. Run the app

```bash
# Dependencies
flutter pub get

# Run on connected device or emulator
flutter run

# Or target a platform
flutter run -d chrome    # Web
flutter run -d android   # Android
flutter run -d ios       # iOS (macOS only)
```

---

## Deployment

- **Flutter:** Build release artifacts (e.g. `flutter build apk`, `flutter build ios`, `flutter build web`) and deploy to stores or hosting.  
- **Firebase Functions:** From `cinemawala_apis`, run `firebase use YOUR_PROJECT_ID` then `firebase deploy --only functions`.  
- **cinemawala_aws:** Deploy the Node app to your preferred host (e.g. Cloud Run, App Engine, VPS) and set env vars (including `FIREBASE_SERVICE_ACCOUNT_JSON` or `GOOGLE_APPLICATION_CREDENTIALS` and `FIREBASE_STORAGE_BUCKET`).

---

## Config and secrets (summary)

| Item | In repo? | What to do |
|------|----------|------------|
| Code + `.example` files | ✅ Yes | Clone and use as-is. |
| `b1d668fbd6.json` | ❌ No | Add locally or use env (see Backend above). |
| `google-services.json`, `GoogleService-Info.plist` | ❌ No | Copy from `.example` and fill from Firebase Console. |
| `web/index.html` Firebase config | ✅ Placeholders | Replace locally or inject in build. |
| `.firebaserc` | ✅ Placeholder | Set project: `firebase use YOUR_PROJECT_ID` or edit locally. |
| `.env` | ❌ No | Copy from `.env.example` and fill; do not commit. |

---

## License

See repository license file (if present). Use and modification at your own responsibility.

---

## Contributing

Contributions are welcome. Please open an issue or pull request and follow the project’s code style and structure.
