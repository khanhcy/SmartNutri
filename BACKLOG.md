# SmartNutri Backlog

## In progress

- Giai đoạn 1 — Ổn định production foundation: chạy manual UI core flow verification trên emulator/thiết bị thật theo `docs/test-checklist.md`.

## High priority

- Chạy tiếp manual test checklist cho auth/onboarding (flow thêm meal thực tế đã pass; barcode UI và AI picker đã verify).
- Verify happy-path AI scan/barcode với backend sẵn sàng để xác nhận end-to-end trả kết quả thành công.
- Cleanup dữ liệu `goals/{uid}` lỗi (nếu còn) sau khi đã có fallback guard trong app.
- Kiểm tra dữ liệu Firestore `foods` thật và lập migration/cleanup riêng nếu còn legacy fields.
- Dùng Firestore `foods` làm source of truth chính, seed local chỉ là fallback.

## Medium priority

- Tối ưu admin users/dashboard để tránh N+1 query khi dữ liệu tăng.
- Thêm favorite foods.
- Cải thiện quick add từ recent foods.
- Thêm copy meal từ hôm qua hoặc ngày khác.
- Thêm portion selector theo gram, khẩu phần, chén, tô hoặc đơn vị phổ biến.
- Thêm undo khi xóa meal entry.
- Thêm confirm/edit screen tốt hơn sau AI scan/barcode.
- Thêm unit/widget tests cho logic và flow quan trọng.

## Low priority

- Weekly Review.
- Personalized insights.
- Calendar heatmap.
- Goal adherence score.
- Achievement/streak nâng cao.
- AI scan quota hoặc premium gating.
- Premium reports, meal plans, coach mode hoặc export PDF/CSV.

## Blocked

- Production release: đang chờ Storage rules, test checklist và core flow verification.

## Done

- Tạo `ROADMAP.md` với lộ trình nhiều giai đoạn.
- Chặn admin web routes bằng admin claim trong `AuthGuard`.
- Review code phần admin-only guard và tách `AccessDenied` component nhỏ.
- Chạy `npm --prefix admin-web run build` thành công sau thay đổi admin guard.
- Siết `storage.rules` theo owner/admin path: user chỉ truy cập `users/{uid}/...`, admin chỉ truy cập `admin/...` với admin claim.
- Chuẩn hóa AI/barcode error states: `FunctionCaller` interface, `FunctionsException`, `AiFoodServiceException`, `BarcodeLookupException` với message tiếng Việt.
- Cập nhật UI photo scan và barcode scan catch exception hiển thị lỗi rõ ràng.
- `FoodCatalog` abstract class cho DI/testing, `FoodService` implements `FoodCatalog`.
- Thêm tests: `ai_food_service_error_test.dart` (4), `barcode_service_error_test.dart` (4), `nutrition_goal_test.dart` (8). Flutter 38 tests pass, analyze sạch (2026-05-14).
- Thêm widget tests cho auth/onboarding/food tile/meal groups/custom meal, gồm validation, success và error state cho nhập món thủ công.
- Chuẩn hóa food schema giữa Flutter app, admin web và Cloud Functions: Flutter đọc canonical/legacy và fallback Firestore doc id, admin foods CRUD/import CSV ghi canonical, `seedFoods` normalize payload. `flutter analyze`, `flutter test` (43 tests), admin build, Functions build/lint đều pass (2026-05-14).
- Cập nhật `docs/test-checklist.md` thành manual checklist chi tiết cho core flows, Firebase rules, Cloud Functions và admin web verification.
- Chạy automated release baseline: `flutter analyze`, `flutter test` (43 tests), `flutter build apk --debug`, Functions build/lint và admin build đều pass; admin build còn cảnh báo Vite chunk lớn (2026-05-14).
- Chạy manual emulator smoke test: app launch, dashboard, food search, meal log empty state và add-action sheet pass.
- Fix guard cho goal bất thường: thêm `NutritionGoal.resolveForDisplay` và áp dụng tại Home/Meal log/Profile; verify emulator cho thấy dashboard về `2312 kcal` thay vì `153440 kcal`.
- Manual meal logging flow pass trên emulator: `Nhật ký -> + -> Tìm món thủ công -> Thêm vào nhật ký`, ghi thành công `Phở bò 400g` với `272 kcal`.
- Manual barcode flow verification (UI-level) pass trên emulator: mở được `Quét mã vạch`, hiển thị scan frame, hint text và torch button.
- Manual AI gallery entrypoint verification pass: mở `Chụp ảnh món ăn` và Android Photo Picker thành công.
- Fix blocker AI scan treo loading: thêm timeout 20 giây trong `CloudFunctionClient.call`, re-test cho thấy sau khi chọn ảnh app hiển thị lỗi mạng rõ ràng thay vì treo `AI đang phân tích...` vô hạn.

## Cancelled / not doing

- Chưa đổi Provider sang state management khác; chưa có nhu cầu đủ mạnh.
