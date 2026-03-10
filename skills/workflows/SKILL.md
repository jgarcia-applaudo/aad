---
name: workflows
description: Generate GitHub Actions workflows powered by Claude Code or GitHub Copilot
---

# AAD Workflows — GitHub Actions Generator

You generate GitHub Actions workflows adapted to the current project's real stack and tools, powered by Claude Code or GitHub Copilot.

## Phase 1: Project Detection

### 1.1 Scan project stack

Read the following files if they exist (do not fail if they don't):

- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `pyproject.toml`, `setup.py`, `requirements.txt`, `Pipfile`
- `go.mod`, `go.sum`
- `Cargo.toml`
- `Gemfile`
- `build.gradle`, `pom.xml`
- `.eslintrc*`, `.prettierrc*`, `biome.json`
- `tsconfig.json`

From what was detected, determine:

- **Primary language(s)** and runtime
- **Package manager** (npm, yarn, pnpm, pip, uv, cargo, go, etc.)
- **Linter/Formatter** (ESLint, Prettier, Biome, Ruff, Black, golangci-lint, etc.)
- **Test runner** (Jest, Vitest, Pytest, Go test, etc.)
- **Key commands** (build, test, lint, format — extract from scripts or config)

### 1.2 Check existing workflows

Check which of the 4 standard workflow files already exist in `.github/workflows/`:
- `pr-review.yml`
- `code-quality.yml`
- `dependency-audit.yml`
- `docs-sync.yml`

Classify each as **new** (file doesn't exist) or **skip** (file already exists).

## Phase 2: Choose Engine

Ask the user which engine to use:

```
How should the GitHub Actions workflows be powered?

  1. Claude Code — Uses anthropics/claude-code-action for AI-powered review and fixes.
     Requires: ANTHROPIC_API_KEY secret in your GitHub repo.

  2. GitHub Copilot — Uses Copilot code review on PRs.
     Requires: Copilot enabled for your organization/repo.

Choose (1/2):
```

### If the user chooses "Claude Code":

Before generating any workflows, fetch the latest documentation:

1. Use web search to find the latest docs for `anthropics/claude-code-action` GitHub Action
2. Present the user with a setup checklist:

```
Before I generate the workflows, configure your GitHub repo:

  1. Go to: https://github.com/[owner]/[repo]/settings/secrets/actions
  2. Add a new repository secret:
     Name: ANTHROPIC_API_KEY
     Value: Your Anthropic API key (get one at https://console.anthropic.com/)

  3. Go to: https://github.com/[owner]/[repo]/settings/actions
  4. Under "Workflow permissions", enable:
     ✓ Read and write permissions
     ✓ Allow GitHub Actions to create and approve pull requests

  Docs: [URL found from web search]

Have you completed the setup? (yes/no)
```

If the user says **no** → remind them to complete setup and stop.
If the user says **yes** → proceed to Phase 3.

### If the user chooses "GitHub Copilot":

1. Use web search to find the latest docs for GitHub Copilot code review in pull requests
2. Present setup checklist with links found from docs
3. Wait for user confirmation before proceeding

## Phase 3: Select Workflows

Present the list of available workflows with their current status:

```
Detected stack:
  Language: [detected]
  Package manager: [detected]
  Linter: [detected]
  Formatter: [detected]
  Test runner: [detected]

Engine: [Claude Code / GitHub Copilot]

Available workflows:
  1. [new]  PR Review         — AI-powered code review on pull requests
  2. [new]  Code Quality      — Weekly code quality sweep
  3. [skip] Dependency Audit  — Biweekly dependency audit (already exists)
  4. [new]  Docs Sync         — Monthly documentation sync check

Which workflows do you want to generate? (e.g., "1,2,4" or "all new")
```

- Show `[new]` for workflows that don't exist yet
- Show `[skip]` for workflows that already exist (cannot be selected)
- The user picks which ones to generate by number, or "all new"
- If ALL 4 already exist, inform the user and stop

## Phase 4: Generate Workflows

**CRITICAL**: All generated files must be portable. Never use absolute paths. Use the project's REAL commands, package manager, and runtime.

Generate only the workflows the user selected. Output to `.github/workflows/[name].yml`.

### Claude Code Engine

Use `anthropics/claude-code-action@beta` for all workflows. Fetch the latest documentation to determine the current recommended version and configuration options.

#### PR Review (`pr-review.yml`)
- **Trigger**: PR open/synchronize/reopen + issue comments containing `@claude`
- Claude reviews the diff and leaves comments
- Tools: `Read, Glob, Grep, Bash(git:*), Bash(gh:*)`
- Max turns: ~10
- Allow `@claude` mentions in PR comments for follow-up

#### Code Quality (`code-quality.yml`)
- **Trigger**: Weekly (Sundays 8 AM UTC) + `workflow_dispatch`
- Claude reviews random directories for code quality issues
- Claude FIXES issues (not just reports) and creates a PR
- Max turns: ~35

#### Dependency Audit (`dependency-audit.yml`)
- **Trigger**: Biweekly (1st and 15th) + `workflow_dispatch`
- Claude checks outdated/vulnerable dependencies
- Claude conservatively updates packages, runs lint/test to verify
- Creates a PR with updates if successful
- Max turns: ~40

#### Docs Sync (`docs-sync.yml`)
- **Trigger**: Monthly (1st) + `workflow_dispatch`
- Claude finds code changed in last 30 days
- Checks if related docs are WRONG (not merely missing)
- Creates a PR only if actual problems are found
- Max turns: ~30

### GitHub Copilot Engine

#### PR Review (`pr-review.yml`)
- **Trigger**: PR open/synchronize/reopen
- Enable automatic Copilot review on PR open
- Run the project's linter/formatter as a pre-check step
- Copilot reviews the diff and leaves suggestions

#### Code Quality (`code-quality.yml`)
- **Trigger**: Weekly (Sundays 8 AM UTC) + `workflow_dispatch`
- Run full lint/format check across the codebase
- Create a GitHub Issue if problems are found

#### Dependency Audit (`dependency-audit.yml`)
- **Trigger**: Biweekly (1st and 15th) + `workflow_dispatch`
- Check for outdated/vulnerable deps using native tools
- Create a GitHub Issue if issues are found

#### Docs Sync (`docs-sync.yml`)
- **Trigger**: Monthly (1st) + `workflow_dispatch`
- Find stale docs based on recent code changes
- Create a GitHub Issue listing stale docs

## Workflow Rules

- All workflows must use the project's REAL commands, package manager, and runtime
- Add `workflow_dispatch` to all scheduled workflows for manual trigger
- Use appropriate `concurrency` groups to avoid duplicate runs
- Pin action versions (e.g., `actions/checkout@v4`, `actions/setup-node@v4`)
- Do NOT hardcode API keys — always use `${{ secrets.ANTHROPIC_API_KEY }}`
- Claude Code mode: workflows create PRs with fixes
- Copilot mode: PR review is native, other workflows create GitHub Issues

## Phase 5: Summary

Display a summary table showing ALL available workflows with their final status:

```
AAD Workflows Summary (GitHub Actions, [engine] mode)

| Workflow         | Status    | File                                   | Reason              |
|------------------|-----------|----------------------------------------|----------------------|
| PR Review        | ✓ Created | .github/workflows/pr-review.yml        |                      |
| Code Quality     | ✓ Created | .github/workflows/code-quality.yml     |                      |
| Dependency Audit | — Skipped | .github/workflows/dependency-audit.yml | Already exists       |
| Docs Sync        | — Skipped | —                                      | Not selected by user |
```

**Status values:**
- `✓ Created` — file was generated
- `— Skipped` — not generated, with reason

**Skip reasons** (use the one that applies):
- `Already exists` — file already present, not overwritten
- `Not selected by user` — user chose not to generate this workflow

Then show next steps:

```
Next steps:
  1. Review the generated workflows
  2. Commit the .github/workflows/ folder
  3. Workflows will activate automatically on GitHub
```
