# SmartNutri Project Status

## App overview

SmartNutri là app theo dõi dinh dưỡng tiếng Việt gồm Flutter mobile app, Firebase backend, Cloud Functions và React admin web.

## Current development focus

Giai đoạn 1 trong roadmap: ổn định production foundation trước khi mở rộng tính năng.

## Completed features

- Mobile auth, onboarding và auth-gated routing.
- Home dashboard với calories, macros, nước, streak, bữa hôm nay và AI suggestions.
- Meal log, food search, profile, statistics, water tracking và weight tracking.
- AI photo scan, barcode lookup và meal suggestions qua Cloud Functions.
- Admin web scaffold với login, dashboard, foods và users.
- Admin web route guard đã yêu cầu tài khoản có admin claim.

## Partially completed features

- Food catalog đã có Firestore loading và seed fallback, nhưng chưa hoàn toàn là source of truth chuẩn hóa.
- Admin web có quản lý foods/users cơ bản, nhưng còn thiếu hardening và tối ưu dữ liệu lớn.

## Recently completed

- AI/barcode error states: `AiFoodServiceException` và `BarcodeLookupException` với message tiếng Việt, UI catch và hiển thị lỗi rõ ràng cho từng loại (auth, 5xx, mạng, invalid response).
- `FunctionCaller` interface và `FoodCatalog` abstract class cho DI/testing.
- Admin web `AuthGuard` chặn route với admin claim + `AccessDenied` component.
- Tests: `ai_food_service_error_test.dart` (3 tests), `barcode_service_error_test.dart` (3 tests), `nutrition_goal_test.dart` (8 tests). Tổng 23 tests pass, analyze sạch.

## Missing features

- Storage rules theo owner path.
- Manual release/test checklist đầy đủ cho core flows.
- Integration tests cho auth → onboarding → dashboard và meal logging.
- Food data verification workflow.
- Daily logging UX nâng cao như favorite foods, copy meal và portion selector.
- Weekly review/insights.

## Known bugs / risks

- Storage upload có thể lỗi nếu code mới dùng path ngoài `users/{uid}/...` hoặc `admin/...`.
- Admin users/dashboard có rủi ro N+1 query khi dữ liệu tăng.
- Test coverage còn yếu, chưa có integration test.

## Test status

- Flutter: 23 tests pass, `flutter analyze` sạch (2026-05-13).
- Admin web build đã pass sau thay đổi admin-only guard.

## Recent decisions

- Ưu tiên roadmap theo hướng: production foundation → food database → daily logging UX → test/release readiness → retention insights.
- Provider hiện tại vẫn đủ dùng; chưa ưu tiên đổi state management.
- Đã hoàn thành chuẩn hóa AI/barcode error states với exception classes và UI error hiển thị rõ ràng.

## Next recommended action

Tiếp tục Giai đoạn 1: chuẩn hóa food schema giữa Flutter app, admin web và Cloud Functions, đảm bảo Firestore `foods` là source of truth chính. Sau đó cập nhật storage rules và tạo manual test checklist cho core flows.
