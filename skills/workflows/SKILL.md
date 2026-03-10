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

## Phase 2: User Confirmation

Present what was detected and what will be generated:

```
Detected stack:
  Language: [detected]
  Package manager: [detected]
  Linter: [detected]
  Formatter: [detected]
  Test runner: [detected]

GitHub workflows:
  ✓ .github/workflows/pr-review.yml (new)
  ✓ .github/workflows/code-quality.yml (new)
  — .github/workflows/dependency-audit.yml (already exists, skip)
  ✓ .github/workflows/docs-sync.yml (new)

Generate the 3 new workflows? (yes/no)
```

- If ALL 4 already exist, inform the user and stop
- If ANY are new, ask the user whether to generate the missing ones
- If the user says **no** → stop

## Phase 3: Generate Workflows

**CRITICAL**: All generated files must be portable. Never use absolute paths. Use the project's REAL commands, package manager, and runtime.

Generate only the workflows classified as **new** (do NOT overwrite existing files):

### 3.1 `pr-review.yml` — PR Code Review

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

### 3.2 `code-quality.yml` — Scheduled Code Quality Sweep

Runs weekly (e.g., Sundays 8 AM UTC). Performs a deep lint/format check across the codebase and creates a GitHub Issue if problems are found.

```yaml
name: Code Quality Sweep
on:
  schedule:
    - cron: '0 8 * * 0'  # Every Sunday at 8 AM UTC
  workflow_dispatch:

# Steps:
# 1. Checkout + setup language/runtime
# 2. Install dependencies
# 3. Run linter in check mode, capture output
# 4. Run formatter in check mode, capture output
# 5. If any issues found, create a GitHub Issue with:
#    - Title: "Code Quality: [N] issues found on [date]"
#    - Body: lint output + format output + suggested fixes
# 6. If no issues, log success
```

### 3.3 `dependency-audit.yml` — Biweekly Dependency Audit

Runs 1st and 15th of each month. Checks for outdated dependencies and known vulnerabilities. Creates a GitHub Issue if any are found.

```yaml
name: Dependency Audit
on:
  schedule:
    - cron: '0 10 1,15 * *'  # 1st and 15th at 10 AM UTC
  workflow_dispatch:

# Steps:
# 1. Checkout + setup language/runtime
# 2. Install dependencies
# 3. Check for outdated packages:
#    - npm: npm outdated --json
#    - Python: pip list --outdated --format=json
#    - Go: go list -u -m all
# 4. Check for vulnerabilities:
#    - npm: npm audit --json
#    - Python: pip-audit --format=json (or safety check)
#    - Go: govulncheck ./...
# 5. If outdated or vulnerable, create a GitHub Issue with:
#    - Vulnerability count and severity breakdown
#    - List of outdated packages with current → latest versions
#    - Recommended actions
# 6. If clean, log success
```

### 3.4 `docs-sync.yml` — Monthly Documentation Sync

Runs 1st of each month. Identifies documentation that may be out of sync with recent code changes. Creates a GitHub Issue listing stale docs.

```yaml
name: Documentation Sync Check
on:
  schedule:
    - cron: '0 9 1 * *'  # 1st of month at 9 AM UTC
  workflow_dispatch:
    inputs:
      days_back:
        description: 'Number of days to look back for changes'
        default: '30'

# Steps:
# 1. Checkout with full history (fetch-depth: 0)
# 2. Find source files changed in the last N days:
#    git log --since="N days ago" --name-only --pretty=format: -- '*.py' '*.ts' '*.go' etc.
#    Exclude test/spec files
# 3. Find documentation files (README.md, docs/**, *.md)
# 4. Compare modification dates: flag docs older than related source
# 5. If stale docs found, create a GitHub Issue with:
#    - List of potentially stale docs
#    - The source files that changed recently
#    - Suggestion to review and update
# 6. If all docs are current, log success
```

## Workflow Rules

- All workflows must use the project's REAL commands, package manager, and runtime
- Use `workflow_dispatch` on all scheduled workflows so they can also be triggered manually
- Use appropriate `concurrency` groups to avoid duplicate runs
- Pin action versions (e.g., `actions/checkout@v4`, `actions/setup-node@v4`)
- Do NOT include API keys or secrets unless the project already uses them
- Workflows should create GitHub Issues for findings, not PRs (simpler, no API key needed)

## Phase 4: Summary

```
Workflows generated:

  ✓ .github/workflows/pr-review.yml — created
  ✓ .github/workflows/code-quality.yml — created
  — .github/workflows/dependency-audit.yml — already existed, skipped
  ✓ .github/workflows/docs-sync.yml — created

Next steps:
  1. Review the generated workflows
  2. Commit the .github/workflows/ folder
  3. Workflows will activate automatically on GitHub
```
