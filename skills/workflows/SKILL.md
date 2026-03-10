---
name: workflows
description: Generate CI/CD workflows adapted to the project's stack and platform
---

# AAD Workflows — CI/CD Generator

You generate CI/CD workflows adapted to the current project's real stack, platform, and tools.

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

### 1.2 Detect existing CI/CD

Scan the project root for existing CI/CD configuration:

| Platform | Files to check |
|----------|---------------|
| GitHub Actions | `.github/workflows/*.yml` |
| Azure Pipelines | `azure-pipelines.yml`, `.azure-pipelines/`, `azure-pipelines/*.yml` |
| GitLab CI | `.gitlab-ci.yml` |
| CircleCI | `.circleci/config.yml` |
| Jenkins | `Jenkinsfile` |
| Bitbucket Pipelines | `bitbucket-pipelines.yml` |
| AWS CodePipeline | `buildspec.yml` |
| Travis CI | `.travis.yml` |

For each platform found, read the existing config files and note:
- What stages/jobs already exist (build, test, lint, deploy, etc.)
- What triggers are configured (PR, push, schedule, manual)
- What tools are already being run

## Phase 2: Present Findings & Ask User

Present what was detected:

```
Detected stack:
  Language: [detected]
  Package manager: [detected]
  Linter: [detected]
  Formatter: [detected]
  Test runner: [detected]

Existing CI/CD:
  ✓ Azure Pipelines (azure-pipelines.yml)
    - Stages: build, test, deploy
    - Triggers: PR to main, push to main
  ✓ GitHub Actions (.github/workflows/)
    - 2 existing workflows: ci.yml, deploy.yml

  (or: No CI/CD configuration found)
```

Then ask the user TWO questions:

### Question 1: Platform

```
Which CI/CD platform do you want to generate workflows for?

  1. GitHub Actions
  2. Azure Pipelines
  3. GitLab CI
  4. [other detected platform]

(Your project already uses Azure Pipelines — generating GitHub Actions
workflows would create a parallel CI/CD setup. Choose carefully.)
```

If the project already has CI/CD, warn about potential duplication.

### Question 2: Scope

```
What type of workflows do you want to generate?

  1. Quality gates — Complementary checks (lint, format, security audit, docs sync)
     These run alongside your existing CI/CD without replacing it.

  2. Full pipeline — Complete CI/CD pipeline (build, test, lint, deploy)
     This would replace or duplicate your existing pipeline.

  3. Custom — Let me describe what I want.
```

If the project already has a full pipeline (build + test + deploy), recommend option 1 (quality gates) to avoid duplication.

## Phase 3: Choose Workflow Engine

Ask the user how they want the workflows powered:

```
How should the workflows be powered?

  1. Standard — Uses your project's native tools (linters, formatters, test runners)
     No API keys needed. Workflows run your real commands directly.

  2. Claude Code — Uses anthropics/claude-code-action for AI-powered review and fixes.
     Requires: ANTHROPIC_API_KEY secret in your CI/CD platform.

  3. GitHub Copilot — Uses Copilot code review on PRs.
     Requires: Copilot enabled for your organization/repo.
     (Only available with GitHub Actions)
```

Note: Option 3 (Copilot) is only available if the user chose GitHub Actions in Phase 2.

### If the user chooses "Claude Code" (option 2):

Before generating any workflows, fetch the latest documentation:

1. Use web search to find the latest docs for `anthropics/claude-code-action` GitHub Action
2. Present the user with a setup checklist appropriate for their chosen platform:

**For GitHub Actions:**
```
Before I generate the workflows, configure your GitHub repo:

  1. Go to: https://github.com/[owner]/[repo]/settings/secrets/actions
  2. Add secret: ANTHROPIC_API_KEY (get one at https://console.anthropic.com/)
  3. Go to: https://github.com/[owner]/[repo]/settings/actions
  4. Enable: Read and write permissions + Allow creating PRs

Have you completed the setup? (yes/no)
```

**For Azure Pipelines:**
```
Before I generate the pipelines, configure your Azure DevOps project:

  1. Go to: Project Settings → Service connections or Pipelines → Library
  2. Add a variable group or secret variable: ANTHROPIC_API_KEY
  3. Ensure the pipeline has permissions to create work items/PRs

Have you completed the setup? (yes/no)
```

Adapt the checklist for the chosen platform.

If the user says **no** → remind them to complete setup and stop.
If the user says **yes** → proceed to Phase 4.

### If the user chooses "GitHub Copilot" (option 3):

1. Use web search to find the latest docs for GitHub Copilot code review in pull requests
2. Present setup checklist with links found from docs
3. Wait for user confirmation before proceeding

### If the user chooses "Standard" (option 1):

Proceed directly to Phase 4. No additional setup needed.

## Phase 4: Check Existing Workflows & Confirm

Based on the chosen platform and scope, check which workflow files already exist.

**Quality gates** (4 standard workflows):

| Workflow | GitHub Actions | Azure Pipelines | GitLab CI |
|----------|---------------|-----------------|-----------|
| PR Review | `pr-review.yml` | stage in pipeline or separate YAML | job in `.gitlab-ci.yml` |
| Code Quality | `code-quality.yml` | scheduled pipeline | scheduled pipeline |
| Dependency Audit | `dependency-audit.yml` | scheduled pipeline | scheduled pipeline |
| Docs Sync | `docs-sync.yml` | scheduled pipeline | scheduled pipeline |

Classify each as **new** or **skip** (already exists).

Present the plan:

```
Workflows to generate ([platform], [engine] mode):

  ✓ pr-review (new)
  ✓ code-quality (new)
  — dependency-audit (already exists, skip)
  ✓ docs-sync (new)

Generate the [N] new workflows? (yes/no)
```

- If ALL already exist, inform the user and stop
- If the user says **no** → stop

## Phase 5: Generate Workflows

**CRITICAL**: All generated files must be portable. Never use absolute paths. Use the project's REAL commands, package manager, and runtime.

Generate only the workflows classified as **new** (do NOT overwrite existing files).

Adapt the output format to the chosen platform:

- **GitHub Actions** → `.github/workflows/[name].yml`
- **Azure Pipelines** → YAML pipeline files (ask user where to place them)
- **GitLab CI** → Jobs in `.gitlab-ci.yml` (merge with existing if present)
- **Other** → Adapt to the platform's native config format

### Quality Gate Templates

Use these as the basis for each workflow, adapting to the chosen platform and engine:

#### PR Review
- **Trigger**: PR open/sync/reopen
- **Standard**: Run linter + formatter in check mode, run tests, report issues
- **Claude Code**: Use claude-code-action to review diff, leave comments, suggest fixes
- **Copilot**: Enable Copilot review + run linter/formatter as pre-check

#### Code Quality Sweep
- **Trigger**: Weekly (Sundays 8 AM UTC) + manual
- **Standard**: Run full lint/format check, create issue if problems found
- **Claude Code**: Claude reviews random directories, creates PR with fixes

#### Dependency Audit
- **Trigger**: Biweekly (1st and 15th) + manual
- **Standard**: Check outdated/vulnerable deps, create issue if found
- **Claude Code**: Claude updates deps conservatively, runs tests, creates PR

#### Docs Sync
- **Trigger**: Monthly (1st) + manual
- **Standard**: Find stale docs based on recent code changes, create issue
- **Claude Code**: Claude checks if docs are wrong, creates PR with fixes

### Full Pipeline Templates

If the user chose "Full pipeline" scope, also generate:

#### Build & Test
- **Trigger**: PR + push to main
- **Steps**: Install deps → lint → type-check → test → build
- Adapt all commands to the project's real tools

#### Deploy (if applicable)
- **Trigger**: Push to main (or tag)
- Ask the user about their deployment target before generating

## Workflow Rules

- All workflows must use the project's REAL commands, package manager, and runtime
- Add manual trigger capability to all scheduled workflows
- Use appropriate concurrency groups to avoid duplicate runs
- Pin action/task versions (GitHub: `actions/checkout@v4`, Azure: `task@version`)
- Do NOT hardcode API keys — always use platform secrets
- Standard mode: create issues for findings (no API key needed)
- Claude Code mode: can create PRs with fixes (requires ANTHROPIC_API_KEY)
- Never generate workflows that duplicate existing CI/CD jobs — warn the user instead

## Phase 6: Summary

```
Workflows generated ([platform], [engine] mode):

  ✓ pr-review — created
  ✓ code-quality — created
  — dependency-audit — already existed, skipped
  ✓ docs-sync — created

Next steps:
  1. Review the generated workflows
  2. Commit the workflow files
  3. [Platform-specific activation instructions]
```
