# SmartNutri MVP Foundation

SmartNutri is structured as a 3-part MVP foundation:
- `Flutter mobile app` in this root project.
- `Firebase backend` with Auth, Firestore, Functions.
- `Admin web` scaffold in `admin-web`.

## Mobile app

### Implemented core
- Email/password sign in and sign up using Firebase Auth.
- Auth gate that routes:
  - unauthenticated users to sign in
  - authenticated users without profile to onboarding
  - completed users to dashboard
- Onboarding profile capture:
  - display name, age, height, weight, gender, activity level
- Profile persistence in Firestore collection `profiles/{uid}`.

### Run mobile
1. Install packages:
   - `flutter pub get`
2. Configure Firebase options:
   - `flutterfire configure`
   - generated config is in `lib/firebase_options.dart`
   - `lib/src/core/firebase/firebase_options.dart` re-exports the generated file
3. Run:
   - `flutter run`

## Firebase backend scaffold

Files added:
- `firebase.json`
- `.firebaserc`
- `firestore.rules`
- `firestore.indexes.json`
- `functions/` (TypeScript function scaffold)

Run locally:
1. `cd functions`
2. `npm install`
3. `npm run build`
4. `firebase emulators:start --only functions,firestore,auth`

## Admin web scaffold

Path: `admin-web`

Features:
- React + Vite setup
- Firebase client bootstrap
- Basic admin login screen (Firebase Auth)

Run:
1. `cd admin-web`
2. `npm install`
3. `npm run dev`

## Notes

- Firebase has been connected to project ID: `smartnutri-dev-2e67b`.
- Firestore rules and indexes have been deployed successfully.
- Mobile app now initializes Firebase in `lib/src/app/bootstrap.dart`.
- `AuthService` uses `FirebaseAuth` and `ProfileService` uses `Cloud Firestore`.
- This repository now contains baseline architecture for:
  - Foundation setup (`foundation-setup`)
  - Auth + onboarding + profile flow (`core-auth-onboarding`)

## Quick return checklist (when reopening this project)

### 1) First 60 seconds
- Confirm current Firebase project:
  - `firebase projects:list`
  - `cat .firebaserc` (or open file in editor)
- Confirm generated Firebase config exists:
  - `lib/firebase_options.dart`
- Confirm Android Firebase file exists:
  - `android/app/google-services.json`

### 2) Start Android emulator from terminal (Windows)
- List AVDs:
  - `& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -list-avds`
- Start AVD (current known name):
  - `& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd pixel_6_api34`
- Run app:
  - `flutter devices`
  - `flutter run`

### 3) Common gotchas
- PowerShell script block for Firebase CLI:
  - If `firebase.ps1` is blocked, run:
    - `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- `emulator` command not found:
  - Use full path command above, or add SDK paths to `$env:Path`.
- AVD not found:
  - Use exact output from `-list-avds` (case-sensitive naming matters).

### 4) What "deploy firestore" does and does not do
- `firebase deploy --only firestore:rules,firestore:indexes` updates:
  - Security rules
  - Index definitions
- It does **not** create user data in Firestore `Data` tab.

### 5) Quick verification after login/onboarding
- Create account in app -> complete onboarding.
- In Firebase Console -> Firestore -> `profiles` collection:
  - expect a document with id = authenticated `uid`.