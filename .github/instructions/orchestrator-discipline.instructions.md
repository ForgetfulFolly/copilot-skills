---
applyTo: "**"
---
# Orchestrator Discipline — Opus Stays Out of Execution

When running the Sonnet task queue at `/landing-zone/workspaces/sonnet-queue/`, Opus orchestrates only. Sonnet executes. The token-cost asymmetry (Opus ≫ Sonnet) means executing tasks myself silently re-prices the user's work envelope.

## Hard Rules

1. **Never execute a pending task myself on the first attempt.** Even if Sonnet is idle. Idle ≠ permission to switch modes — it's a signal to ask the user whether to relaunch Sonnet.

2. **Only escalate to Opus execution after the same task has hit `failed/` twice.** Two failures of the same task = something systemic that needs an orchestrator-level fix. Diagnose and fix the underlying cause, then re-queue. The "execute it myself" path is a last resort.

3. **Don't re-run verify commands myself for routine reviews.** Trust Sonnet's verify-passed signal. Only re-run a verify if:
   - Something in the file content looks suspicious during spot-check
   - A later task changed shared state (DB schema, env vars) that might have invalidated earlier work
   - User explicitly asks for a re-verify

4. **Don't read files for review purposes.** Only read files when staging a new task (need real interfaces). Reviewing a completed file means: glance at the verify result, glance at file size + commit message, commit. Move on.

5. **Stop staging when value drops.** Two batches in a row with no real bugs caught = filler territory. Surface this to the user, don't push another batch.

## When the User Says "Review the Queue"

Default loop, in order:
1. `ls done/ in-progress/ pending/ failed/` — one SSH call.
2. If new files in `done/`: commit them in one batch (no per-file verify re-run).
3. If files in `failed/`: read the failure note, decide if it's a spec bug, backend bug, or genuine task-too-hard. Fix → re-queue OR escalate to user.
4. If `pending/ < 3` AND value-rate is still positive: stage next batch.
5. If pipeline appears idle (in-progress empty for >5 min, no new done since last cycle): tell the user, don't auto-execute.

## Pattern-Detection Triggers

Pause to create a memory or steering doc when:

- **Same kind of failure twice in one session** — e.g., two tasks both fail because of a wrong API path → spec template needs updating, not per-task fixes.
- **Same correction applied >2 times** — e.g., adding `pytest.skip` for rate-limits in three test files in a row → bake it into the spec template.
- **A schema or interface change discovered during execution** — capture immediately so the next attempt doesn't re-discover it.
- **A user feedback that contradicts a memory** — update or supersede the memory rather than letting both float.

When this trigger fires: pause the queue, create the memory/steering doc, then resume.

## Token Economy

- Use `Bash` calls combining multiple ops with `&&` instead of one tool call per command.
- Don't run `git status` after every commit — `git commit` already prints status.
- Don't print verbose review summaries — one line per task is enough.
- Don't restate the queue state at the start AND end of every cycle. End-of-cycle summary only.
- Long ScheduleWakeup intervals (e.g. 600s, 900s) when the pipeline is stable. Short (270s) only during active triage.
