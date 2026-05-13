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

- Food catalog đã có Firestore loading, local seed fallback và schema Firestore chuẩn hóa; còn cần kiểm tra/migrate dữ liệu thật nếu collection cũ còn legacy fields.
- Admin web có quản lý foods/users cơ bản, nhưng còn thiếu hardening và tối ưu dữ liệu lớn.

## Recently completed

- AI/barcode error states: `AiFoodServiceException` và `BarcodeLookupException` với message tiếng Việt, UI catch và hiển thị lỗi rõ ràng cho từng loại (auth, 5xx, mạng, invalid response).
- `FunctionCaller` interface và `FoodCatalog` abstract class cho DI/testing.
- Admin web `AuthGuard` chặn route với admin claim + `AccessDenied` component.
- Tests: `ai_food_service_error_test.dart` (4 tests), `barcode_service_error_test.dart` (4 tests), `nutrition_goal_test.dart` (8 tests) và các widget tests cho auth/onboarding/food tile/meal groups/custom meal. Tổng 38 Flutter tests pass, analyze sạch (2026-05-14).
- Chuẩn hóa food schema giữa Flutter, admin web và Cloud Functions: readers đọc được canonical/legacy fields, new writes dùng canonical fields, `seedFoods` normalize payload. Flutter 43 tests pass, admin build pass, Functions build/lint pass (2026-05-14).
- Cập nhật [docs/test-checklist.md](docs/test-checklist.md) thành manual checklist chi tiết cho core flows: setup, auth, onboarding, dashboard, meal log, food search, AI scan, barcode, stats, profile/goals, Firebase rules, Functions và admin web.
- Automated release baseline pass: `flutter analyze`, `flutter test` (43 tests), `flutter build apk --debug`, `npm --prefix functions run build`, `npm --prefix functions run lint`, `npm --prefix admin-web run build` đều pass; admin build còn cảnh báo Vite chunk lớn.
- Manual emulator smoke test trên Android 14 API 34 pass cho launch, dashboard, food search, meal log empty state và add-action sheet.
- Đã thêm guard logic cho goal bất thường: Home/Meal log/Profile tự fallback về goal hợp lý từ profile/default khi dữ liệu `goals/{uid}` bị lỗi; verify lại trên emulator, dashboard test user hiển thị `2312 kcal`.
- Manual flow `Nhật ký -> + -> Tìm món thủ công -> Thêm vào nhật ký` đã pass trên emulator; meal `Phở bò 400g` được ghi thành công với `272 kcal` và macros hiển thị đúng.
- Manual flow `Nhật ký -> + -> Quét mã vạch` đã mở đúng màn scanner trên emulator (title, scan frame, torch button, hint text đều hiển thị đúng), chưa xác nhận được case quét thành công.
- Manual flow `Nhật ký -> + -> Chụp ảnh AI -> Thư viện` đã mở được Android Photo Picker và chọn ảnh thành công; đã fix treo loading bằng timeout ở client call, re-test cho thấy app hiển thị lỗi rõ ràng khi backend không phản hồi thay vì treo vô hạn.

## Missing features

- Chạy manual release/test checklist đầy đủ cho core flows.
- Integration tests cho auth → onboarding → dashboard và meal logging.
- Food data verification workflow.
- Daily logging UX nâng cao như favorite foods, copy meal và portion selector.
- Weekly review/insights.

## Known bugs / risks

- Storage upload có thể lỗi nếu code mới dùng path ngoài `users/{uid}/...` hoặc `admin/...`.
- Dữ liệu `goals/{uid}` cũ có thể chứa giá trị bất thường; UI đã có fallback guard nhưng vẫn nên cleanup dữ liệu lỗi trong Firestore để tránh lệch nguồn.
- Admin users/dashboard có rủi ro N+1 query khi dữ liệu tăng.
- Test coverage còn yếu, chưa có integration test.
- AI photo scan phụ thuộc Cloud Function `identifyFoodImage`: khi backend không phản hồi, app hiện lỗi mạng sau timeout client (không còn treo vô hạn); vẫn cần theo dõi latency/độ ổn định backend để đảm bảo happy-path trả kết quả đúng hạn.

## Test status

- Flutter: 43 tests pass, `flutter analyze` sạch, `flutter build apk --debug` pass (2026-05-14).
- Admin web: `npm --prefix admin-web run build` pass; còn cảnh báo Vite chunk lớn.
- Cloud Functions: `npm --prefix functions run build` và `npm --prefix functions run lint` pass.

## Recent decisions

- Ưu tiên roadmap theo hướng: production foundation → food database → daily logging UX → test/release readiness → retention insights.
- Provider hiện tại vẫn đủ dùng; chưa ưu tiên đổi state management.
- Đã hoàn thành chuẩn hóa AI/barcode error states với exception classes và UI error hiển thị rõ ràng.
- Firestore `foods/{foodId}` dùng canonical fields theo Flutter `FoodItem`; admin web và Cloud Functions đọc legacy nhưng ghi canonical.
- Sau mỗi phần việc có ý nghĩa, cập nhật các file Markdown quản lý dự án/docs phù hợp để lần sau tiếp tục đúng điểm dừng.

## Next recommended action

Tiếp tục manual verification cho auth/onboarding và xác minh happy-path AI scan/barcode khi backend sẵn sàng (đã có timeout guard cho case backend treo). Song song cleanup các document `goals/{uid}` lỗi nếu có; sau đó thêm integration tests cho auth → onboarding → dashboard / meal logging.
