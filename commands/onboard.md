---
name: onboard
description: Explore the codebase to understand the context of a task
disable-model-invocation: true
---

# Task Onboarding

Read `CLAUDE.md` to learn the project's stack and structure.

## Input

The task to explore is provided in `$ARGUMENTS`. If no arguments are provided, ask the user what task they want to work on.

## Steps

1. **Understand the task**: Analyze what needs to be implemented or modified.

2. **Explore the codebase**:
   - Identify relevant files and modules for the task
   - Read existing code in those areas
   - Understand dependencies and how components connect
   - Review related existing tests

3. **Load relevant skills**: If skills in `skills/` apply to the task, read them to understand the project's patterns.

4. **Present context**:

   ```
   ## Task Context
   [Summary of what you understand needs to be done]

   ## Relevant Files
   - [file] — [what it does and why it's relevant]

   ## Proposed Approach
   1. [step]
   2. [step]

   ## Questions
   - [Any ambiguity or decision the user needs to make]
   ```

5. **Ask before acting**: Do not start implementing. Wait for user confirmation on the proposed approach.

Use extended thinking to reason about architecture and the implications of changes.
