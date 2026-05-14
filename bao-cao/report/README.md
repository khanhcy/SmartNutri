# SmartNutri — Báo cáo dự án (LaTeX)

## Yêu cầu hệ thống

- XeLaTeX (thường có sẵn trong TeX Live hoặc MiKTeX)
- Biber (cho bibliography)

## Cách build

```bash
# Từ thư mục report/
xelatex main.tex
biber main
xelatex main.tex
xelatex main.tex
```

Hoặc dùng `latexmk`:

```bash
latexmk -xelatex main.tex
```

## Build online

Nếu không cài LaTeX local, có thể upload project này lên Overleaf và build online.

## Cấu trúc thư mục

```
report/
├── main.tex              # File chính
├── config/               # Cấu hình (packages, metadata, commands, style)
├── frontmatter/          # Trang bìa, lời cảm ơn, cam đoan, tóm tắt, từ viết tắt
├── chapters/             # Nội dung 4 chương + kết luận
├── assets/               # Hình ảnh, diagram, screenshot
│   ├── images/
│   ├── diagrams/
│   └── screenshots/
├── tables/               # Bảng dữ liệu riêng (nếu cần)
└── bibliography/         # File .bib cho tài liệu tham khảo
```

## Các việc cần làm

Xem các placeholder `[TODO: ...]` trong file `.tex` để biết cần bổ sung gì:

1. Điền metadata dự án trong `config/metadata.tex`
2. Thêm logo trường vào `assets/images/logo.png`
3. Viết nội dung Tóm tắt trong `frontmatter/abstract.tex`
4. Bổ sung diagram (usecase, activity, sequence, ERD, architecture) vào `assets/diagrams/`
5. Chụp screenshot các màn hình chính, để vào `assets/screenshots/`
6. Hoàn thiện mô tả các use case còn lại trong Chương 3
7. Điền kết quả kiểm thử thực tế trong Chương 4
8. Bổ sung tài liệu tham khảo thật trong `bibliography/references.bib`
