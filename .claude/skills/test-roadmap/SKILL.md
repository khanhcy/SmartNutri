---
name: test-roadmap
description: Survey the current testing setup and report a testing roadmap without modifying files.
---

# Test Roadmap Skill

Use this skill when the user wants to understand the current testing state of SmartNutri and plan what to test next.

## Scope

- Read-only survey only.
- Do not edit files.
- Do not create files.
- Do not add dependencies.
- Do not delete or move files.
- Do not deploy.
- Do not run destructive commands.

## Required context to read

1. Read `CLAUDE.md`.
2. Read relevant docs before reporting:
   - `docs/features.md`
   - `docs/architecture.md`
   - `docs/database.md`
   - `docs/backend.md`
3. If the user asks about AI scan, barcode, design, status, or decisions, also read the relevant docs:
   - `docs/ai.md`
   - `docs/design.md`
   - `docs/status.md`
   - `docs/decisions.md`

## Required checks

Check whether these test areas exist:

- Flutter tests: `test/`
- Flutter integration tests: `integration_test/`
- Cloud Functions tests:
  - `functions/test/`
  - `functions/tests/`
  - `functions/src/**/*.test.ts`
  - `functions/src/**/*.spec.ts`
- Admin web tests:
  - `admin-web/src/**/*.test.*`
  - `admin-web/src/**/*.spec.*`
  - `admin-web/src/**/__tests__/**`
  - `admin-web/test/`
  - `admin-web/tests/`

Check available commands in:

- `pubspec.yaml`
- `functions/package.json`
- `admin-web/package.json`

## Report format

Report in Vietnamese unless the user asks otherwise.

Include these sections:

1. Current tests found
2. Missing tests
3. Available commands
4. Recommended testing roadmap
5. Highest-priority areas to test first
6. Current risks without stronger tests
7. Suggested next step

## Rules

- Prefer concrete file references.
- If something is uncertain, write `TODO` and explain what must be verified.
- Do not guess behavior from docs alone when source verification is needed.
- Do not implement the roadmap in this skill.
