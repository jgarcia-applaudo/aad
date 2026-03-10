---
name: code-quality
description: Project code quality analysis
disable-model-invocation: true
---

# Code Quality Analysis

Read `CLAUDE.md` to learn the project's stack, commands, and conventions.

## Steps

1. **Run project tools**: Execute the lint and type-check commands defined in `CLAUDE.md`. If not defined, try to detect them from the project's configuration files.

2. **Manual analysis**: Search through the project's source files for:
   - Typing violations (e.g.: `any` in TypeScript, missing type hints in Python)
   - Missing or incomplete error handling (empty try/catch, promises without catch, silenced errors)
   - Dead code or unused imports
   - Insecure patterns (SQL injection, XSS, hardcoded secrets)
   - Duplicated code that should be abstracted
   - Excessively long or complex functions

3. **Verify against skills**: If skills exist in `skills/`, use them as reference to validate project patterns.

4. **Report**: Present findings organized by severity:

```
## Critical (requires immediate fix)
- [finding + file + line]

## Warning (should be fixed)
- [finding + file + line]

## Suggestion (optional improvement)
- [finding + file + line]

## Summary
- X files analyzed
- X critical issues
- X warnings
- X suggestions
```

Do not report issues already detected by the linter/type-checker. Only add valuable findings that automated tools don't cover.
