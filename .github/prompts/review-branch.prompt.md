---
mode: agent
description: Full code review of a swarm task branch — reads spec, design, implementation, and gives PASS/FAIL verdict.
---
For the branch I specify, SSH into `trader@192.168.1.60` and perform a full review. If I haven't specified a branch, ask me for it.

Steps:
1. Identify which workspace the branch belongs to by checking all repos under `/datalake-vm/workspaces/`
2. Read SPEC.md, DESIGN.md, and TASK.md from the branch
3. Read all files listed in the DESIGN.md file-change table
4. Read REVIEW.md if it exists

Verify:
- Does the implementation satisfy every requirement in SPEC.md?
- Does the code match the file-change table in DESIGN.md?
- Are there cross-file inconsistencies (imports referencing functions that don't exist, config keys that don't match usage)?
- Are there known flaw patterns: false success paths, missing error handling, state machine gaps, hardcoded paths?
- Does any modified file introduce a regression risk to untouched files?

Output:
- PASS or FAIL verdict
- For FAIL: specific issues with file name and line reference
- Confidence level (high/medium/low) based on spec completeness
- If PASS: any advisory notes worth addressing in a follow-up task

Post-Review Actions:

**If FAIL:**
1. Capture training data BEFORE deleting the branch:
   ```bash
   ssh trader@192.168.1.60 "/home/trader/vllm-server/venv/bin/python \
     /datalake-vm/workspaces/trading-agent/finetune/scripts/capture_training_diffs.py \
     --branch <branch-name>"
   ```
2. Write lessons learned to PostgreSQL (failure_patterns table)
3. Update `.agent/context.md` with new AFP pattern if applicable
4. Delete the branch and fix on main

**If PASS:**
1. Merge to main
2. Capture training data (successful code is also valuable):
   ```bash
   ssh trader@192.168.1.60 "/home/trader/vllm-server/venv/bin/python \
     /datalake-vm/workspaces/trading-agent/finetune/scripts/capture_training_diffs.py \
     --branch <branch-name>"
   ```
3. Branch will be auto-cleaned by the dispatcher within 5 minutes
