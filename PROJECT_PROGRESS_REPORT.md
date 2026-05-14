# Báo cáo tiến độ dự án SmartNutri

## 1. Thông tin chung

SmartNutri là ứng dụng theo dõi dinh dưỡng được xây dựng bằng Flutter và Firebase. Ứng dụng giúp người dùng ghi lại bữa ăn hằng ngày, theo dõi lượng calo, protein, carb, fat, nước uống và cân nặng.

Dự án gồm các phần chính:

- Ứng dụng mobile cho người dùng.
- Firebase để đăng nhập, lưu trữ dữ liệu và xử lý backend.
- Trang admin web để quản lý dữ liệu thực phẩm và người dùng.

## 2. Trạng thái dự án

Hiện tại, dự án đã hoàn thành phần nền tảng chính của ứng dụng. Các chức năng cơ bản như đăng ký, đăng nhập, nhập thông tin cá nhân, trang chủ, nhật ký bữa ăn, tìm kiếm thực phẩm, món ăn yêu thích, quét ảnh món ăn bằng AI và quét mã vạch đã được xây dựng.

Dự án cũng đã kết nối Firebase để lưu dữ liệu người dùng và dữ liệu bữa ăn. Một số chức năng backend như AI scan, barcode lookup và gợi ý bữa ăn đã được xử lý bằng Cloud Functions.

Tuy nhiên, dự án vẫn cần tiếp tục kiểm thử kỹ hơn, chuẩn hóa dữ liệu thực phẩm và cải thiện trải nghiệm người dùng trước khi hoàn thiện.

## 3. Tiến độ chi tiết

Các công việc đã thực hiện gồm:

- Xây dựng giao diện đăng ký và đăng nhập.
- Tích hợp Firebase Authentication.
- Xây dựng màn hình nhập thông tin cá nhân ban đầu.
- Xây dựng trang chủ hiển thị calo, dinh dưỡng và nước uống.
- Xây dựng chức năng ghi nhật ký bữa ăn.
- Xây dựng chức năng tìm kiếm thực phẩm.
- Thêm chức năng lưu món ăn yêu thích.
- Xây dựng chức năng quét ảnh món ăn bằng AI.
- Xây dựng chức năng quét mã vạch sản phẩm.
- Xây dựng trang hồ sơ cá nhân.
- Xây dựng trang admin web cơ bản.
- Kết nối Firestore để lưu dữ liệu.
- Kiểm thử bước đầu bằng test tự động và giả lập Android.

Một số phần còn đang tiếp tục hoàn thiện:

- Kiểm thử toàn bộ luồng sử dụng của người dùng.
- Kiểm tra và chuẩn hóa dữ liệu thực phẩm.
- Cải thiện chức năng AI scan và barcode.
- Cải thiện trải nghiệm thêm món ăn hằng ngày.
- Hoàn thiện thêm trang admin web.
- Xây dựng chatbot thông minh để hỗ trợ người dùng tư vấn và giải đáp về dinh dưỡng.

## 4. Kế hoạch tiếp theo

Trong thời gian tiếp theo, nhóm sẽ tiếp tục thực hiện các công việc sau:

- Kiểm thử đầy đủ các chức năng chính của ứng dụng.
- Sửa các lỗi phát hiện trong quá trình kiểm thử.
- Hoàn thiện dữ liệu thực phẩm trên hệ thống.
- Tối ưu UI để giao diện đẹp hơn, dễ sử dụng hơn và phù hợp với người dùng.
- Cải thiện giao diện và trải nghiệm người dùng.
- Tối ưu chức năng thêm món ăn vào nhật ký.
- Kiểm tra lại chức năng AI scan và quét mã vạch.
- Phát triển chatbot thông minh hỗ trợ người dùng.
- Bổ sung thêm test cho các chức năng quan trọng.
- Chuẩn bị báo cáo và demo sản phẩm.

## 5. Phân công việc

| Thành viên | Công việc phụ trách |
|---|---|
| Thành viên 1 | Phát triển ứng dụng mobile, xây dựng giao diện người dùng, chức năng đăng nhập, onboarding, trang chủ, nhật ký bữa ăn và hồ sơ cá nhân. |
| Thành viên 2 | Phụ trách Firebase, Firestore, Cloud Functions, chức năng AI scan, barcode, dữ liệu thực phẩm, admin web và kiểm thử hệ thống. |
