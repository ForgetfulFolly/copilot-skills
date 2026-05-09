---
mode: agent
description: Create a new task branch in the ForgetfulFolly swarm with full spec, pre-dispatch checks, and roamer wake.
---
When this command is invoked, immediately present the user with two mode options before doing anything else:

---
**Mode A — Interactive:** I ask structured questions one section at a time to build the task spec collaboratively. Best when the task is still loosely defined.

**Mode B — Brief:** You provide a full description upfront; I proceed and only pause for genuine ambiguities. Best when you already know exactly what you want.

Which mode? **A** or **B**?

---

## MODE A: Interactive

Ask each section in order and wait for the response before moving to the next.

1. **Task title** — "What's a short title for this task? (e.g. WeatherSkill, auth bug fix)"
2. **Workspace** — "Which workspace? (telegram-approve / trading-agent / viral_channel / Warren_n_the_buffets / embird / server_maintenence)"
3. **What it does** — "Describe what this task should accomplish in 2-3 sentences."
4. **Exact files** — "List every file that needs to be created or modified. Be specific."
5. **Done when** — "List the acceptance criteria as checkboxes. Each one should be testable."
6. **Constraints** — "Any known constraints? (APIs to use, things to avoid, Python version quirks, protected files)"
7. **Dependencies** — "Does this depend on another task being merged first? If so, which one?"

Then proceed to Pre-Dispatch Checks.

---

## MODE B: Brief

Ask once: "Describe the task. Include: workspace, files to change, what it should do, and any constraints you know about."

Parse the response. Fill every template field you can infer. Then ask only for fields that are genuinely missing or ambiguous.

Then proceed to Pre-Dispatch Checks.

---

## PRE-DISPATCH CHECKS

SSH to `trader@192.168.1.60` and run these before creating anything:

**1. Protected path check (telegram-approve only)**
```bash
PROTECTED="swarm.py ai_agent.py hooks.py"
for f in $PROTECTED; do
  if echo "$SCOPED_FILES" | grep -q "$f"; then
    echo "BLOCKED: $f is a protected path"
  fi
done
```
If any scoped file is protected → tell the user, suggest decomposing scope to use only `bot_hooks.py`, `skills/`, and `tests/`. Do NOT create the branch.

**2. Dependency check**
```bash
cd /datalake-vm/workspaces/<workspace>
git fetch --quiet origin
git branch -r --merged origin/main | grep "agent/<depends-on-branch>"
```
If the dependency branch is NOT merged → warn the user and ask whether to proceed anyway or wait.

**3. Determine next task number**
```bash
git branch -r | grep 'agent/task-' | grep -oP 'task-\K\d+' | sort -n | tail -1
```
New task number = highest existing + 1.

**4. Decide Skip-Spec**
Set `Skip-Spec: true` if ALL of these are true:
- Exact file list is provided (no "and related files" vagueness)
- Acceptance criteria are numbered and testable
- No architectural decisions left open
- Task is additive (new skill, new test, new config — not a refactor)

---

## BRANCH CREATION

Once checks pass:

```bash
BRANCH="agent/task-<NN>-<slug>"
WORKSPACE="/datalake-vm/workspaces/<workspace>"
cd $WORKSPACE
git fetch --quiet origin
git worktree add /tmp/task-<NN>-create origin/main
cd /tmp/task-<NN>-create
```

Write TASK.md using this exact template:

```markdown
# Task <NN> — <Title>
Priority: <1=critical / 2=high / 3=normal>
Status: queued
Scope: <comma-separated exact file list>
Merge-Order: <NN>
Depends-On: <branch-name or none>
Worker-Role: <code|code-lead|research|test|infra|investigator>
Skip-Spec: true   ← include only if decided above

## Summary
<2-3 sentence description of what this task accomplishes and why>

## Acceptance Criteria
- [ ] <specific, testable criterion>
- [ ] <criterion>

## Known Constraints
- <list any: protected paths to avoid, Python version quirks, API keys, etc.>
```

Then:
```bash
git add TASK.md
git commit -m "task: <NN> — <Title> (queued for swarm)"
git push origin HEAD:refs/heads/<branch-name>
git worktree remove /tmp/task-<NN>-create --force
```

---

## WAKE THE SWARM

```bash
bash /home/trader/bin/swarm-wake.sh
```

**After the task completes**, put the swarm back to sleep:
```bash
bash /home/trader/bin/swarm-sleep.sh
```

---

## CONFIRMATION

After pushing, report:
- Branch name and URL pattern: `agent/task-<NN>-<slug>`
- **Worker assigned**: which named worker will claim it (by role match)
- Roamers woken: how many started
- Whether Skip-Spec is set and why
- Any warnings from the pre-dispatch checks
- Estimated phases: Spec (~15 min, or skipped) → Design (~20 min) → Implement (~45 min)

---

## WORKER ROSTER

| Name | Role | Best For |
|------|------|----------|
| Larry | code-lead | Complex multi-file implementation |
| Moe | code | Focused single-file implementation |
| Curly | code | New file creation, creative solutions |
| Doc | research | Spec writing, codebase analysis, design |
| Grumpy | test | pytest, validation, regression checks |
| Happy | code | Simple fixes, cleanup, refactoring |
| Sleepy | research | Documentation, README, thorough analysis |
| Bashful | test | Post-implementation verification |
| Sneezy | infra | Shell, systemd, git ops, deployment |
| Dopey | code | Repetitive tasks, bulk operations |
| Frank Drebin | investigator | Debugging, log analysis, root cause |
