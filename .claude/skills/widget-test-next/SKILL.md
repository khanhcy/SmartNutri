---
name: widget-test-next
description: Add the next useful Flutter widget test for important SmartNutri screens or components without calling real Firebase.
---

# Widget Test Next Skill

Use this skill when the user wants to add the next useful widget test for SmartNutri.

## Goal

Write widget tests for important screens and reusable components, prioritizing user-critical flows.

Suggested priority:

1. Auth forms
2. Onboarding forms
3. Meal log form
4. Food search UI states
5. Scan AI / barcode UI states
6. Profile / goals forms
7. Shared UI components used across flows

## Scope

- Only edit test files unless the user explicitly approves a source change.
- Do not add dependencies.
- Do not delete or move files.
- Do not deploy.
- Do not call real Firebase.
- Do not require network access.

## Required workflow

1. Read `CLAUDE.md`.
2. Read relevant docs for the target screen or component.
3. Inspect existing widget tests in `test/`.
4. Inspect the widget and its dependencies.
5. Before editing, tell the user which test file will be created or modified.
6. If a fake or mock service is needed, explain why.
7. If source must be changed for testability, stop and ask the user first.
8. Add the smallest useful widget test.
9. Run `flutter test` for the specific test file changed.

## Test design rules

- Test what the user sees or does.
- Avoid testing layout internals unless they are user-visible behavior.
- Prefer fake services over real Firebase calls.
- Keep fakes local to tests when possible.
- Verify loading, empty, error, and success states when practical.
- Keep each test focused and readable.

## Output format

After finishing, report:

1. Files changed
2. Tests added
3. Commands run
4. Test result
5. Bugs found
6. Source code modified?
7. Remaining risks
8. Recommended next step

## If blocked

Stop and ask the user before proceeding if:

- The widget directly initializes Firebase.
- A dependency injection seam is missing.
- A new package is needed.
- The expected UI behavior is unclear.
