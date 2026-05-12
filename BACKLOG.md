# SmartNutri Backlog

## In progress

- Giai đoạn 1 — Ổn định production foundation: food schema standardization.

## High priority

- Chuẩn hóa food schema giữa Flutter app, admin web và Cloud Functions.
- Tạo hoặc cập nhật manual test checklist cho core flows.
- Dùng Firestore `foods` làm source of truth chính, seed local chỉ là fallback.

## Medium priority

- Cải thiện admin foods CRUD/import CSV theo schema thống nhất.
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
- Thêm tests: `ai_food_service_error_test.dart` (3), `barcode_service_error_test.dart` (3), `nutrition_goal_test.dart` (8). Flutter 23 tests pass, analyze sạch.

## Cancelled / not doing

- Chưa đổi Provider sang state management khác; chưa có nhu cầu đủ mạnh.
