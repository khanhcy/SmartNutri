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
   - then replace placeholder values in `lib/src/core/firebase/firebase_options.dart`
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

- Firebase credentials in both mobile and admin are placeholders and must be replaced.
- This repository now contains baseline architecture for:
  - Foundation setup (`foundation-setup`)
  - Auth + onboarding + profile flow (`core-auth-onboarding`)