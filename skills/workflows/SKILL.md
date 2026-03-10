---
name: workflows
description: Generate GitHub Actions workflows adapted to the project's stack
---

# AAD Workflows — GitHub Actions Generator

You generate GitHub Actions workflows adapted to the current project's real stack and tools.

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

## Phase 2: Choose Workflow Mode

Ask the user which type of workflows they want:

```
How would you like your workflows powered?

  1. Standard — Uses your project's native tools (linters, formatters, test runners)
     No API keys needed. Workflows run your real commands directly.

  2. Claude Code — Uses anthropics/claude-code-action to have Claude review PRs,
     fix code quality issues, and manage dependencies.
     Requires: ANTHROPIC_API_KEY secret in your GitHub repo.

  3. GitHub Copilot — Uses GitHub Copilot-powered code review on PRs.
     Requires: Copilot enabled for your organization/repo.

Choose (1/2/3):
```

### If the user chooses "Claude Code" (option 2):

Before generating any workflows, fetch the latest documentation:

1. Use web search to find the latest docs for `anthropics/claude-code-action` GitHub Action
2. Present the user with a setup checklist:

```
Before I generate the workflows, you need to configure your GitHub repo:

  1. Go to: https://github.com/[owner]/[repo]/settings/secrets/actions
  2. Add a new repository secret:
     Name: ANTHROPIC_API_KEY
     Value: Your Anthropic API key (get one at https://console.anthropic.com/)

  3. Go to: https://github.com/[owner]/[repo]/settings/actions
  4. Under "Workflow permissions", enable:
     ✓ Read and write permissions
     ✓ Allow GitHub Actions to create and approve pull requests

Have you completed the setup? (yes/no)
```

If the user says **no** → remind them to complete setup and stop.
If the user says **yes** → proceed to Phase 3.

### If the user chooses "GitHub Copilot" (option 3):

Before generating any workflows, fetch the latest documentation:

1. Use web search to find the latest docs for GitHub Copilot code review in pull requests
2. Present the user with a setup checklist:

```
Before I generate the workflows, verify your Copilot setup:

  1. Go to: https://github.com/organizations/[org]/settings/copilot
     (or https://github.com/settings/copilot for personal repos)
  2. Ensure Copilot is enabled for your organization/repo
  3. Under "Copilot in pull requests", enable:
     ✓ Code review suggestions

  Docs: (include the URL found from web search)

Have you completed the setup? (yes/no)
```

If the user says **no** → remind them to complete setup and stop.
If the user says **yes** → proceed to Phase 3.

### If the user chooses "Standard" (option 1):

Proceed directly to Phase 3. No additional setup needed.

## Phase 3: User Confirmation

Present what was detected and what will be generated:

```
Detected stack:
  Language: [detected]
  Package manager: [detected]
  Linter: [detected]
  Formatter: [detected]
  Test runner: [detected]

Mode: [Standard / Claude Code / GitHub Copilot]

GitHub workflows:
  ✓ .github/workflows/pr-review.yml (new)
  ✓ .github/workflows/code-quality.yml (new)
  — .github/workflows/dependency-audit.yml (already exists, skip)
  ✓ .github/workflows/docs-sync.yml (new)

Generate the [N] new workflows? (yes/no)
```

- If ALL 4 already exist, inform the user and stop
- If ANY are new, ask the user whether to generate the missing ones
- If the user says **no** → stop

## Phase 4: Generate Workflows

**CRITICAL**: All generated files must be portable. Never use absolute paths. Use the project's REAL commands, package manager, and runtime.

Generate only the workflows classified as **new** (do NOT overwrite existing files).

---

### Standard Mode Workflows

Use the project's native tools directly in workflow steps.

#### 4.1 `pr-review.yml` — PR Code Review

Triggered on PR open/synchronize/reopen. Runs the project's linter and formatter in check mode. Reports issues.

```yaml
name: PR Code Review
on:
  pull_request:
    types: [opened, synchronize, reopened]

# Adapt jobs to the project's real tools:
# - JS/TS: npm ci → npx eslint . → npx prettier --check .
# - Python: pip install -e ".[dev]" → ruff check . → ruff format --check .
# - Go: golangci-lint run → go vet ./...
# - Rust: cargo clippy → cargo fmt -- --check
#
# Also include project-specific checks:
# - If the project has migrations (Alembic, Prisma, etc.), check for conflicts
# - If the project has TypeScript, run tsc --noEmit
# - If the project has tests, run the test suite
```

#### 4.2 `code-quality.yml` — Scheduled Code Quality Sweep

Runs weekly (Sundays 8 AM UTC). Creates a GitHub Issue if problems are found.

```yaml
name: Code Quality Sweep
on:
  schedule:
    - cron: '0 8 * * 0'
  workflow_dispatch:

# Steps:
# 1. Checkout + setup language/runtime
# 2. Install dependencies
# 3. Run linter in check mode, capture output
# 4. Run formatter in check mode, capture output
# 5. If any issues found, create a GitHub Issue with findings
# 6. If no issues, log success
```

#### 4.3 `dependency-audit.yml` — Biweekly Dependency Audit

Runs 1st and 15th of each month. Creates a GitHub Issue if vulnerabilities are found.

```yaml
name: Dependency Audit
on:
  schedule:
    - cron: '0 10 1,15 * *'
  workflow_dispatch:

# Steps:
# 1. Checkout + setup language/runtime
# 2. Install dependencies
# 3. Check for outdated packages (npm outdated / pip list --outdated / go list -u -m all)
# 4. Check for vulnerabilities (npm audit / pip-audit / govulncheck)
# 5. If issues found, create a GitHub Issue with findings
# 6. If clean, log success
```

#### 4.4 `docs-sync.yml` — Monthly Documentation Sync

Runs 1st of each month. Creates a GitHub Issue listing stale docs.

```yaml
name: Documentation Sync Check
on:
  schedule:
    - cron: '0 9 1 * *'
  workflow_dispatch:
    inputs:
      days_back:
        description: 'Number of days to look back for changes'
        default: '30'

# Steps:
# 1. Checkout with full history (fetch-depth: 0)
# 2. Find source files changed in the last N days
# 3. Find documentation files (README.md, docs/**, *.md)
# 4. Compare modification dates: flag docs older than related source
# 5. If stale docs found, create a GitHub Issue with findings
# 6. If all docs are current, log success
```

---

### Claude Code Mode Workflows

Use `anthropics/claude-code-action@beta` for AI-powered review and fixes. Fetch the latest documentation to determine the current recommended version and configuration options.

#### 4.1 `pr-review.yml` — AI PR Code Review

```yaml
name: PR Code Review
on:
  pull_request:
    types: [opened, synchronize, reopened]
  issue_comment:
    types: [created]

# Use anthropics/claude-code-action@beta
# - Checkout the PR
# - Run Claude with the project's code review standards
# - Claude reviews the diff and leaves comments
# - Use tools: Read, Glob, Grep, Bash(git:*), Bash(gh:*)
# - Use the ANTHROPIC_API_KEY secret
# - Set max_turns appropriate for review (e.g., 10)
# - Allow @claude mentions in PR comments for follow-up
```

#### 4.2 `code-quality.yml` — AI Code Quality Sweep

```yaml
name: Code Quality Sweep
on:
  schedule:
    - cron: '0 8 * * 0'
  workflow_dispatch:

# Use anthropics/claude-code-action@beta
# - Claude reviews random directories for code quality
# - Claude actually FIXES issues (not just reports)
# - Creates a PR with fixes if any issues found
# - Set max_turns higher (e.g., 35) for thorough review
```

#### 4.3 `dependency-audit.yml` — AI Dependency Audit

```yaml
name: Dependency Audit
on:
  schedule:
    - cron: '0 10 1,15 * *'
  workflow_dispatch:

# Use anthropics/claude-code-action@beta
# - Claude checks outdated/vulnerable dependencies
# - Claude conservatively updates packages
# - Runs lint/test to verify updates don't break anything
# - Creates a PR with updates if successful
# - Set max_turns higher (e.g., 40)
```

#### 4.4 `docs-sync.yml` — AI Documentation Sync

```yaml
name: Documentation Sync Check
on:
  schedule:
    - cron: '0 9 1 * *'
  workflow_dispatch:

# Use anthropics/claude-code-action@beta
# - Claude finds code changed in last 30 days
# - Checks if related docs are WRONG (not merely missing)
# - Creates a PR only if actual problems are found
# - Set max_turns moderate (e.g., 30)
```

---

### GitHub Copilot Mode Workflows

Use GitHub Copilot's built-in code review features. Fetch the latest documentation to determine the current recommended configuration.

#### 4.1 `pr-review.yml` — Copilot PR Code Review

```yaml
name: PR Code Review
on:
  pull_request:
    types: [opened, synchronize, reopened]

# Configure Copilot code review:
# - Enable automatic review on PR open
# - Use the project's linter/formatter as a pre-check step
# - Copilot reviews the diff and leaves suggestions
# - No API key needed — uses GitHub's built-in Copilot
```

#### 4.2-4.4 — Standard Workflows

For code-quality, dependency-audit, and docs-sync, use the **Standard mode** templates above. Copilot's built-in features focus on PR review — scheduled maintenance workflows should use the project's native tools.

---

## Workflow Rules

- All workflows must use the project's REAL commands, package manager, and runtime
- Use `workflow_dispatch` on all scheduled workflows so they can also be triggered manually
- Use appropriate `concurrency` groups to avoid duplicate runs
- Pin action versions (e.g., `actions/checkout@v4`, `actions/setup-node@v4`)
- Do NOT hardcode API keys — always use GitHub secrets
- Standard mode: workflows create GitHub Issues for findings (no API key needed)
- Claude Code mode: workflows can create PRs with fixes (requires ANTHROPIC_API_KEY)
- Copilot mode: PR review is automatic, other workflows use standard mode

## Phase 5: Summary

```
Workflows generated ([mode] mode):

  ✓ .github/workflows/pr-review.yml — created
  ✓ .github/workflows/code-quality.yml — created
  — .github/workflows/dependency-audit.yml — already existed, skipped
  ✓ .github/workflows/docs-sync.yml — created

Next steps:
  1. Review the generated workflows
  2. Commit the .github/workflows/ folder
  3. Workflows will activate automatically on GitHub
```
