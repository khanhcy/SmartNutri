# SmartNutri

SmartNutri là ứng dụng theo dõi dinh dưỡng tiếng Việt, tập trung vào ghi nhận bữa ăn, mục tiêu dinh dưỡng, nước uống, cân nặng, thống kê và hỗ trợ AI scan thực phẩm.

Project gồm ba phần chính:

- Mobile app Flutter trong `lib/`.
- Firebase backend: Auth, Firestore, Storage, Cloud Functions, Hosting.
- Admin web React/Vite trong `admin-web/`.

## Tech stack

- Flutter 3.x, Dart ^3.10.1
- Firebase Auth, Firestore, Storage, Functions, Hosting
- Provider, GoRouter
- Cloud Functions v2, Node.js 20, TypeScript
- React 18, TypeScript, Vite

Firebase project mặc định: `smartnutri-dev-2e67b`.

## Cài đặt nhanh

### Mobile app

```bash
flutter pub get
flutter run
```

Nếu Firebase config thay đổi, chạy lại FlutterFire config và kiểm tra các file generated:

- `lib/firebase_options.dart`
- `android/app/google-services.json`

### Cloud Functions

```bash
cd functions && npm install
cd functions && npm run build
```

### Admin web

```bash
cd admin-web && npm install
cd admin-web && npm run dev
```

## Kiểm tra chất lượng

### Flutter

```bash
flutter analyze
flutter test
flutter build apk --debug
```

### Cloud Functions

```bash
cd functions && npm run build
cd functions && npm run lint
```

### Admin web

```bash
cd admin-web && npm run build
```

## Firebase commands

```bash
firebase emulators:start --only functions,firestore,auth,storage
firebase deploy --only firestore:rules,firestore:indexes
firebase deploy --only storage
firebase deploy --only functions
firebase deploy --only hosting
```

Lưu ý: `firebase deploy --only firestore:rules,firestore:indexes` chỉ deploy rules/indexes, không tạo dữ liệu trong Firestore.

## Android emulator trên Windows

```powershell
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -list-avds
& "$env:LOCALAPPDATA\Android\Sdk\emulator\emulator.exe" -avd pixel_6_api34
flutter devices
flutter run
```

## Tài liệu

- `CLAUDE.md` — hướng dẫn làm việc cho Claude Code.
- `docs/README.md` — mục lục tài liệu.
- `docs/features.md` — chức năng chính.
- `docs/architecture.md` — kiến trúc và data flow.
- `docs/database.md` — Firestore/Storage schema và rules.
- `docs/backend.md` — Firebase backend và Cloud Functions.
- `docs/ai.md` — AI scan, Gemini, barcode, meal suggestions.
- `docs/status.md` — trạng thái hiện tại và checklist quay lại project.
- `docs/decisions.md` — quyết định kỹ thuật.

## Ghi chú thường gặp

- Nếu Firebase CLI bị chặn bởi PowerShell policy, chạy:

```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
```

- Nếu auth Android lỗi cấu hình, kiểm tra SHA-1/SHA-256 trong Firebase Console rồi tải lại `android/app/google-services.json`.
- Nếu Firebase config không cập nhật, thử `flutter clean` rồi chạy lại app.
- Storage rules đã giới hạn theo owner/admin path; nếu thêm upload media, dùng đúng path được phép.
