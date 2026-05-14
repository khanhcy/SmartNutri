---
name: bao-cao
description: Vietnamese academic project report LaTeX manager — viết, chỉnh sửa, review báo cáo đồ án/cá nhân bằng LaTeX theo chuẩn đại học Việt Nam.
---

# Vietnamese Academic Project Report LaTeX Manager

Skill này giúp viết báo cáo dự án học thuật tiếng Việt bằng LaTeX, theo chuẩn "Báo cáo Dự án Công nghệ", "Đồ án chuyên ngành", hoặc "Đồ án tốt nghiệp".

## Scope

- Chỉ thao tác trong thư mục `bao-cao/report/`.
- Không sửa source code.
- Không thêm dependency vào project chính.
- Không deploy.
- Không tự ý xóa file trong `bao-cao/`.

## Default startup

Khi skill được kích hoạt:

1. Kiểm tra cấu trúc thư mục `bao-cao/report/` hiện tại.
2. Xác định file LaTeX đã có hay chưa.
3. Xác định phần nào còn thiếu so với format chuẩn.
4. Đề xuất hành động tiếp theo.
5. Chờ xác nhận trước khi viết lại nội dung lớn.

## Cấu trúc thư mục LaTeX

```
bao-cao/report/
├── main.tex
├── config/
│   ├── packages.tex
│   ├── metadata.tex
│   ├── commands.tex
│   └── style.tex
├── frontmatter/
│   ├── cover.tex
│   ├── acknowledgements.tex
│   ├── declaration.tex
│   ├── abstract.tex
│   └── abbreviations.tex
├── chapters/
│   ├── chapter01_intro.tex
│   ├── chapter02_background.tex
│   ├── chapter03_analysis_design.tex
│   ├── chapter04_implementation_testing.tex
│   └── conclusion.tex
├── assets/
│   ├── images/
│   ├── diagrams/
│   └── screenshots/
├── tables/
├── bibliography/
│   └── references.bib
└── README.md
```

Không bao giờ viết toàn bộ báo cáo vào một file `.tex` duy nhất.

## Cấu trúc báo cáo

Báo cáo phải theo thứ tự sau:

1. Trang bìa
2. Lời cảm ơn
3. Lời cam đoan
4. Tóm tắt
5. Mục lục
6. Danh sách hình vẽ
7. Danh sách bảng
8. Danh mục các từ viết tắt
9. Chương 1: Đặt vấn đề
10. Chương 2: Kiến thức nền tảng
11. Chương 3: Phân tích thiết kế hệ thống
12. Chương 4: Xây dựng, triển khai và kiểm thử hệ thống
13. Kết luận
14. Tài liệu tham khảo
15. Phụ lục (nếu cần)

## Quy tắc LaTeX

- Dùng **XeLaTeX** làm engine mặc định (hỗ trợ tiếng Việt UTF-8).
- Font: Times New Roman hoặc font học thuật tương đương.
- Khổ giấy A4, lề chuẩn.
- Hỗ trợ: đánh số trang, mục lục tự động, danh sách hình, danh sách bảng, đánh số chương/mục, caption hình và bảng, bibliography, hyperlinks.

### Packages ưu tiên

`fontspec`, `polyglossia` (hoặc `babel` với Vietnamese), `geometry`, `graphicx`, `longtable`, `array`, `booktabs`, `caption`, `hyperref`, `fancyhdr`, `titlesec`, `biblatex` hoặc `natbib`.

### Tránh

- Giãn cách thủ công lộn xộn
- Nhồi quá nhiều package không cần thiết
- Hardcoded page break khắp nơi
- Định dạng không nhất quán
- Đánh số bị hỏng
- Bảng quá to tràn trang

## Văn phong

- Ngôn ngữ mặc định: **tiếng Việt**.
- Giọng văn: trang trọng, học thuật, rõ ràng, chuyên nghiệp.
- Dùng "em" trong Lời cảm ơn nếu phù hợp.
- Dùng "tôi" trong Lời cam đoan.
- Dùng văn phong trung lập trong các chương kỹ thuật.
- Tránh: ngôn ngữ suồng sã, cảm xúc quá mức, phóng đại kiểu marketing, số liệu bịa đặt, trích dẫn giả.

## Quy tắc tạo nội dung

Khi người dùng cung cấp Markdown thô, ghi chú, hoặc thông tin dự án:

1. Xác định nó thuộc chương/mục nào.
2. Viết lại thành văn phong học thuật tiếng Việt.
3. Chuyển thành LaTeX sạch.
4. Giữ ý nghĩa chính xác.
5. Thêm `[TODO: ...]` placeholder nơi còn thiếu thông tin.
6. Không tự bịa chi tiết dự án.

### Placeholder mẫu

```
[TODO: Bổ sung tên trường]
[TODO: Bổ sung tên giảng viên hướng dẫn]
[TODO: Bổ sung hình kiến trúc hệ thống]
[TODO: Bổ sung tài liệu tham khảo thật]
```

## Nội dung từng phần

### Trang bìa

Phải có: tên trường, khoa, placeholder logo, loại báo cáo, chuyên ngành, tên đề tài, tên sinh viên, MSSV, lớp, giảng viên hướng dẫn, địa điểm và năm.

### Lời cảm ơn

Viết trang trọng, lịch sự. Nhắc đến giảng viên hướng dẫn và người hỗ trợ. Không quá dài.

### Lời cam đoan

Xác nhận báo cáo là công trình của người viết. Tài liệu tham khảo được trích dẫn đầy đủ. Có nơi, ngày, tên sinh viên.

### Tóm tắt

Tóm tắt: bối cảnh vấn đề, lý do xây dựng hệ thống, giải pháp chính, công nghệ/cách tiếp cận, kết quả đạt được, ý nghĩa dự án.

### Danh mục từ viết tắt

Bảng với cột: STT | Từ viết tắt | Từ đầy đủ tiếng Anh | Nghĩa tiếng Việt

### Chương 1 — Đặt vấn đề

- **1.1 Mô tả bài toán**: bối cảnh thực tế, vấn đề hiện tại, hạn chế của quy trình thủ công, lý do cần hệ thống phần mềm.
- **1.2 Mục tiêu dự án**: mục tiêu tổng thể, mục tiêu cụ thể, người dùng mục tiêu, lợi ích mong đợi.
- **1.3 Cấu trúc dự án**: mô tả ngắn nội dung từng chương.

### Chương 2 — Kiến thức nền tảng

- **2.1 Tổng quan về kiến trúc hệ thống**: giải thích client-server, three-tier, MVC, REST API, hoặc kiến trúc liên quan.
- **2.2 Các công nghệ được sử dụng**: chia thành Backend, Frontend, Database, Authentication, Deployment, Công cụ hỗ trợ. Với mỗi công nghệ: giới thiệu, lý do dùng, lợi ích liên quan đến dự án. Luôn kết nối giải thích công nghệ với dự án cụ thể này.

### Chương 3 — Phân tích thiết kế hệ thống

- **3.1 Tổng quan hệ thống**: tổng quan, actors chính, modules chính.
- **3.2 Đặc tả yêu cầu**: bảng yêu cầu chức năng (Use Case | Mô tả), yêu cầu phi chức năng (Hiệu năng, Độ tin cậy, An ninh, Khả bảo trì, Ràng buộc).
- **3.3 Tổng quan ca sử dụng**: giới thiệu use case diagram, placeholder hình.
- **3.4 Mô tả ca sử dụng**: mỗi use case dùng bảng với các trường: Tên, Mô tả, Actor, Luồng cơ bản (đánh số), Luồng thay thế, Tiền điều kiện, Hậu điều kiện, Business Rules. Sau mỗi bảng có placeholder cho activity diagram và sequence diagram.
- **3.5 Thiết kế cơ sở dữ liệu**: giải thích thiết kế DB, ERD figure, mô tả entity/table/collection chính.

### Chương 4 — Xây dựng, triển khai và kiểm thử

- **4.1 Cài đặt hệ thống**: tổng quan, kiến trúc, modules backend/frontend, database setup, deployment.
- **4.2 Kiểm thử**: bảng kiểm thử với cột: Mã kiểm thử | Chức năng | Dữ liệu đầu vào | Kết quả mong đợi | Kết quả thực tế | Trạng thái. Bao phủ: auth, business flow, admin, security, performance, integration, UI.
- **4.3 Giao diện hệ thống**: screenshot, mô tả từng màn hình chính, caption.

## Bảng use case — Style LaTeX

Dùng `longtable` hoặc `tabularx`. Cột trái: tên trường, cột phải: mô tả chi tiết. Dùng `p{}` hoặc `tabularx` để không tràn trang.

## Quy tắc hình và bảng

- Mỗi hình: tên file rõ ràng, caption, label.
- Mỗi bảng: caption, label, format nhất quán.
- Caption tiếng Việt: "Hình 3.1: ...", "Bảng 3.3: ...".
- Không chèn hình không có caption.

## Review mode

Khi được yêu cầu review, kiểm tra:

**STRUCTURE**: thiếu front matter, thiếu chương, sai thứ tự, sai số mục.

**CONTENT**: problem statement mơ hồ, mục tiêu yếu, thiếu actor, thiếu non-functional requirements, use case không đầy đủ, thiếu bằng chứng kiểm thử.

**FORMAT**: bảng vỡ, vấn đề caption, tràn trang, giãn cách kém, thuật ngữ không nhất quán.

**LANGUAGE**: tiếng Việt suồng sã, lặp từ, vấn đề ngữ pháp.

Định dạng kết quả review:

```
DONE:
...

PROBLEMS:
...

MUST FIX:
...

SHOULD IMPROVE:
...

NEXT ACTION:
...
```

## Task management

Cuối mỗi phiên làm việc lớn, tóm tắt:

```
DONE:
- ...

TODO:
- ...

RISKS:
- ...

NEXT ACTION:
- ...
```

## Quy tắc an toàn

- **Không bịa**: trích dẫn, kết quả performance, kết quả test, tên giảng viên, thông tin trường, diagram không tồn tại, screenshot không tồn tại.
- Nếu thiếu thông tin, dùng `[TODO: ...]` placeholder.
- Không tuyên bố hệ thống đã được test trừ khi người dùng cung cấp bằng chứng.
