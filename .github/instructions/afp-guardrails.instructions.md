---
applyTo: "**"
---
# AFP Guardrails — Active Failure Prevention

These are the known failure patterns (AFP) that have caused production issues.
Every worker must actively prevent these, not just react to them.

## AFP-008: False Completion (CRITICAL)

**What it is:** Writing REVIEW.md without making any actual code changes.
**How to prevent:**
- Before writing REVIEW.md, verify `git diff main..HEAD --name-only` shows changed files
- At least one non-marker file must be modified (not just SPEC.md, DESIGN.md, etc.)
- If you cannot make changes, write BLOCKED.md explaining why — never fake completion

## AFP-011: Invented Classes and Interfaces (CRITICAL)

**What it is:** Designing or implementing code that references classes, functions, or modules that don't exist in the codebase.
**How to prevent:**
- Before referencing ANY class or function, search the codebase: `grep -rn "class ClassName" .`
- Before importing ANY module, verify it exists: `ls path/to/module.py`
- If a needed interface doesn't exist, CREATE it or use what exists
- Never assume a class exists because it "should" — verify first

## AFP-014: Marker Files on Main Branch

**What it is:** CLAIMED.md, REVIEW.md, SPEC.md etc. accidentally merged into main.
**How to prevent:** The merge service strips these automatically. If you see them on main, do not reference them as valid state.

## AFP-016: Parallel Merge Conflicts (HIGH)

**What it is:** Multiple task branches modifying the same files, causing merge conflicts.
**How to prevent:**
- Check Scope: field in TASK.md — only modify files within your scope
- If you need to modify a shared file (like `__init__.py`), make minimal changes
- Prefer creating new files over modifying existing shared ones

## AFP-018: Missing Typing Imports

**What it is:** Using `List`, `Optional`, `Dict` etc. without importing from `typing`.
**How to prevent:**
- Every file that uses type annotations must have its own imports
- Do not assume imports exist because other files have them
- Always add: `from typing import List, Optional, Dict, Tuple, Set` when using these types
