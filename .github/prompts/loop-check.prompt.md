---
mode: agent
description: Check all active task branches across swarm workspaces for loops, stalls, and reviews ready to merge.
---
SSH into `trader@192.168.1.60` and check all active task branches across all workspaces under `/datalake-vm/workspaces/` for loops, stalls, and ready reviews.

**IMPORTANT — Heartbeat filtering:**
Workers write `[agent] heartbeat: roamer-N` commits every 5 minutes. With 11 roamers, a healthy branch accumulates ~132 heartbeat commits/hour. Always filter these out:
```bash
git log $branch --oneline | grep -v 'heartbeat:' | wc -l   # real commit count
git log $branch --oneline | grep -v 'heartbeat:' | head -3  # last real commits
```

**Signals (based on non-heartbeat commits only):**
- >10 non-heartbeat commits + no REVIEW.md = loop suspect
- Same file in 3+ consecutive non-heartbeat commits = loop confirmed
- Last non-heartbeat commit >30 min ago + no REVIEW.md = stalled
- REVIEW.md exists but not yet actioned = ready for supervisor review

**For each workspace, run:**
```bash
cd /datalake-vm/workspaces/<workspace>
git fetch --quiet origin
for branch in $(git branch -r | grep 'agent/task' | grep -v HEAD | awk '{print $1}'); do
  has_review=$(git show $branch:REVIEW.md 2>/dev/null >/dev/null && echo "REVIEW_READY" || echo "")
  has_blocked=$(git show $branch:BLOCKED.md 2>/dev/null >/dev/null && echo "BLOCKED" || echo "")
  total=$(git rev-list --count origin/main..$branch 2>/dev/null || echo 0)
  real=$(git log $branch --oneline | grep -v 'heartbeat:' | wc -l | tr -d ' ')
  last_real=$(git log $branch --oneline | grep -v 'heartbeat:' | head -1)
  echo "$branch | total:$total real:$real | $has_review$has_blocked | last: $last_real"
done
```

Skip branches where BLOCKED.md first line is "# Merged to main" or "# Completed".

**Report format:**
1. **ALERT** for any REVIEW.md ready (needs merge decision)
2. **LOOP FLAG** for real commits >10, no REVIEW.md (show last 3 real commits)
3. **STALL FLAG** for no real commit in >30 min (show last real commit timestamp)
4. Otherwise: one-line confirmation per active branch
5. Summary: total active branches per repo, overall health assessment
6. **SWARM STATUS**: check if roamers are running (`systemctl is-active trading-agent-roamer@1`)
   - If roamers are running but NO active tasks exist → recommend `bash /home/trader/bin/swarm-sleep.sh`
   - If roamers are stopped and active tasks exist → recommend `bash /home/trader/bin/swarm-wake.sh`
