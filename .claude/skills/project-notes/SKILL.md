---
name: project-notes
description: Create or update PROJECT_NOTES.md — a comprehensive project snapshot to quickly resume work after time away.
---

# Project Notes Skill

Use this skill when the user wants to create or update `PROJECT_NOTES.md` for SmartNutri.

## Purpose

`PROJECT_NOTES.md` is the single entry point for anyone (including future-you) who returns to the project after time away. It must be self-contained, factual, and immediately actionable — no prior context needed.

## Scope

- Only create or edit `PROJECT_NOTES.md`.
- Do not edit source code.
- Do not add dependencies.
- Do not delete or move files.
- Do not deploy.
- Do not run app-changing commands.

## Required context

Before creating or editing, read at minimum:

- `CLAUDE.md`
- `docs/README.md`
- `docs/features.md`
- `docs/architecture.md`
- `docs/database.md`
- `docs/status.md`
- `.firebaserc`

If any of these don't exist, note that in the report instead of guessing.

## Required sections

The report must include these 9 sections in this exact order:

1. **Snapshot hiện tại** — current project state summary (project type, Firebase project name, what's deployed, what's working with real backend vs mock).
2. **Kiến trúc code nhanh** — quick code map: key directories and their roles, key entry-point files with paths, service layer overview.
3. **Luồng chính trong app** — numbered list of the main user flows through the app, each step referencing relevant files.
4. **Các command thường dùng** — grouped by category (Flutter, Firebase, Emulator, etc.) with working paths and any platform-specific notes.
5. **Các điểm dễ nhầm / lỗi thường gặp** — concrete gotchas with error messages or symptoms and their fixes. Only include issues confirmed from code, docs, or git history — don't invent.
6. **Dữ liệu Firestore đang dùng** — collections currently mapped in the app (path pattern + purpose), plus planned collections not yet implemented.
7. **Tình trạng roadmap** — high-level progress across major workstreams (Foundation, Core MVP, AI/Notifications/Reports/Admin, etc.). Keep at ~3-5 lines.
8. **Checklist mỗi lần quay lại dự án** — numbered 5-step quick-start checklist: open this file, check Firebase project, start emulator + run app, smoke test (signup → onboarding → verify Firestore), deploy rules if needed.
9. **Việc ưu tiên tiếp theo (để đẩy nhanh MVP)** — numbered list of 5-7 concrete next tasks, ordered by impact. Each item must be specific enough to start immediately.

## Content rules

- All user-facing labels and descriptions must be in Vietnamese.
- File paths must use backtick formatting and be relative to repo root.
- Commands must be copy-paste ready with correct paths (use PowerShell syntax on Windows).
- Paths must be verified by reading the actual file tree — never guess paths.
- Distinguish clearly between deployed/working and planned/not-yet-implemented.
- Use `None` or "Chưa có" for empty sections, not silence.
- Keep each section concise — this is a quick-reference document, not a design doc.

## Output after editing

After finishing, report:

1. Whether `PROJECT_NOTES.md` was created or updated.
2. Sections that changed significantly (if updating).
3. Any areas marked as uncertain that need manual verification.

## Rules

- Do not update other docs unless the user explicitly asks.
- Do not claim commands work unless verified against actual project config.
- Do not invent Firebase projects, collections, or flows — derive from actual code and config.
- Read source files to confirm architecture claims — don't rely on memory or docs alone.
