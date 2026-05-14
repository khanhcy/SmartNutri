# SmartNutri Roadmap

## Mục tiêu

Đưa SmartNutri từ trạng thái MVP nhiều tính năng thành app dinh dưỡng ổn định, an toàn, dễ dùng hằng ngày và sẵn sàng demo/release.

## Nguyên tắc ưu tiên

1. Sửa rủi ro bảo mật và production trước khi thêm tính năng lớn.
2. Làm dữ liệu thực phẩm thành nền tảng đáng tin cậy.
3. Tối ưu thao tác ghi món hằng ngày vì đây là hành vi cốt lõi của app.
4. Thêm retention/insight sau khi core flow ổn định.
5. Mỗi thay đổi nên nhỏ, dễ test và dễ rollback.

## Giai đoạn 1 — Ổn định production foundation

### Mục tiêu

Giảm rủi ro bảo mật, lỗi trải nghiệm và thiếu quản lý dự án trước khi mở rộng app.

### Việc cần làm

- Chặn admin web chỉ cho tài khoản có admin claim truy cập dashboard, foods và users.
- Thêm trang hoặc trạng thái “Không có quyền truy cập” cho user không phải admin.
- Duy trì Storage rules theo owner/admin path khi thêm upload mới.
- Chuẩn hóa lỗi AI scan, meal suggestions và barcode lookup để UI hiển thị thông báo rõ ràng.
- Tạo checklist test thủ công cho các flow chính.
- Tạo hoặc cập nhật file quản lý dự án: `PROJECT_STATUS.md`, `BACKLOG.md`.

### Tiêu chí hoàn thành

- User không phải admin không vào được admin web.
- Storage rules không cho phép authenticated user ghi mọi path.
- AI/barcode lỗi có thông báo rõ thay vì trả kết quả rỗng khó hiểu.
- Có checklist test cho auth, onboarding, meal log, scan, profile, admin.

### Độ ưu tiên

Cao.

## Giai đoạn 2 — Làm food database thành source of truth

### Mục tiêu

Biến dữ liệu thực phẩm thành nền tảng chính của app, thay vì phụ thuộc nhiều vào seed hard-coded.

### Việc cần làm

- Chuẩn hóa schema `FoodItem` giữa Flutter app, admin web và Cloud Functions.
- Dùng Firestore `foods` làm nguồn dữ liệu chính.
- Giữ seed local chỉ như fallback offline/demo.
- Nâng cấp admin foods CRUD/import CSV.
- Thêm field hữu ích: `verified`, `source`, `brand`, `servingSize`, `region`, `tags`, `updatedAt`.
- Xác định quy trình kiểm duyệt dữ liệu thực phẩm.

### Tiêu chí hoàn thành

- App mobile đọc food catalog chính từ Firestore.
- Admin web có thể thêm/sửa/import thực phẩm theo schema thống nhất.
- Dữ liệu AI/barcode/meal log dùng cùng format dinh dưỡng.
- Có phân biệt món verified và món AI estimated.

### Độ ưu tiên

Cao.

## Giai đoạn 3 — Cải thiện trải nghiệm ghi món hằng ngày

### Mục tiêu

Giúp người dùng ghi bữa ăn nhanh hơn, ít thao tác hơn và ít bỏ cuộc hơn.

### Việc cần làm

- Thêm món yêu thích.
- Cải thiện quick add từ món gần đây.
- Cho phép copy bữa từ hôm qua hoặc ngày khác.
- Thêm portion selector theo gram, khẩu phần, chén, tô hoặc đơn vị phổ biến.
- Thêm undo khi xóa meal entry.
- Sau AI scan/barcode, cho user xác nhận và chỉnh khẩu phần trước khi lưu.

### Tiêu chí hoàn thành

- User có thể thêm lại món thường ăn trong vài thao tác.
- User có thể chỉnh khẩu phần dễ hiểu hơn chỉ nhập gram thủ công.
- AI scan không tự động trở thành dữ liệu cuối nếu user chưa xác nhận.

### Độ ưu tiên

Trung bình cao.

## Giai đoạn 4 — Tăng test và release readiness

### Mục tiêu

Giảm lỗi regression và chuẩn bị quy trình release/demonstration ổn định.

### Việc cần làm

- Thêm unit test cho model/service quan trọng.
- Thêm widget test cho màn hình hoặc component cốt lõi.
- Thêm integration test hoặc manual test checklist cho flow auth → onboarding → dashboard.
- Test meal log: add, edit, delete, custom meal, search food.
- Test scan/barcode success, not found và error states.
- Test admin foods CRUD/import nếu chuẩn bị dùng admin web thật.

### Tiêu chí hoàn thành

- `flutter analyze` sạch cho mobile changes.
- `flutter test` pass.
- Admin web build pass khi có thay đổi admin.
- Cloud Functions build/lint pass khi có thay đổi functions.
- Có checklist release blockers rõ ràng.

### Độ ưu tiên

Trung bình.

## Giai đoạn 5 — Subscription/Premium MVP ✅ (đã hoàn thành code)

### Mục tiêu

Thêm nền tảng gói Free/Premium để chuẩn bị mô hình kinh doanh cho app.

### Đã làm xong

- [x] Quyền lợi Free/Premium: AI scan quota 5 lượt/tháng.
- [x] Trạng thái subscription trong Firestore (`users/{uid}/subscription`).
- [x] PaywallPage, SubscriptionPage, SubscriptionSummaryCard trong mobile app.
- [x] Guard UI cho tính năng premium (chặn AI scan khi hết quota).
- [x] Admin web hiển thị/set Free/Premium cho user.
- [x] Cloud Function `setUserSubscription` (admin-only).
- [x] Backend enforce quota trong `identifyFoodImage` nếu dùng Cloud Functions path.
- [x] Firestore rules cho `users/{uid}/usage/{yyyyMM}` và client-side quota demo khi dùng Gemini trực tiếp.
- [x] Docs/checklist cập nhật.

### Còn cần làm

- [ ] Manual verify quota enforcement với Firebase emulator.
- [ ] Quyết định payment thật (mock/demo trước hay tích hợp IAP).

## Giai đoạn 6 — Retention và insight thông minh

### Mục tiêu

Làm app có giá trị lâu dài hơn app ghi log đơn thuần.

### Việc cần làm

- Weekly Review: tổng kết calories, protein, carb, fat, water, weight trend.
- Personalized insights: ví dụ thiếu protein, uống ít nước, thường bỏ bữa sáng.
- Calendar heatmap cho ngày đạt mục tiêu.
- Goal adherence score.
- Achievement/streak nâng cao.
- Gợi ý mục tiêu tuần sau.

### Tiêu chí hoàn thành

- User nhận được tổng kết dễ hiểu sau mỗi tuần.
- App đưa ra insight hành động được, không chỉ hiển thị số liệu.
- Dashboard có lý do rõ ràng để user quay lại.

### Độ ưu tiên

Trung bình.

## Giai đoạn 7 — Growth, monetization và mở rộng

### Mục tiêu

Chuẩn bị cho hướng thương mại hoặc mở rộng sản phẩm nếu MVP chứng minh được giá trị.

### Việc có thể làm

- AI scan quota.
- Premium reports.
- Meal plans cá nhân hóa.
- Coach/nutritionist mode.
- Export PDF/CSV.
- Wearable integration.

### Tiêu chí bắt đầu

Chỉ nên bắt đầu khi core tracking, food database, bảo mật và UX hằng ngày đã ổn.

### Độ ưu tiên

Thấp ở hiện tại.

## Kế hoạch 2 tuần đề xuất

### Tuần 1

1. Sửa admin-only guard.
2. Thiết kế và siết Storage rules theo path owner.
3. Chuẩn hóa lỗi AI/barcode ở service và UI liên quan.
4. Tạo `PROJECT_STATUS.md` và `BACKLOG.md`.

### Tuần 2

1. Chuẩn hóa food schema.
2. Cải thiện admin food import/CRUD theo schema mới.
3. Thêm hoặc cập nhật manual test checklist.
4. Thêm test cho logic nutrition/meal/food quan trọng nhất.

## Việc nên làm ngay tiếp theo

1. Commit các thay đổi refactor hiện tại (Barcode + AI service + Subscription UI + test).
2. Chạy `npm run build` cho Functions và Admin để xác nhận không hồi quy.
3. Manual verify Subscription/Premium quota enforcement với Firebase emulator.
4. Quyết định hướng payment thật (IAP hay mock/demo).
