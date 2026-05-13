---
name: test-checklist
description: Create or update the SmartNutri manual testing checklist in docs/test-checklist.md using Markdown only.
---

# Test Checklist Skill

Use this skill when the user wants to create or update `docs/test-checklist.md` for SmartNutri.

## Scope

- Only create or edit Markdown files.
- The default target is `docs/test-checklist.md`.
- Do not edit source code.
- Do not add dependencies.
- Do not delete or move files.
- Do not deploy.
- Do not run app-changing commands.

## Required context

Before editing, read:

- `CLAUDE.md`
- `docs/features.md`
- `docs/architecture.md`
- `docs/database.md`
- `docs/backend.md`

If `docs/test-checklist.md` already exists, read it before editing.

## Required checklist groups

The checklist must include these groups:

- Pre-test setup
- Auth
- Onboarding
- Home dashboard
- Meal log
- Food search
- Scan AI / Barcode
- Stats
- Profile / Goals
- Firebase / Security rules
- Cloud Functions
- Admin web
- Before release checklist
- Known risky areas

## Checklist item style

- Each item must be short.
- Each item must be clear.
- Each item must be easy to tick.
- Prefer user-realistic flows over implementation details.
- Use Vietnamese if the rest of the project docs are Vietnamese.
- Use `TODO` for behavior that is not confirmed by docs or source.

## Output after editing

After finishing, report:

1. Files created or changed
2. Summary of checklist contents
3. Any TODO areas that need source verification

## Rules

- Do not update other docs unless the user explicitly asks.
- Do not claim commands were run unless they were actually run.
- Do not remove existing useful checklist items unless replacing them with clearer equivalents.
