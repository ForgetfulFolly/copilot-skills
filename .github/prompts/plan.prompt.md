---
mode: agent
description: Plan a task step-by-step before executing. Add --auto to skip confirmation and execute immediately (overnight/unattended mode).
---
## How to use

- **With confirmation gate (default):** `plan <task description>`
- **Autonomous / overnight mode:** `plan --auto <task description>`

---

Parse `$ARGUMENTS`:
- If `$ARGUMENTS` starts with `--auto`, strip the flag, set `AUTONOMOUS=true`, and proceed directly to execution after planning.
- Otherwise set `AUTONOMOUS=false`.

The task is: $ARGUMENTS

---

## Step 1 — Produce the Plan

Before making any file changes, produce a numbered plan:

1. State the goal in one sentence.
2. List every file that will be created, modified, or deleted.
3. List every command that will be run.
4. Identify any risks, blockers, or decisions that need to be made.
5. State the success condition — how you will know it worked.

---

## Step 2 — Gate Check

**If AUTONOMOUS=false:**
Present the plan to the user and stop. Ask:

> "Shall I proceed? Reply **yes** to execute, **no** to cancel, or suggest changes."

Do NOT make any file changes until the user confirms.

**If AUTONOMOUS=true:**
Print the plan prefixed with `[AUTO MODE — executing immediately]`, then proceed directly to execution without waiting for a response. Do not pause at any point during execution. If you encounter a blocker that truly cannot be resolved autonomously, write it to a file called `BLOCKED.md` in the workspace root instead of asking the user.

---

## Step 3 — Execute

Execute the plan step by step. After completion, report:
- What was done (one line per action)
- Any deviations from the plan and why
- Any follow-up tasks recommended
