---
name: workflows
description: Generate GitHub Actions workflows powered by Claude Code or GitHub Copilot
disable-model-invocation: true
---

# AAD Workflows — GitHub Actions Generator

You generate GitHub Actions workflows adapted to the current project's real stack and tools, powered by Claude Code or GitHub Copilot.

**IMPORTANT**: This is an interactive flow. You MUST follow each phase in order and WAIT for the user's response before proceeding to the next phase. Do NOT generate any files until the user has made all their selections.

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

### 1.2 Detect repository info

Read the Git remote to determine the `owner` and `repo` name:

```bash
git remote get-url origin
```

Extract `OWNER` and `REPO` from the URL. Also determine the default branch (`main` or `develop` — check what exists).

### 1.3 Check existing workflows

Check which of the 4 standard workflow files already exist in `.github/workflows/`. For each name, check BOTH formats:
- `.yml` (traditional) — e.g., `pr-review.yml`
- `.md` (gh-aw agentic) — e.g., `pr-review.md`
- `.lock.yml` (compiled gh-aw) — e.g., `pr-review.lock.yml`

Workflow names to check:
- `pr-review`
- `code-quality`
- `dependency-audit`
- `docs-sync`

Classify each as **new** (no file in any format) or **skip** (file already exists in any format).

## Phase 2: Choose Engine

**STOP and ask the user.** Present this prompt and WAIT for their response:

```
How should the GitHub Actions workflows be powered?

  1. Claude Code — Uses anthropics/claude-code-action for AI-powered review and fixes.
     Requires: ANTHROPIC_API_KEY secret in your GitHub repo.

  2. GitHub Copilot (Agentic Workflows) — Uses gh-aw with Copilot as the AI engine.
     Requires: Copilot enabled for your organization/repo + gh-aw CLI.
     Workflows are written in Markdown and compiled to .lock.yml files.

Choose (1/2):
```

Do NOT proceed until the user responds.

### If the user chooses "Claude Code":

Before generating any workflows, fetch the latest documentation:

1. Use web search to find the latest docs for `anthropics/claude-code-action` GitHub Action
2. **STOP and present** the user with a setup checklist. WAIT for their response:

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

1. Use web search to find the latest docs for GitHub Agentic Workflows (`gh-aw`)
2. **STOP and present** setup checklist. WAIT for user confirmation:

```
Before I generate the workflows, ensure your repo is set up for GitHub Agentic Workflows:

  1. Install the gh-aw CLI extension:
     gh extension install github/gh-aw

  2. Initialize your repo (if not already done):
     gh aw init

  3. Go to: https://github.com/[owner]/[repo]/settings/actions
  4. Under "Workflow permissions", enable:
     ✓ Read and write permissions
     ✓ Allow GitHub Actions to create and approve pull requests

  5. Ensure Copilot is enabled for your organization/repo

  Docs: [URL found from web search]

Have you completed the setup? (yes/no)
```

If the user says **no** → remind them to complete setup and stop.
If the user says **yes** → proceed to Phase 3.

## Phase 3: Select Workflows

**STOP and ask the user.** Present the list of available workflows and WAIT for their selection:

```
Detected stack:
  Language: [detected]
  Package manager: [detected]
  Linter: [detected]
  Formatter: [detected]
  Test runner: [detected]

Engine: [Claude Code / GitHub Copilot (gh-aw)]

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
- Do NOT proceed until the user responds.

## Phase 4: Generate Workflows

**Only now generate files.** Generate only the workflows the user selected.

**CRITICAL**: All generated files must be portable. Never use absolute paths. Use the project's REAL commands, package manager, and runtime. Replace `[OWNER]`, `[REPO]`, and `[DEFAULT_BRANCH]` with the actual values detected in Phase 1.2.

---

### Claude Code Engine

Output to `.github/workflows/[name].yml`. Use `anthropics/claude-code-action@beta` for all workflows. Fetch the latest documentation to determine the current recommended version and configuration options.

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

---

### GitHub Copilot Engine (gh-aw Agentic Workflows)

Output to `.github/workflows/[name].md` — Markdown files with YAML frontmatter that compile to `.lock.yml` via `gh aw compile`.

Each workflow file follows this structure:

```markdown
---
name: Workflow Name
description: What this workflow does
on:
  [triggers]
permissions:
  [minimal permissions needed]
engine: copilot
strict: true
network:
  allowed:
    - defaults
    - github
safe-outputs:
  [create-pull-request or create-issue configuration]
tools:
  github:
    toolsets: [default]
  edit:
  bash:
    - [project-specific allowed commands]
timeout-minutes: [appropriate timeout]
---

# Workflow Title

Natural language prompt telling Copilot what to do.
The prompt should be detailed, specific, and reference the project's real tools.
```

#### PR Review (`pr-review.md`)

**Frontmatter:**
- **Trigger**: `pull_request: types: [opened, synchronize, reopened]`
- **Permissions**: `contents: read`, `pull-requests: write`
- **safe-outputs**: None needed (Copilot reviews directly on the PR)
- **Tools**: `github` (toolsets: [default]), `bash` with linter/formatter commands
- **Timeout**: 15 minutes

**Prompt content** — Tell Copilot to:
- Review the PR diff for code quality, bugs, security issues, and adherence to project conventions
- Run the project's linter/formatter as a pre-check (use the REAL commands)
- Leave specific, actionable review comments on problematic lines
- Categorize findings as Critical / Warning / Suggestion
- Reference the project's conventions and patterns

#### Code Quality (`code-quality.md`)

**Frontmatter:**
- **Trigger**: `schedule: - cron: weekly` + `workflow_dispatch`
- **Permissions**: `contents: read`, `pull-requests: read`
- **safe-outputs**: `create-pull-request` with labels `[code-quality, automated]`, `expires: 1d`
- **Tools**: `github` (toolsets: [default]), `edit`, `bash` with lint/format/test commands + `git:*`
- **Timeout**: 45 minutes

**Prompt content** — Tell Copilot to:
- Scan the codebase for code quality issues beyond what linters catch
- Look for: logic errors, missing error handling, security concerns, dead code, type violations, anti-patterns
- FIX the issues (not just report them) using the `edit` tool
- Run the project's linter/formatter after fixes to verify
- Run tests to ensure fixes don't break anything
- Stage, commit, and create a PR via `safeoutputs-create_pull_request`
- If no issues found, call `safeoutputs-noop`

#### Dependency Audit (`dependency-audit.md`)

**Frontmatter:**
- **Trigger**: `schedule: - cron: "0 9 1,15 * *"` + `workflow_dispatch`
- **Permissions**: `contents: read`, `pull-requests: read`
- **safe-outputs**: `create-pull-request` with labels `[dependencies, automated]`, `expires: 1d`
- **Tools**: `github` (toolsets: [default]), `edit`, `bash` with package manager commands + `git:*`
- **Timeout**: 60 minutes

**Prompt content** — Tell Copilot to:
- Check for outdated and vulnerable dependencies using the project's native tools
- Conservatively update packages (patch/minor versions only, skip major unless critical security fix)
- After each update, run lint and tests to verify nothing breaks
- If an update breaks tests, revert it and move on
- Stage, commit, and create a PR with a summary of what was updated and why
- If no updates needed, call `safeoutputs-noop`

#### Docs Sync (`docs-sync.md`)

**Frontmatter:**
- **Trigger**: `schedule: - cron: monthly` + `workflow_dispatch`
- **Permissions**: `contents: read`, `pull-requests: read`
- **safe-outputs**: `create-pull-request` with labels `[documentation, automated]`, `expires: 1d`
- **Tools**: `github` (toolsets: [default]), `edit`, `bash` with `git:*`, `find`, `grep`, `cat`
- **Timeout**: 45 minutes

**Prompt content** — Tell Copilot to:
- Find source code files changed in the last 30 days using `git log`
- Check if related documentation is WRONG (not merely missing)
- Read the actual doc files and compare with current code behavior
- Fix genuinely broken/outdated documentation using the `edit` tool
- Do NOT create documentation for undocumented features — only fix existing docs that are incorrect
- Stage, commit, and create a PR if problems were found
- If all docs are accurate, call `safeoutputs-noop`

#### Sandbox awareness

Each Copilot workflow prompt MUST include a sandbox awareness section explaining:
- The workspace is a shallow clone — use `github-get_file_contents(ref="[DEFAULT_BRANCH]")` to read files from the default branch
- `mkdir -p` is needed before `create` tool to ensure parent directories exist
- `git add` + `git commit` is REQUIRED before calling `safeoutputs-create_pull_request`
- `git config user.email` and `git config user.name` must be set before committing
- Network operations (`curl`, `wget`, `git push`) are blocked by the firewall

---

## Workflow Rules

**Common to both engines:**
- All workflows must use the project's REAL commands, package manager, and runtime
- Add `workflow_dispatch` to all scheduled workflows for manual trigger
- Use appropriate `concurrency` groups to avoid duplicate runs
- Do NOT hardcode API keys — always use `${{ secrets.* }}`

**Claude Code specific:**
- Pin action versions (e.g., `actions/checkout@v4`, `actions/setup-node@v4`)
- Workflows create PRs with fixes via claude-code-action

**Copilot (gh-aw) specific:**
- Use `engine: copilot` and `strict: true`
- Use `safe-outputs` for structured output (create-pull-request, create-issue, noop)
- Define minimal `tools` with explicit bash allowlists
- Configure `network: allowed: [defaults, github]`
- Prompts must include sandbox awareness section
- Files are `.md` and need compilation via `gh aw compile`

## Phase 5: Summary

Display a summary table showing ALL available workflows with their final status:

```
AAD Workflows Summary (GitHub Actions, [engine] mode)

| Workflow         | Status    | File                                      | Reason              |
|------------------|-----------|-------------------------------------------|---------------------|
| PR Review        | ✓ Created | .github/workflows/pr-review.[yml/md]      |                     |
| Code Quality     | ✓ Created | .github/workflows/code-quality.[yml/md]   |                     |
| Dependency Audit | — Skipped | .github/workflows/dependency-audit.[ext]  | Already exists      |
| Docs Sync        | — Skipped | —                                         | Not selected by user|
```

**Status values:**
- `✓ Created` — file was generated
- `— Skipped` — not generated, with reason

**Skip reasons** (use the one that applies):
- `Already exists` — file already present, not overwritten
- `Not selected by user` — user chose not to generate this workflow

Then show next steps:

**If Claude Code:**
```
Next steps:
  1. Review the generated workflows in .github/workflows/
  2. Commit the .github/workflows/ folder
  3. Workflows will activate automatically on GitHub
```

**If GitHub Copilot (gh-aw):**
```
Next steps:
  1. Review the generated .md workflow files in .github/workflows/
  2. Compile to lock files: gh aw compile
  3. Commit both the .md and .lock.yml files
  4. Workflows will activate automatically on GitHub
```
