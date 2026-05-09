---
applyTo: "**"
---
# False Completion Prevention (AFP-008)

This is the #1 failure mode in the swarm. A worker completes all phases and writes REVIEW.md but makes ZERO actual code changes. The merge service catches this and blocks the branch, wasting an entire task cycle.

## Root Causes

1. **Stale artifact reuse** — Worker copies SPEC.md/DESIGN.md from a previous branch instead of generating fresh content
2. **Skip-Spec:true misuse** — Shortcutting context gathering causes the worker to miss what actually needs to be done
3. **Wrong branch context** — Worker operates on a branch that already has IMPLEMENT.md from a previous attempt
4. **Scope too narrow** — The Scope: field doesn't include the files that need changing

## Prevention Checklist

Before writing REVIEW.md, verify ALL of these:

1. **Check git diff:** `git diff main..HEAD --name-only`
   - Must show at least ONE file that is NOT a marker (SPEC.md, DESIGN.md, etc.)
   - If only markers changed, you have a false completion

2. **Check file content:** The files you "created" or "modified" must actually exist on disk with real content
   - `ls -la path/to/your/file.py` — must exist and have >0 bytes
   - `wc -l path/to/your/file.py` — must have actual code lines

3. **Check test existence:** If the task requires tests, verify test files exist
   - `ls tests/test_*.py` matching the task scope

## What To Do Instead

If you cannot make real changes:
- Write BLOCKED.md with the reason: "Cannot implement because [specific reason]"
- Do NOT write REVIEW.md
- The orchestrator will provide steering hints for blocked tasks
