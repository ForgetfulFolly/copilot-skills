# copilot-skills

Copilot-compatible mirror of the [ForgetfulFolly/claude-skills](https://github.com/ForgetfulFolly/claude-skills) swarm steering docs and prompt library.

## What lives here

| Path | Purpose | Copilot equivalent |
|------|---------|-------------------|
| `.github/copilot-instructions.md` | Top-level system prompt for all Copilot sessions | `CLAUDE.md` |
| `.github/instructions/*.instructions.md` | Scoped steering docs (auto-loaded by Copilot) | `steering_docs/` |
| `.github/prompts/*.prompt.md` | Slash-command-style agent prompts | `skills/project/` |
| `sync.ps1` | Deploy files to a target workspace's `.github/` | `sync.ps1` |

## Quick start

Deploy all skills to a workspace:
```powershell
.\sync.ps1 -Workspace "C:\Projects\MyRepo"
```

Deploy to default workspace (`E:\agent_workspace`):
```powershell
.\sync.ps1
```

Harvest live files back into this repo:
```powershell
.\sync.ps1 -Harvest
```

## How Copilot loads these

- **`copilot-instructions.md`** — loaded automatically in every Copilot chat in the workspace
- **`*.instructions.md`** — loaded automatically based on `applyTo` glob patterns
- **`*.prompt.md`** — invoked manually via the **Copilot Chat → Prompts** picker or `#` reference

## Skill/Instruction format

### Prompt files (`.prompt.md`)
```yaml
---
mode: agent
description: One-line description shown in the prompt picker
---
<full prompt body>
```

### Instruction files (`.instructions.md`)
```yaml
---
applyTo: "**"   ← glob pattern: which files trigger this instruction
---
<instruction body>
```

## Sync with claude-skills

This repo is a **converted mirror** — the source of truth is `ForgetfulFolly/claude-skills`.
When steering docs are updated there, re-convert and push here.

## Contents

### Prompts (agent workflows)
- `create-task` — Create a new swarm task branch with full pre-dispatch checks
- `loop-check` — Scan all active branches for loops, stalls, and ready reviews
- `review-branch` — Full PASS/FAIL code review of a task branch
- `service-status` — Check all swarm services, workers, roamers, GPU, and vLLM

### Instructions (always-on steering)
- `afp-guardrails` — Active failure prevention patterns (AFP-008, AFP-011, AFP-014, AFP-016, AFP-018)
- `code-quality-checklist` — Pre-commit checklist for implementation code
- `failure-pattern-triggers` — When to pause the queue and capture a new rule
- `false-completion-prevention` — How to avoid AFP-008 (REVIEW.md with no real changes)
- `merge-quality-gates` — What the merge service validates before merging to main
- `orchestrator-discipline` — Opus orchestrates, Sonnet executes — token economy rules
- `sonnet-spec-template` — Non-negotiable patterns for task specs
- `v2-relay-protocol` — Phase-based worker handoff (research → code → test → merge)
