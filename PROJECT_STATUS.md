# SmartNutri Project Status

## App overview

SmartNutri là app theo dõi dinh dưỡng tiếng Việt gồm Flutter mobile app, Firebase backend, Cloud Functions và React admin web.

## Current development focus

Đã chọn hướng đồ án/demo: giữ Gemini trực tiếp trong Flutter để giảm độ phức tạp vận hành, đồng thời dùng Firestore client-side quota cho Free/Premium và cho client lưu chat history theo rules. Trọng tâm tiếp theo: chạy manual verify core demo flows và cập nhật báo cáo giải thích rõ giới hạn demo so với production.

## Completed features

- Mobile auth, onboarding và auth-gated routing.
- Home dashboard với calories, macros, nước, streak, bữa hôm nay và AI suggestions.
- Meal log, food search, profile, statistics, water tracking và weight tracking.
- AI photo scan, barcode lookup và meal suggestions đã có UI/service; barcode đang gọi Open Food Facts trực tiếp, AI đang gọi Gemini qua client service.
- Admin web scaffold với login, dashboard, foods và users.
- Admin web route guard đã yêu cầu tài khoản có admin claim.

## Partially completed features

- Food catalog đã có Firestore loading, local seed fallback và schema Firestore chuẩn hóa; còn cần kiểm tra/migrate dữ liệu thật nếu collection cũ còn legacy fields.
- Admin web có quản lý foods/users cơ bản, nhưng còn thiếu hardening và tối ưu dữ liệu lớn.

## Recently completed

- Demo alignment: giữ Gemini trực tiếp trong Flutter cho đồ án/demo; thêm client-side record quota AI scan sau khi Gemini trả kết quả thành công; mở Firestore rules cho owner ghi `chat_history` và `usage/{yyyyMM}` có validate field; cập nhật docs backend/AI để phân biệt demo direct-client với production Cloud Functions. (2026-05-15)
- Refactor Barcode service: chuyển từ Cloud Functions sang gọi trực tiếp Open Food Facts API (`BarcodeService` dùng `http.Client`, parse JSON product/nutriments). Test cập nhật dùng `_FakeHttpClient`. (2026-05-14)
- Refactor AI Food service: chuyển từ Cloud Functions sang Gemini trực tiếp qua `AiService` interface. Thêm fuzzy match (Levenshtein + diacritics stripping) để map kết quả AI vào food catalog. Thêm `suggestMealsLocal` fallback offline với scoring macro. (2026-05-14)
- Review + fix bảo mật chatbot: xóa hardcoded Gemini API key khỏi client, xóa Gemini Direct fallback path, fix duplicate Firestore save (chỉ CF ghi), thêm debugPrint empty catch, fix isError persistence, cập nhật docs/chatbot.md. (2026-05-14)
- Hoàn thiện Subscription/Premium MVP backend/admin/docs: tạo DOCX kế hoạch, thêm model/service subscription, paywall/profile entry, chặn AI scan khi hết quota, Cloud Function `setUserSubscription`, backend enforce quota 5 lượt/tháng trong `identifyFoodImage`, admin web hiển thị/set Free/Premium, rules `users/{uid}/usage/{yyyyMM}` và docs/checklist cập nhật. (2026-05-14)
- Implement chatbot thông minh: Cloud Function `chatNutrition` với system prompt cá nhân hóa (profile + goal + meals hôm nay), `ChatService` ChangeNotifier, `ChatPage` với bubble UI, typing indicator 3 chấm, suggestion chips, lưu lịch sử vào Firestore `users/{uid}/chat_history`; nút chat trong AppBar mọi tab. `flutter analyze` sạch, Functions build/lint pass (2026-05-14).
- Implement favorite foods: `FavoriteFoodsService` với `FoodCatalog` DI, Firestore subcollection `users/{uid}/favorites/{foodId}`, reactive snapshot + `ChangeNotifier`; `FoodTile` có heart toggle; favorites section trên FoodSearchPage; `QuickAddFavorites` chips trên HomePage; `firestore.rules` cập nhật. 4 unit tests, analyze sạch, Functions và admin build pass (2026-05-14).
- Tối ưu admin N+1 query: Cloud Function trigger `onMealEntryChanged` duy trì `mealCount` và `lastMealDate` trên `users/{uid}`; admin web `loadUsers()` giảm từ N+1 xuống 1 query, `getDashboardStats().todayMeals` dùng collection group query thay N+1. Thêm `firestore.indexes.json` collection group index cho `meal_entries.date`. Functions build/lint pass, admin build pass, trigger đã test trên emulator (2026-05-14).
- Verify Cloud Functions: `health`, `barcodeLookup`, `identifyFoodImage`, `suggestMeals` đều hoạt động trên emulator. Viết script cleanup goals và migrate foods legacy→canonical, đã test trên emulator (2026-05-14).
- Thêm `user_profile_test.dart` (6) và `meal_entry_test.dart` (9) — Flutter 58 tests pass, analyze sạch (2026-05-14).
- Polish Subscription UI mobile: cải thiện `SubscriptionSummaryCard`, `SubscriptionPage`, `PaywallPage`; thêm copy ngữ cảnh khi bị chặn quota AI scan và truyền `source/reason` qua router từ `PhotoScanPage` (2026-05-14).
- Thêm `test/subscription_ui_test.dart` (4 widget tests) cho summary/subscription/paywall. (2026-05-14)
- Cập nhật test AI/barcode: migrate từ `_FakeFunctions` sang `_FakeHttpClient`/`_FakeGeminiService`, cập nhật error message assertions khớp với code mới. (2026-05-14)

- AI/barcode error states: `AiFoodServiceException` và `BarcodeLookupException` với message tiếng Việt, UI catch và hiển thị lỗi rõ ràng cho từng loại (auth, 5xx, mạng, invalid response).
- `FunctionCaller` interface và `FoodCatalog` abstract class cho DI/testing.
- Admin web `AuthGuard` chặn route với admin claim + `AccessDenied` component.
- Tests: `ai_food_service_error_test.dart` (4 tests), `barcode_service_error_test.dart` (4 tests), `nutrition_goal_test.dart` (8 tests), `user_profile_test.dart` (6 tests), `meal_entry_test.dart` (9 tests) và các widget tests cho auth/onboarding/food tile/meal groups/custom meal. Tổng 58 Flutter tests pass, analyze sạch (2026-05-14).
- Chuẩn hóa food schema giữa Flutter, admin web và Cloud Functions: readers đọc được canonical/legacy fields, new writes dùng canonical fields, `seedFoods` normalize payload. Flutter 43 tests pass, admin build pass, Functions build/lint pass (2026-05-14).
- Cập nhật [docs/test-checklist.md](docs/test-checklist.md) thành manual checklist chi tiết cho core flows: setup, auth, onboarding, dashboard, meal log, food search, AI scan, barcode, stats, profile/goals, Firebase rules, Functions và admin web.
- Automated release baseline pass: `flutter analyze`, `flutter test` (43 tests), `flutter build apk --debug`, `npm --prefix functions run build`, `npm --prefix functions run lint`, `npm --prefix admin-web run build` đều pass; admin build còn cảnh báo Vite chunk lớn.
- Manual emulator smoke test trên Android 14 API 34 pass cho launch, dashboard, food search, meal log empty state và add-action sheet.
- Đã thêm guard logic cho goal bất thường: Home/Meal log/Profile tự fallback về goal hợp lý từ profile/default khi dữ liệu `goals/{uid}` bị lỗi; verify lại trên emulator, dashboard test user hiển thị `2312 kcal`.
- Manual flow `Nhật ký -> + -> Tìm món thủ công -> Thêm vào nhật ký` đã pass trên emulator; meal `Phở bò 400g` được ghi thành công với `272 kcal` và macros hiển thị đúng.
- Manual flow `Nhật ký -> + -> Quét mã vạch` đã mở đúng màn scanner trên emulator (title, scan frame, torch button, hint text đều hiển thị đúng), chưa xác nhận được case quét thành công.
- Manual flow `Nhật ký -> + -> Chụp ảnh AI -> Thư viện` đã mở được Android Photo Picker và chọn ảnh thành công; đã fix treo loading bằng timeout ở client call, re-test cho thấy app hiển thị lỗi rõ ràng khi backend không phản hồi thay vì treo vô hạn.

## Missing features

- Manual verification cho Subscription/Premium MVP: Free còn quota, Free hết quota, Premium không giới hạn và admin set plan.
- Payment thật cho Subscription/Premium: receipt validation, renewal/cancel lifecycle và store integration.
- Chạy manual release/test checklist đầy đủ cho core flows.
- Integration tests cho auth → onboarding → dashboard và meal logging.
- Food data verification workflow.
- Daily logging UX nâng cao như copy meal, portion selector và undo delete meal.
- Weekly review/insights.

## Known bugs / risks

- Demo limitation: Gemini API key đang nằm trong Flutter client để phục vụ đồ án/demo; khi production cần chuyển sang backend/Cloud Functions hoặc backend proxy.
- Demo limitation: Free/Premium quota hiện enforce ở mức app + Firestore rules, đủ để demo flow nhưng không chống bypass như backend enforcement thật.
- Chat history đã được chuyển sang client-write theo hướng demo; cần manual verify gửi chat, reload app và thấy lịch sử còn.
- Storage upload có thể lỗi nếu code mới dùng path ngoài `users/{uid}/...` hoặc `admin/...`.
- Dữ liệu `goals/{uid}` cũ có thể chứa giá trị bất thường; UI đã có fallback guard nhưng vẫn nên cleanup dữ liệu lỗi trong Firestore để tránh lệch nguồn.
- Admin users/dashboard có rủi ro N+1 query khi dữ liệu tăng.
- Đã implement favorite foods: `FavoriteFoodsService` với Firestore subcollection `users/{uid}/favorites/{foodId}`, reactive snapshot listener + `ChangeNotifier`, UI heart toggle trên `FoodTile`, section "Yêu thích" trong FoodSearchPage, `QuickAddFavorites` chips trên HomePage, Firestore rules cập nhật. 4 unit tests pass (2026-05-14).
- Test coverage còn yếu, chưa có integration test.
- AI photo scan phụ thuộc Cloud Function `identifyFoodImage`: khi backend không phản hồi, app hiện lỗi mạng sau timeout client (không còn treo vô hạn); vẫn cần theo dõi latency/độ ổn định backend để đảm bảo happy-path trả kết quả đúng hạn.

## Test status

- Flutter: `flutter analyze` pass và `flutter test` pass 86 tests sau thay đổi quota client-side (2026-05-15).
- Firestore rules: `firebase deploy --only firestore:rules --dry-run` compiled successfully, không deploy thật (2026-05-15).
- Admin web: không đổi source lần này; lần trước `npm --prefix admin-web run build` pass với cảnh báo Vite chunk lớn.
- Cloud Functions: không đổi source lần này; lần trước `npm --prefix functions run build` và `npm --prefix functions run lint` pass.

## Recent decisions

- Đã fix lỗi UI text style trên PaywallPage và SubscriptionPage (text bị fallback style đỏ/vàng khi không set `style` cho `Text` widget trong `_Benefit`/`_BenefitRow`).
- Đã manual verify mobile flow Subscription/Premium: Profile→Gói SmartNutri→Paywall pass trên emulator (2026-05-14).
- Cập nhật ưu tiên roadmap: Subscription/Premium MVP được đưa lên nhóm ưu tiên cao để chuẩn bị mô hình Free/Premium.
- Ưu tiên roadmap trước đó: production foundation → food database → daily logging UX → test/release readiness → retention insights.
- Provider hiện tại vẫn đủ dùng; chưa ưu tiên đổi state management.
- Đã hoàn thành chuẩn hóa AI/barcode error states với exception classes và UI error hiển thị rõ ràng.
- Firestore `foods/{foodId}` dùng canonical fields theo Flutter `FoodItem`; admin web và Cloud Functions đọc legacy nhưng ghi canonical.
- Sau mỗi phần việc có ý nghĩa, cập nhật các file Markdown quản lý dự án/docs phù hợp để lần sau tiếp tục đúng điểm dừng.

## Manual verification — Subscription/Premium — 2026-05-14

Mobile flow (đã xác minh trên emulator):
- [x] Profile hiển thị SubscriptionSummaryCard "Gói Free • Còn 5/5 lượt AI scan".
- [x] Tap thẻ mở SubscriptionPage với title "Gói SmartNutri", quota "Đã dùng 0/5 lượt", nút "Xem Premium".
- [x] Nút "Xem Premium" mở PaywallPage với title "Nâng cấp Premium", quyền lợi, disclaimer MVP.
- [x] Text tiếng Việt trên toàn bộ các màn Subscription/Paywall.

Cần Firebase emulator/backend để xác minh tiếp:
- [ ] AI scan quota tăng sau scan thành công, usage ghi vào `users/{uid}/usage/{yyyyMM}`.
- [ ] Free user hết quota bị chặn AI scan, hiển thị paywall/lỗi quota.
- [ ] Premium user không bị giới hạn AI scan.
- [ ] Admin web hiển thị cột plan/quota và nút Set Free/Premium hoạt động.
- [ ] `setUserSubscription` chặn non-admin, set được plan khi caller là admin.

## Next recommended action

Chạy `flutter analyze` và `flutter test`, sau đó manual verify demo flows: chat gửi/lưu lịch sử, AI scan Free còn quota tăng usage, Free hết quota mở paywall, Premium không bị chặn, và cập nhật báo cáo phần giới hạn demo/production.
