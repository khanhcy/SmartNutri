# SmartNutri Project Notes

Muc tieu cua file nay: giup bat nhip du an nhanh khi mo lai sau mot thoi gian.

## 1) Snapshot hien tai

- Project type: Flutter mobile app + Firebase backend + admin web scaffold.
- Firebase project dang dung: `smartnutri-dev-2e67b`.
- Firestore da duoc tao tren Firebase Console va da deploy:
  - `firestore.rules`
  - `firestore.indexes.json`
- Mobile da khoi tao Firebase trong app bootstrap.
- Auth va Profile da dung Firebase that:
  - `AuthService` -> Firebase Auth (email/password)
  - `ProfileService` -> Cloud Firestore (`profiles/{uid}`)

## 2) Kien truc code nhanh

- Mobile app:
  - `lib/src/app/bootstrap.dart`: khoi tao app + Firebase initialize + dependency providers.
  - `lib/src/features/auth/presentation/auth_gate.dart`: route theo trang thai auth/profile.
  - `lib/src/features/onboarding/presentation/onboarding_page.dart`: nhap profile lan dau.
  - `lib/src/core/services/auth_service.dart`: login/signup/signout voi Firebase Auth.
  - `lib/src/core/services/profile_service.dart`: get/upsert profile voi Firestore.
- Firebase:
  - `firebase.json`: config functions/firestore/hosting/flutter.
  - `.firebaserc`: map project default.
  - `firestore.rules`, `firestore.indexes.json`
  - `functions/src/index.ts`: hien tai moi co endpoint health check.
- Admin web:
  - `admin-web/src/firebase.ts`: firebase web config.
  - `admin-web/src/main.tsx`: login scaffold.

## 3) Luong chinh trong app

1. User vao app -> `AuthGate`.
2. Neu chua dang nhap -> `SignInPage`.
3. Neu da dang nhap nhung chua co profile/onboarding -> `OnboardingPage`.
4. Onboarding save vao `profiles/{uid}`.
5. Hoan tat -> vao `MainShellPage` (Home/Search/MealLog/Profile tabs).

## 4) Cac command thuong dung

### Flutter mobile

```powershell
cd D:\project\SmartNutri\SmartNutri
flutter pub get
flutter run
```

### Firebase deploy rules/indexes

```powershell
cd D:\project\SmartNutri\SmartNutri
firebase deploy --only firestore:rules,firestore:indexes
```

### Emulator Android (Windows)

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -list-avds
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd pixel_6_api34
flutter devices
flutter run
```

## 5) Cac diem de nham / loi thuong gap

- `firebase` bi chan boi PowerShell policy:
  - `Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser`
- `emulator` command not found:
  - Dung full path toi `emulator.exe` nhu tren.
- Sai ten AVD:
  - Luon copy dung ten tu `-list-avds` (vd: `pixel_6_api34`).
- Auth loi `CONFIGURATION_NOT_FOUND` tren Android:
  - Kiem tra da them SHA1 + SHA-256 cho app Android trong Firebase.
  - Tai lai `google-services.json` va dat dung vi tri `android/app/google-services.json`.
  - `flutter clean` + `flutter run` lai.
- Luu y:
  - Deploy Firestore rules/indexes KHONG tao data trong tab Data.

## 6) Du lieu Firestore dang dung

- Collection chinh da map trong app:
  - `profiles/{uid}`
- Cac collection plan tiep theo (chua build day du):
  - `goals`
  - `daily_logs`
  - `progress`
  - `food_items`, `workout_templates`, `meal_templates`

## 7) Tinh trang roadmap

- Foundation: gan xong (da qua buoc setup kho nhat).
- Core MVP: dang o muc co khung UI + auth/profile that, can them logic nghiep vu.
- AI/Notification/Reports/Admin CRUD day du: chua hoan thien.

## 8) Checklist moi lan quay lai du an

1. Mo file nay truoc.
2. Kiem tra Firebase project trong `.firebaserc`.
3. Chay emulator + `flutter run`.
4. Test nhanh:
   - Dang ky user moi
   - Hoan tat onboarding
   - Kiem tra Firestore co `profiles/{uid}`
5. Neu can deploy rules:
   - `firebase deploy --only firestore:rules,firestore:indexes`

## 9) Viec uu tien tiep theo (de day nhanh MVP)

1. Them data model goals/daily logs/progress vao Firestore.
2. Build metrics engine (BMI/BMR/TDEE + calories/macro target).
3. Chuyen dashboard va meal log tu data mock sang Firestore that.
4. Viet integration test auth -> onboarding -> profile.
5. Hoan thien admin CRUD cho foods/workouts/templates.
