---
name: unit-test-next
description: Add the next highest-priority Flutter unit test for SmartNutri while modifying only test files.
---

# Unit Test Next Skill

Use this skill when the user wants to add the next useful unit test to SmartNutri.

## Goal

Write the next highest-priority unit test, focusing on business logic before UI polish.

Priority order:

1. Nutrition goals
2. Calorie and macro calculations
3. Water target calculations
4. Meal summary logic
5. Firestore model mapping with `toMap()` / `fromMap()`
6. Date grouping and daily/weekly aggregation

## Scope

- Only edit test files.
- Do not edit source code unless a clear bug is proven and the user approves the source change.
- Do not add dependencies.
- Do not delete or move files.
- Do not deploy.
- Prefer existing test folders and patterns.

## Required workflow

1. Read `CLAUDE.md`.
2. Read relevant docs for the target area.
3. Inspect existing tests in `test/`.
4. Inspect the source needed to understand public APIs and expected behavior.
5. Before editing, tell the user which test file will be created or modified.
6. Add the smallest useful test for the selected behavior.
7. Run `flutter test` for the specific test file changed.
8. If the test reveals a source bug, stop and report it before changing source code.

## Test selection rules

- Prefer pure Dart unit tests over widget tests for business logic.
- Prefer deterministic tests with no Firebase network calls.
- Do not call real Firebase services.
- Do not test private implementation details.
- Use clear test names that describe user-visible or domain behavior.
- Keep each test focused on one behavior.

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

- A source change is needed to make code testable.
- A dependency is required.
- Firebase emulator setup is required.
- The expected behavior is ambiguous.
