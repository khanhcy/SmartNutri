# SmartNutri Backlog

## In progress

- Giai đoạn 1 — Ổn định production foundation: đã hoàn thành 3 high-priority items backend. Chuẩn bị chuyển qua medium priority.

## Deferred

- Manual test auth/onboarding trên emulator (để làm sau khi test coverage khá hơn).

## High priority

- Chạy tiếp manual test checklist cho auth/onboarding (flow thêm meal thực tế đã pass; barcode UI và AI picker đã verify).
- Dùng Firestore `foods` làm source of truth chính, seed local chỉ là fallback.

## Medium priority

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
- Thêm `user_profile_test.dart` (6 tests): kiểm tra `UserProfile.fromMap` đọc đủ field, giá trị mặc định, cast numeric, updatedAt lỗi; `toMap` xuất đúng và roundtrip toMap/fromMap giữ nguyên giá trị. Flutter 58 tests pass, analyze sạch (2026-05-14).
- Thêm `meal_entry_test.dart` (9 tests): kiểm tra `MealTypeX` label tiếng Việt + icon; `MealEntry.fromMap` đọc đủ field, mặc định, fallback mealType, cast numeric, loggedAt lỗi; `toMap` xuất đúng và roundtrip. Flutter 58 tests pass, analyze sạch (2026-05-14).
- Verify Cloud Functions trên emulator: `health`, `barcodeLookup` (Coca-Cola OK), `identifyFoodImage` (pipeline OK), `suggestMeals` (gợi ý tiếng Việt OK). Tất cả function đều hoạt động (2026-05-14).
- Viết & test script cleanup `goals/{uid}`: phát hiện goal bất thường (153440 kcal, 500 kcal) và fix về default. Verify 3/3 goal hợp lệ sau cleanup (2026-05-14).
- Viết & test script migrate `foods` legacy→canonical: phát hiện legacy-only, mixed, empty food; migrate thành công 4/4 docs sạch canonical, 0 legacy fields (2026-05-14).
- Tối ưu admin N+1 query: Cloud Function trigger `onMealEntryChanged` duy trì `mealCount` + `lastMealDate` trên `users/{uid}`; admin web `loadUsers()` giảm N+1→1 query, `getDashboardStats().todayMeals` dùng collection group query. Thêm index `meal_entries.date`. Functions build/lint pass, admin build pass, trigger đã test (2026-05-14).
- Implement favorite foods: `FavoriteFoodsService` (Firestore subcollection + ChangeNotifier), `FoodCatalog` DI, heart toggle trên `FoodTile`, favorites section trên FoodSearchPage, `QuickAddFavorites` chips trên HomePage, `firestore.rules` cập nhật. Flutter 62 tests pass, analyze sạch, Functions/admin build pass (2026-05-14).

## Cancelled / not doing

- Chưa đổi Provider sang state management khác; chưa có nhu cầu đủ mạnh.
