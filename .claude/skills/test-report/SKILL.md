---
name: test-report
description: Summarize a SmartNutri testing iteration using a fixed report format.
---

# Test Report Skill

Use this skill after running or adding tests for SmartNutri.

## Scope

- Report only unless the user explicitly asks for edits.
- Do not edit source code.
- Do not add dependencies.
- Do not delete or move files.
- Do not deploy.

## Required format

Always use this exact section order:

1. Files changed
2. Tests added
3. Commands run
4. Test result
5. Bugs found
6. Source code modified?
7. Remaining risks
8. Recommended next step

## Section guidance

### 1. Files changed

List changed files. If none, write `None`.

### 2. Tests added

List new or updated tests. If none, write `None`.

### 3. Commands run

List exact commands that were run. If none, write `None`.

### 4. Test result

Summarize pass/fail clearly. Include failing test names or command failures when available.

### 5. Bugs found

List bugs found during testing. If none, write `None confirmed`.

### 6. Source code modified?

Answer `Yes` or `No`. If yes, list files and why.

### 7. Remaining risks

List risks that still need manual or automated verification.

### 8. Recommended next step

Recommend one concrete next action.

## Rules

- Do not claim tests passed unless command output confirms it.
- Distinguish between not tested and passed.
- Mention if Firebase, emulator, network, or device testing was not performed.
- Keep the report concise and factual.
