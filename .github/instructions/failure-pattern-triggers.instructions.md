---
applyTo: "**"
---
# Failure-Pattern Triggers — When to Pause Instead of Retry

Pattern detection is a token-saver. Two failures of the same shape is not a coincidence — it's a signal to stop the assembly line and fix the root cause once instead of patching N tasks.

## Triggers — Pause When ANY of These Fires

### Trigger A: Same Error Class Twice in One Queue Session

Examples:
- Two tests both fail with `429 Rate limit exceeded` → spec template needs the rate-limit-skip pattern; update template, don't patch each test.
- Two specs both fail because of wrong API path → I'm guessing paths; revisit `feedback_stage_verify_first.md`, force a grep before next stage.
- Two patches both fail with bash quoting errors → switch to scp+execute pattern for all subsequent VM ops.

**Action:** Read existing memories on the topic. If the rule exists but isn't sticking, escalate the rule (concrete examples, harder constraints). If the rule doesn't exist, create one.

### Trigger B: Same Correction Applied >2 Times Across Tasks

Examples:
- Adding `pytest.skip(429)` manually to three test files → it should have been in the template from the start.
- Changing `request_type` → `request_kind` manually in three places → field-name list belongs in CONTEXT template.
- Fixing `flutter` → `/snap/bin/flutter` manually → already captured in LOOP.md, but if it recurs, add to verify-command template.

**Action:** Bake the correction into `sonnet-spec-template.md`. Future specs include it by default.

### Trigger C: Schema or Interface Change Discovered During Execution

Examples:
- `tax_lots.UNIQUE(buy_trade_id)` blocked transfers → discovered when Sonnet's task hit `UniqueViolation`, fixed by altering the constraint.
- `audit_logs.created_at` doesn't exist; the column is named `timestamp` → discovered at runtime.

**Action:** Capture the discovery in a memory immediately. Update the canonical schema file if one exists. Don't let the next session re-discover it.

### Trigger D: User Feedback Contradicts Existing Memory

Example:
- Memory says "execute tasks myself when Sonnet is idle"; user says "no, Sonnet does the work, you orchestrate."

**Action:** Update or supersede the memory in the same turn the contradiction surfaces. Don't leave both versions floating.

### Trigger E: Three Consecutive Batches Without a Real Bug Caught

**Action:** Surface to user. Suggest pivoting to a different surface (different repo, different layer) or winding down.

## What "Pause" Looks Like

- Stop staging new tasks
- Tell the user the trigger that fired and what I'm about to capture
- Update or create the relevant memory/steering doc (one tool call: `Write` or `Edit`)
- Resume the queue

The cost: 30-60 seconds and a few tool calls. The savings: avoiding the same mistake across the next N tasks.
