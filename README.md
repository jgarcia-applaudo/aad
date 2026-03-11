# AAD — Applaudo Agentic Development

A plugin that configures your AI coding agent as an expert development companion for any project, regardless of the stack.

AAD analyzes your project's stack, conventions, and tooling, then generates tailored configuration so your agent understands your codebase from day one.

**Supports both Claude Code and GitHub Copilot** from a single plugin.

## What's Included

| Type | Name | Description |
|------|------|-------------|
| Skill | `setup` | Detects your stack and generates all project configuration |
| Skill | `workflows` | Generates agentic GitHub Actions workflows (Claude Code or Copilot) |
| Skill | `code-quality` | Runs a code quality analysis beyond what linters catch |
| Skill | `pr-review` | Reviews a Pull Request with categorized findings |
| Skill | `pr-summary` | Generates a structured PR summary |
| Skill | `onboard` | Explores the codebase to understand a task before coding |
| Skill | `ticket` | End-to-end workflow: from ticket to PR |
| Skill | `docs-sync` | Finds and fixes outdated documentation |
| Agent | `code-reviewer` | Senior code reviewer with structured output |
| Agent | `github-workflow` | Git/GitHub conventions enforcer |

> In Claude Code, skills are available as `/aad:*` slash commands (e.g., `/aad:setup`).

## Installation

Clone the repo to a shared location:

```bash
git clone https://github.com/jgarcia-applaudo/aad.git ~/.local/share/agent-plugins/aad
```

### Claude Code

Inside Claude Code:

```bash
/plugin marketplace add ~/.local/share/agent-plugins/aad
/plugin install aad
```

### GitHub Copilot (VS Code)

Register the plugin in your VS Code settings:

```json
{
  "chat.pluginLocations": {
    "~/.local/share/agent-plugins/aad": true
  }
}
```

Or if published to a marketplace repository:

```bash
copilot plugin install aad@applaudo/aad
```

#### Windows + WSL

If you develop inside WSL with VS Code and the **Remote - WSL** extension, follow these steps:

1. Clone the plugin inside the WSL filesystem (not the Windows filesystem):

   ```bash
   git clone https://github.com/jgarcia-applaudo/aad.git ~/.local/share/agent-plugins/aad
   ```

2. Open VS Code settings for the **remote** environment — not the local Windows settings.
   Use the command palette: `Preferences: Open Remote Settings (JSON)` and add:

   ```json
   {
     "chat.pluginLocations": {
       "~/.local/share/agent-plugins/aad": true
     }
   }
   ```

   > If you add this to your local (Windows) settings instead of Remote settings, VS Code will not find the plugin.

3. Reload the VS Code window (`Developer: Reload Window`).

**Known limitations in WSL:** There are active VS Code bugs that may affect skill loading:

- Skills files located outside the current workspace may not load ([microsoft/vscode#292297](https://github.com/microsoft/vscode/issues/292297)).
- Copilot Chat may become unresponsive after switching to a WSL remote ([microsoft/vscode#253610](https://github.com/microsoft/vscode/issues/253610)).

If skills are not available after installation, try opening a workspace inside the WSL filesystem (e.g., `code .` from a WSL terminal) and reload the window.

### Update

```bash
cd ~/.local/share/agent-plugins/aad && git pull
```

Agents and skills take effect immediately — no reinstall needed. If the `setup` skill was updated, re-run it in your project to regenerate configuration files (existing settings are preserved and merged).

### Initialize in your project

Navigate to your project and run the setup skill:

- **Claude Code**: `/aad:setup`
- **Copilot**: Use the `setup` skill from the AAD plugin in chat

This will:

1. Detect which agent you're using (Claude Code or Copilot)
2. Scan your project for languages, frameworks, test runners, linters, etc.
3. Show you a summary of what was detected
4. After confirmation, generate agent-specific files:

| Generated file | Claude Code | GitHub Copilot |
|----------------|-------------|----------------|
| Project config | `CLAUDE.md` | `.github/copilot-instructions.md` |
| Hooks | `.claude/settings.json` | `.github/hooks/*.json` |
| Domain skills | `.claude/skills/*/SKILL.md` | `.github/instructions/*.instructions.md` |

---

## Usage & Examples

### `setup`

Run once per project. Analyzes your stack and generates all configuration files so your agent knows how to work with your codebase.

**Claude Code:**

```
> /aad:setup
```

**Copilot:** Use the `setup` skill from the AAD plugin in Copilot chat.

**What happens:**

```
Detected stack:
  Language: TypeScript
  Framework: Next.js 14 (App Router)
  Testing: Vitest + React Testing Library
  Linter: ESLint + Prettier
  State: Zustand
  ORM: Prisma (PostgreSQL)

Files to be created:
  ✓ CLAUDE.md (new)
  ✓ .claude/settings.json (new)
  ✓ .claude/skills/testing-patterns/SKILL.md
  ✓ .claude/skills/systematic-debugging/SKILL.md
  ✓ .claude/skills/ui-patterns/SKILL.md
  ✓ .claude/skills/api-patterns/SKILL.md
  ✓ .claude/skills/db-patterns/SKILL.md
  ✓ .claude/skills/state-patterns/SKILL.md
  ✓ .claude/.gitignore

Confirm installation?
```

After confirmation, the agent generates configuration tailored to your real stack — including project-specific commands, conventions, and hooks.

**Re-running on an existing project:** If configuration files already exist, `setup` reads them first and merges new sections without overwriting your customizations.

---

### `onboard`

Explore the codebase before starting a task. Reads relevant code, identifies files you'll need to touch, and proposes an approach — **without making any changes**.

**Claude Code:**

```
> /aad:onboard add dark mode support to the settings page
```

```
> /aad:onboard migrate the user API from REST to tRPC
```

```
> /aad:onboard fix the race condition in the checkout flow
```

**Copilot:** Use the `onboard` skill with your task description.

**Example output:**

```
## Task Context
Add dark mode toggle to the settings page. The app uses Tailwind CSS with
a custom theme system defined in tailwind.config.ts.

## Relevant Files
- src/app/settings/page.tsx — Settings page component (entry point)
- src/components/ui/ThemeProvider.tsx — Existing theme context (light only)
- src/stores/preferences.ts — Zustand store for user preferences
- tailwind.config.ts — Theme configuration
- src/app/globals.css — CSS variables for theming

## Proposed Approach
1. Extend ThemeProvider to support dark/light/system modes
2. Add a `theme` field to the preferences store
3. Create a ThemeToggle component using existing UI patterns
4. Update globals.css with dark mode CSS variables
5. Add the toggle to the settings page

## Questions
- Should dark mode persist to the database or only localStorage?
- Should it respect the OS preference by default?
```

The agent then waits for your confirmation before doing anything.

---

### `ticket`

Full end-to-end workflow: from a ticket to a finished PR. Creates a branch, implements changes, runs tests, and opens a PR.

**Claude Code:**

```
# From a Jira ticket
> /aad:ticket PROJ-1234

# From a GitHub issue
> /aad:ticket https://github.com/org/repo/issues/42

# From a GitHub issue number
> /aad:ticket #42

# From a Linear ticket
> /aad:ticket ENG-567

# From a plain description
> /aad:ticket add rate limiting to the /api/auth endpoints
```

**Copilot:** Use the `ticket` skill with the ticket reference.

**What the agent does:**

1. Fetches ticket details (from Jira, Linear, or GitHub Issues via MCP or CLI)
2. Explores the codebase to understand the context
3. Creates a feature branch (e.g., `feature/PROJ-1234-rate-limiting`)
4. Implements the changes following project conventions
5. Writes tests for the new code
6. Runs lint, tests, and type-check to verify everything passes
7. Creates a PR with a structured summary using `gh pr create`
8. Optionally updates the ticket status if MCP access is available

---

### `workflows`

Generates **agentic** GitHub Actions workflows — where an AI agent autonomously reviews code, fixes issues, and creates PRs inside GitHub Actions.

**Claude Code:**

```
> /aad:workflows
```

**Copilot:** Use the `workflows` skill from the AAD plugin.

**Interactive flow:**

**Step 1** — Choose the AI engine:

```
Which AI engine should power the workflows?

  1. Claude Code — Uses anthropics/claude-code-action@beta.
     Format: .yml files with prompt: field.
     Requires: ANTHROPIC_API_KEY secret in your GitHub repo.

  2. GitHub Copilot — Uses gh-aw (GitHub Agentic Workflows).
     Format: .md files (Markdown + prompt) compiled to .lock.yml.
     Requires: Copilot enabled for your org/repo + gh-aw CLI.

Choose (1/2):
```

**Step 2** — Configure secrets (depends on engine choice).

**Step 3** — Select which workflows to generate:

```
Available workflows:
  1. [new]  PR Review         — AI-powered code review on pull requests
  2. [new]  Code Quality      — Weekly code quality sweep
  3. [new]  Dependency Audit   — Biweekly dependency audit
  4. [new]  Docs Sync         — Monthly documentation sync check

Which workflows do you want to generate? (e.g., "1,2,4" or "all new")
```

**Generated workflows:**

| Workflow | Trigger | What it does |
|----------|---------|--------------|
| PR Review | PR open/sync/reopen | Reviews diffs for bugs, security issues, convention violations |
| Code Quality | Weekly + manual | Scans for issues linters miss, fixes them, creates a PR |
| Dependency Audit | Biweekly + manual | Updates outdated/vulnerable deps (patch/minor), creates a PR |
| Docs Sync | Monthly + manual | Fixes documentation that is wrong, creates a PR |

**Claude Code format** generates `.yml` files using `anthropics/claude-code-action@beta`.
**Copilot format** generates `.md` files that compile to `.lock.yml` via `gh aw compile`.

---

### `code-quality`

Analyzes your codebase for issues that linters miss: logic errors, missing error handling, security concerns, dead code, and more.

**Claude Code:**

```
> /aad:code-quality
```

**Copilot:** Use the `code-quality` skill.

**What it does:**

1. Runs your project's lint and type-check commands
2. Manually scans source files for deeper issues
3. Cross-references against project domain skills/instructions

**Example output:**

```
## Critical (requires immediate fix)
- src/api/users.ts:45 — SQL query built with string concatenation.
  Use parameterized queries to prevent SQL injection.
- src/auth/session.ts:12 — JWT secret read from process.env without
  fallback. Server crashes if SECRET_KEY is not set.

## Warning (should be fixed)
- src/hooks/useAuth.ts:38 — Promise rejected without .catch().
  Unhandled rejections can crash the app in strict mode.
- src/utils/cache.ts:67 — Cache TTL hardcoded to 3600. Should use
  config constant for consistency with other caches.

## Suggestion (optional improvement)
- src/components/DataTable.tsx:120-145 — Filter logic duplicated
  from src/components/SearchBar.tsx:30-55. Consider extracting
  a shared filtering utility.

## Summary
- 47 files analyzed
- 2 critical issues
- 2 warnings
- 1 suggestion
```

---

### `pr-review`

Reviews a Pull Request against your project's standards. Posts categorized findings directly as PR comments.

**Claude Code:**

```
# Review a specific PR
> /aad:pr-review 42

# Review the PR for the current branch
> /aad:pr-review
```

**Copilot:** Use the `pr-review` skill, optionally with the PR number.

**What it does:**

1. Fetches the PR diff and metadata via `gh`
2. Loads the `code-reviewer` agent and project conventions
3. Reviews every change for correctness, security, conventions, and test coverage
4. Posts comments on the PR grouped by severity:

```
[CRITICAL] src/api/payments.ts:89
Amount calculation uses floating point arithmetic. Use a decimal
library (e.g., decimal.js) for monetary calculations to avoid
rounding errors.

[WARNING] src/api/payments.ts:102
Missing error handling for the Stripe API call. If the charge
fails, the order status remains "processing" indefinitely.
Suggested fix: wrap in try/catch and set status to "failed".

[SUGGESTION] src/api/payments.ts:115
Consider extracting the retry logic into a shared utility —
the same pattern exists in src/api/subscriptions.ts:45.
```

---

### `pr-summary`

Generates a structured summary for the current branch's PR with Summary, Changes, and Test Plan sections.

**Claude Code:**

```
> /aad:pr-summary
```

**Copilot:** Use the `pr-summary` skill.

**Example output:**

```markdown
## Summary
- Add rate limiting middleware to all authenticated API endpoints
- Implement sliding window algorithm using Redis for distributed rate tracking

## Changes
- **Middleware**: New `rateLimit.ts` middleware with configurable
  limits per endpoint group (auth: 10/min, api: 100/min, uploads: 5/min)
- **Config**: Added `RATE_LIMIT_*` env variables to `.env.example`
- **Tests**: Added integration tests for rate limiting with Redis mock
- **Docs**: Updated API documentation with rate limit headers

## Test plan
- [ ] Verify rate limiting kicks in after threshold (10 requests to /auth)
- [ ] Verify rate limit headers (X-RateLimit-Remaining) are present
- [ ] Verify different limits apply to different endpoint groups
- [ ] Verify Redis connection failure falls back gracefully
```

If there's an open PR for the current branch, the agent offers to update the PR description automatically via `gh pr edit`.

---

### `docs-sync`

Finds documentation that has fallen out of sync with recent code changes and fixes **only verifiable inconsistencies** — it does not add docs for undocumented features.

**Claude Code:**

```
> /aad:docs-sync
```

**Copilot:** Use the `docs-sync` skill.

**What it does:**

1. Identifies source files changed in the last 30 days
2. Finds related documentation (READMEs, markdown files, docstrings, API schemas)
3. Compares docs with current code to find real errors
4. Fixes incorrect documentation

**Example output:**

```
## Documentation Updated
- docs/api/authentication.md — Updated the /auth/login endpoint
  signature: added the `mfaToken` parameter (added in commit abc123)
- src/utils/cache.ts — Fixed JSDoc for `invalidate()`: parameter
  was renamed from `key` to `pattern` in v2.1

## No Changes Needed
- README.md — up to date
- docs/deployment.md — up to date

## Summary
- 8 doc files reviewed
- 2 corrections made
```

---

## Agents

AAD includes two specialized agents that work in both Claude Code and GitHub Copilot:

### `code-reviewer`

A senior code reviewer agent that evaluates changes for correctness, security, conventions, and test coverage. Used internally by the `pr-review` skill and available for direct use.

**Evaluation criteria:**
- **Correctness**: Logic errors, unhandled edge cases, race conditions
- **Security**: Unsanitized inputs, hardcoded secrets, injection vulnerabilities
- **Conventions**: Naming, patterns, consistency with existing code
- **Testing**: Coverage, edge cases, readability of tests

**Output format:**

```
[CRITICAL] file:line — Description. Suggested fix.
[WARNING]  file:line — Description. Suggested fix.
[SUGGESTION] file:line — Description.
```

### `github-workflow`

A Git and GitHub conventions enforcer. Ensures branches, commits, and PRs follow the project's standards (or sensible defaults).

**Enforces:**
- Branch naming: `feature/`, `fix/`, `refactor/`, `docs/`
- Commit messages: Conventional Commits format (`feat:`, `fix:`, `docs:`, etc.)
- PR structure: concise title (< 70 chars), Summary + Changes + Test Plan
- Pre-PR checklist: correct branch, clean lint, passing tests, no unwanted files

---

## Built-in Protections

AAD includes hooks that activate automatically after running `setup`:

### Branch Protection

Blocks edits on `main`/`master` and prompts you to create a feature branch.

```
⚠ You are on the main branch. Create a feature branch first.
```

**How it works:** A `PreToolUse` hook runs before every `Edit` or `Write` operation, checks the current git branch, and blocks the action if you're on a protected branch.

### Auto-Formatting

Runs the project's formatter after every file edit. Detects which formatter to use based on your project:

| Detected tool | Command |
|---------------|---------|
| Biome | `npx biome format --write` |
| Prettier | `npx prettier --write` |
| Ruff (Python) | `ruff format` |
| Black (Python) | `black` |
| gofmt (Go) | `gofmt -w` |
| rustfmt (Rust) | `rustfmt` |

### Additional Hooks (generated by `setup`)

When you run `setup`, the agent generates project-specific hooks beyond the two defaults:

| Hook | What it does |
|------|-------------|
| Auto-lint fix | Runs linter with auto-fix after edits (ESLint `--fix`, Ruff `--fix`, etc.) |
| Auto-install deps | Re-installs dependencies if `package.json` or `requirements.txt` changes |
| Auto-run tests | Runs related tests when test files are edited |
| Type-check | Validates types after edits (TypeScript `tsc --noEmit`, Python `mypy`) |

> **Note**: In GitHub Copilot, hooks are only available in the CLI, not in VS Code.

---

## Compatibility

| Feature | Claude Code | Copilot VS Code | Copilot CLI |
|---------|-------------|-----------------|-------------|
| Agents | Yes | Yes | Yes |
| Skills / Slash commands | Yes (`/aad:*`) | Yes | Yes |
| Hooks (branch protection) | Yes | No | Yes |
| Hooks (auto-format) | Yes | No | Yes |
| Setup (dynamic generation) | Yes | Yes | Yes |

---

## Project Structure

```text
aad/
├── .claude-plugin/
│   ├── marketplace.json          # Claude Code marketplace registration
│   └── plugin.json               # Claude Code plugin manifest
├── .github/
│   └── plugin.json               # GitHub Copilot plugin manifest
├── agents/
│   ├── code-reviewer.agent.md    # Shared — works in both agents
│   └── github-workflow.agent.md  # Shared — works in both agents
├── hooks/
│   ├── branch-protection.json    # Reference hook for branch protection
│   └── auto-format.json          # Reference hook for auto-formatting
├── skills/                       # Single source of truth for both agents
│   ├── setup/SKILL.md            # Detects agent and adapts output
│   ├── workflows/SKILL.md        # GitHub Actions generator
│   ├── code-quality/SKILL.md
│   ├── pr-review/SKILL.md
│   ├── pr-summary/SKILL.md
│   ├── onboard/SKILL.md
│   ├── ticket/SKILL.md
│   └── docs-sync/SKILL.md
├── settings.json                 # Default Claude Code settings with hooks
└── README.md
```
