---
name: ticket
description: End-to-end ticket implementation workflow
user-invocable: true
argument-hint: ticket ID, URL, or description
disable-model-invocation: true
---

# End-to-End Ticket Workflow

Read the project configuration (`CLAUDE.md` or `.github/copilot-instructions.md`) to learn the project's stack, commands, and conventions.

## Input

The ticket is provided in `$ARGUMENTS`. It can be:
- A ticket ID (e.g.: `PROJ-123`, `#456`)
- A Jira, Linear, or GitHub Issue URL
- A direct task description

## Steps

### 1. Get ticket context

- If it's a Jira or Linear ID/URL, try to get details using available MCP tools
- If it's a GitHub Issue, use `gh issue view`
- If it's a description, use it directly

### 2. Explore the codebase

- Identify relevant files and modules
- Understand existing patterns in the affected code area
- Read related tests
- Load relevant domain skills or instructions

### 3. Create branch

Follow the branch naming convention defined in the project configuration. If no convention is defined, use:
```
feature/[ticket-id]-[short-description]
```

### 4. Implement

- Follow the project's conventions and rules defined in the project configuration
- Apply patterns from relevant skills
- Write tests for the changes
- Run the project's test and lint commands

### 5. Verify

- Run tests: ensure all pass (new and existing)
- Run linter: no new errors or warnings
- Run type-check if applicable: no errors

### 6. Prepare PR

- Generate the PR summary using the pr-summary skill format
- Create the PR with `gh pr create`
- If the ticket has an ID, include it in the PR title

### 7. Update ticket (if applicable)

If you have access to the ticketing system via MCP, update the ticket status and add the PR link.
