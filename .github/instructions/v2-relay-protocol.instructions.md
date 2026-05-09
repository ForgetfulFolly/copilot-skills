---
applyTo: "**"
---
# V2 Relay Protocol — Phase-Based Worker Handoff

## How Tasks Flow Through the Swarm

Tasks are NOT executed by a single worker. Each phase is handled by a specialist:

```
queued (Worker-Role: research) → Doc or Sleepy claim
   ↓ SPEC.md written, HANDOFF.md written
research-done (Worker-Role: code) → Larry, Moe, Curly, Happy, or Dopey claim
   ↓ DESIGN.md + IMPLEMENT.md written, HANDOFF.md updated
code-done (Worker-Role: test) → Grumpy or Bashful claim
   ↓ Tests run, REVIEW.md written
test-pass → Merge service merges to main
test-fail (Worker-Role: code) → Code worker re-claims with test feedback
```

## Worker Role Matrix

| Role | Workers | Claims When | Produces |
|------|---------|-------------|----------|
| research | Doc, Sleepy | Worker-Role: research | SPEC.md, HANDOFF.md |
| code-lead | Larry | Worker-Role: code | DESIGN.md, code files, HANDOFF.md |
| code | Moe, Curly, Happy, Dopey | Worker-Role: code | DESIGN.md, code files, HANDOFF.md |
| test | Grumpy, Bashful | Worker-Role: test | Test results, REVIEW.md |
| infra | Sneezy | Worker-Role: infra | Shell scripts, systemd, git ops |
| investigator | Frank Drebin | Worker-Role: investigator | Debug logs, root cause analysis |

## HANDOFF.md Protocol

After completing your phase, you MUST write HANDOFF.md with:
- **What I Did** — summary of work completed
- **What I Found** — files changed, discoveries
- **What Needs Doing Next** — instructions for the next worker
- **Risks/Warnings** — edge cases, known issues

The next worker reads HANDOFF.md before starting their phase.

## Phase Completion Rules

1. Run ONE phase only, then release the task
2. Update `Worker-Role:` in TASK.md to the next role
3. Remove CLAIMED.md
4. Push and let the next specialist pick it up
5. Do NOT write REVIEW.md unless you are a test worker confirming tests pass
