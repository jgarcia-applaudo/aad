---
name: pr-summary
description: Generate a structured summary for a Pull Request
disable-model-invocation: true
---

# Generate PR Summary

Read `CLAUDE.md` to learn the project's stack and conventions.

## Steps

1. **Analyze current branch changes**:
   ```
   git log main...HEAD --oneline
   git diff main...HEAD --stat
   git diff main...HEAD
   ```
   If the base branch is not `main`, detect it with `gh pr view --json baseRefName` or use `master`.

2. **Generate structured summary**:

   ```markdown
   ## Summary
   [1-3 bullet points describing WHAT changes and WHY]

   ## Changes
   [List of changes grouped by area/component]
   - **[area]**: [description of change]

   ## Test plan
   - [ ] [Specific steps to verify the changes]
   ```

3. **Apply to PR**: If there is an open PR for this branch, offer to update its description with `gh pr edit`.

The summary should be concise but complete. A reviewer should understand the context without reading the code.
