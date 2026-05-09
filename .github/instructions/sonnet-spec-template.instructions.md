---
applyTo: "**"
---
# Sonnet Task Spec Template — Bake In Proven Patterns

Every task placed into `/landing-zone/workspaces/sonnet-queue/pending/` follows this template. Patterns below are non-negotiable defaults captured from real failure modes — don't omit them "to keep the spec short."

## Required Sections

```markdown
# Task NNN — <one-line summary>

FILE: <absolute path on VM>
EDIT ALLOWED  ← only if modifying existing file; otherwise omit (NEW FILE ONLY default)

VERIFY:
```
ssh trader@192.168.1.60 "<command that exits 0 on success>"
```

---

## CONTEXT

<embedded real interfaces — function signatures, model fields, env var names>
<copied from the actual files via grep/Read, NOT from memory>

---

## SPEC

<exact behavioral contract>
```

## Non-Negotiable Patterns to Bake In

### 1. Rate-Limit-Aware Tests (Any HTTP Test)

When tests hit `/api/auth/register` (5/min), `/api/privacy/dsar` (3/hour), `/api/auth/request-reset` (3/min), or any other rate-limited endpoint:

```python
if r.status_code == 429:
    pytest.skip("rate-limited — re-run after cooldown")
```

Always treat 429 as "skip" not "fail" in tests.

### 2. Unique Test Fixtures (No Shared State)

Every test that registers a user, creates an account, etc. must use `uuid.uuid4().hex[:8]` to avoid cross-test collisions.

### 3. SCP+Execute, Never Inline Heredocs (Any VM Patch Task)

When a task spec describes deploying a patch:
- BAD: `ssh trader@... "python3 - <<'EOF' ... EOF"`
- GOOD: spec instructs the worker to `Write` the script locally first, then `scp` to `/tmp/`, then `ssh` to execute.

This avoids bash quoting collisions when scripts contain SQL/regex content.

### 4. File Path Correctness (Flutter)

- Flutter binary on VM is at `/snap/bin/flutter` — verify commands MUST use full path.
- Flutter package name is `audilynow` (from `pubspec.yaml`).
- Use relative imports inside `lib/` (`import '../widgets/foo.dart';`).

### 5. Field-Name Precision (open-song API)

Always copy actual field names from the model file:
- DSAR uses `request_kind`, NOT `request_type`
- Consent uses `consent_kind`, `consent_version`, `granted`, `text_hash` (64-char hex)
- Audit endpoints: `/api/audit/user/{id}/activity` and `/api/audit/{type}/{id}/history`
- OAuth2 token: form-encoded `username=X&password=Y` (username field, NOT email)

### 6. Verify Command Must Actually Verify

- Pytest tasks: must include `-v` and `tail -10` so the result is human-readable
- Flutter analyze: filter on `^error` (info/warnings are fine)
- Shell scripts: `bash -n <path>` for syntax-only checks
- Backend imports: `python -c 'import main'` is a strong syntax + import-graph check

### 7. CONTEXT Section Discipline

Before pasting anything into CONTEXT:
- Run `Read` or `grep` against the actual file on the VM
- Copy signatures verbatim, no paraphrase
- Include line numbers when referring to a specific spot in an existing file
- If writing CONTEXT without having opened the relevant file in the last 60 seconds → STOP and open it

## Spec Quality Self-Check Before Staging

- [ ] Every API path mentioned was grep'd in the last 60 seconds
- [ ] Every model field mentioned was Read from the actual class
- [ ] Verify command will exit 0 on success and non-zero on failure
- [ ] Rate-limit handling is included for any test hitting limited endpoints
- [ ] If editing an existing file, the file was Read first AND `EDIT ALLOWED` is in the spec
- [ ] No "I'm pretty sure the path is X" — only verified facts
