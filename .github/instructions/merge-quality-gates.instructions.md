---
applyTo: "**"
---
# Merge Quality Gates — What the Merge Service Validates

Your code must pass ALL these gates before it can be merged to main.

## Gate 1: AFP-008 Check (Zero Code Changes)
- `git diff main..branch --name-only` must show at least one non-marker file changed
- If only SPEC.md, DESIGN.md, REVIEW.md etc. changed, the branch is blocked as false completion

## Gate 2: Python Syntax Check
- `py_compile.compile()` runs on every changed .py file
- Any syntax error blocks the merge

## Gate 3: Test Suite
- `python -m pytest` runs in the workspace
- NEW test failures block the merge (pre-existing failures are baselined)
- If 0 tests are collected (exit code 5), this gate passes

## Gate 4: Marker File Stripping
- Phase markers (CLAIMED.md, SPEC.md, DESIGN.md, IMPLEMENT.md, REVIEW.md, etc.) are automatically removed from the merge commit
- Only actual code lands on main

## Gate 5: Merge Conflict Detection
- `git merge --no-ff` is attempted into main
- If conflicts exist, MERGE_CONFLICT.md is written to the branch
- The branch is NOT merged

## How to Pass

1. Make real code changes (not just marker files)
2. Ensure all Python files have valid syntax
3. Run tests locally before marking REVIEW.md: `python -m pytest tests/ -v`
4. Keep changes scoped — don't modify files outside your Scope: field
5. If tests fail, write detailed error context in HANDOFF.md for the next worker
