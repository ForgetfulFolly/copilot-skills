---
applyTo: "**"
---
# Code Quality Checklist — Before Committing

Run through this checklist before committing implementation code.

## Imports
- [ ] Every `from typing import ...` needed is present IN THIS FILE
- [ ] No relative imports that go beyond the package root (`from ..config` is ok, `from ...` is not)
- [ ] No imports from modules that don't exist — verify with `ls` or `grep`
- [ ] stdlib → third-party → local import order, separated by blank lines

## File Integrity
- [ ] Read the file BEFORE modifying it — never overwrite without reading first
- [ ] If `git diff` shows >50% deletion, STOP and review
- [ ] No file exceeds 1,500 lines
- [ ] New files have proper `__init__.py` entries if they're in a package

## Testing
- [ ] Every new function has at least one test
- [ ] Tests can be run independently: `python -m pytest tests/test_myfile.py -v`
- [ ] Tests don't depend on external services (mock them)
- [ ] conftest.py is present if tests need fixtures

## Type Safety
- [ ] All function signatures have type hints
- [ ] Use `X | None` syntax (Python 3.10+), not `Optional[X]` for new code
- [ ] Dataclasses over plain dicts for structured data

## Scope
- [ ] Only modify files listed in TASK.md Scope: field
- [ ] If you need to modify a file outside scope, explain why in HANDOFF.md
