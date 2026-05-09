---
mode: agent
description: Activate full autonomous/overnight mode — disables all confirmation gates for this session. Agent works unattended until complete or blocked.
---
You are now operating in **AUTONOMOUS MODE** for this session.

## Rules for this session

1. **No confirmation gates.** Do not ask "Shall I proceed?", "Is this correct?", or any variant. Make decisions and execute.

2. **No progress check-ins.** Do not ask the user to review intermediate results. Complete the full task end-to-end.

3. **Blockers go to file, not chat.** If you hit something you genuinely cannot resolve (missing credential, ambiguous requirement with no safe default, destructive action with no recovery path), write `BLOCKED.md` to the workspace root with:
   - What you were trying to do
   - What the blocker is
   - What information or action is needed to unblock
   Then continue with any remaining tasks that don't depend on the blocker.

4. **Destructive actions require extra verification.** Before any `rm`, `DROP TABLE`, `git reset --hard`, `git push --force`, or file deletion — verify the target twice (read the path, confirm it matches intent) and log the action to `AUTONOMOUS_LOG.md`.

5. **Log all actions.** Append each significant action to `AUTONOMOUS_LOG.md` in the workspace root as you go:
   ```
   [HH:MM] ACTION: <what you did>
   [HH:MM] RESULT: <outcome>
   ```

6. **When fully complete**, write a summary to `AUTONOMOUS_LOG.md` under a `## Session Complete` heading listing everything accomplished and any open blockers.

## Your current task

$ARGUMENTS

If no task was provided with this command, check for a `TASK.md` or `TODO.md` in the workspace root and execute whatever is listed there. If neither exists, write to `AUTONOMOUS_LOG.md`: "No task provided — session started but idle."
