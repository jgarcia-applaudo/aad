---
name: pr-review
description: Pull Request code review
disable-model-invocation: true
---

# Pull Request Review

Read `CLAUDE.md` to learn the project's stack, conventions, and critical rules.

## Input

If `$ARGUMENTS` is provided, use it as the PR number or URL. Otherwise, review the PR for the current branch.

## Steps

1. **Get PR context**:
   ```
   gh pr view $ARGUMENTS --json title,body,baseRefName,headRefName,files
   gh pr diff $ARGUMENTS
   ```

2. **Load standards**: Read the `code-reviewer` agent if it exists at `agents/code-reviewer.md` and relevant skills in `skills/`.

3. **Review the diff** evaluating:
   - Do changes comply with project conventions defined in `CLAUDE.md`?
   - Are there logic errors, unhandled edge cases, or potential bugs?
   - Is error handling adequate?
   - Are there security implications?
   - Do tests cover the changes? Are tests missing?
   - Are variable/function names clear and consistent?

4. **Publish review**: Use `gh` to post comments on the PR, categorized:

   - **Critical**: Bugs, security vulnerabilities, data loss — Must be fixed before merge
   - **Warning**: Convention violations, missing tests, weak error handling — Should be fixed
   - **Suggestion**: Readability improvements, minor refactors — Optional

Do not make trivial comments (style, formatting). Focus on real issues that impact code quality or stability.
