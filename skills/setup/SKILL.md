---
name: setup
description: Initialize Applaudo Agentic Development configuration in the current project
disable-model-invocation: true
---

# AAD Init — Smart Project Configuration

You are the AAD (Applaudo Agentic Development) plugin installer. Your job is to analyze the current project and generate all necessary configuration so that the AI coding agent works as an expert development companion for this specific project.

## Phase 0: Detect Agent

Determine which AI coding agent is executing this skill:

1. Check environment: If `INSIDE_CLAUDE_CODE=1` is set → **Claude Code**
2. If not, ask the user: "Which agent are you using? (Claude Code / GitHub Copilot)"

Store the result as AGENT_TYPE for use in all subsequent phases.

### File path mapping

Use these paths throughout Phases 1-4 based on the detected agent:

| Concept             | Claude Code                  | GitHub Copilot                                          |
|---------------------|------------------------------|---------------------------------------------------------|
| Project config file | `CLAUDE.md`                  | `.github/copilot-instructions.md`                       |
| Settings/hooks      | `.claude/settings.json`      | `.github/hooks/*.json`                                  |
| Domain skills       | `.claude/skills/*/SKILL.md`  | `.github/instructions/*.instructions.md` (with applyTo) |

## Phase 1: Project Detection

### 1.1 Scan existing configuration files

Read the following files if they exist (do not fail if they don't):

- `package.json`, `package-lock.json`, `yarn.lock`, `pnpm-lock.yaml`
- `tsconfig.json`, `jsconfig.json`
- `pyproject.toml`, `setup.py`, `requirements.txt`, `Pipfile`
- `go.mod`, `go.sum`
- `Cargo.toml`
- `Gemfile`
- `build.gradle`, `pom.xml`
- `.eslintrc*`, `.prettierrc*`, `biome.json`
- `vite.config.*`, `webpack.config.*`, `next.config.*`, `nuxt.config.*`
- `docker-compose.yml`, `Dockerfile`
- `.env.example`

Also scan for existing agent-specific files:

- `CLAUDE.md` (Claude Code)
- `.github/copilot-instructions.md` (Copilot)
- `.claude/settings.json` (Claude Code)
- `.github/hooks/` (Copilot)
- `.claude/skills/` (Claude Code)
- `.github/instructions/` (Copilot)

### 1.2 Scan project structure

Run `ls` at the root and in key folders (`src/`, `app/`, `lib/`, `test/`, `tests/`, `__tests__/`) to understand the structure.

### 1.3 Infer stack

From what was detected, determine:

- **Primary language(s)** (TypeScript, JavaScript, Python, Go, Rust, Java, Ruby, etc.)
- **Framework** (React, Vue, Angular, Next.js, Nuxt, Django, FastAPI, Flask, Gin, etc.)
- **Test runner** (Jest, Vitest, Pytest, Go test, etc.)
- **Linter/Formatter** (ESLint, Prettier, Biome, Ruff, Black, golangci-lint, etc.)
- **State management** (if applicable: Redux, Zustand, Pinia, Jotai, etc.)
- **API/Data** (REST, GraphQL, tRPC, gRPC, etc.)
- **Forms** (if applicable: React Hook Form, Formik, VeeValidate, etc.)
- **Monorepo** (if applicable: Turborepo, Nx, Lerna, pnpm workspaces)
- **Database** (if detectable: PostgreSQL, MySQL, MongoDB, SQLite, etc.)
- **ORM** (if applicable: Prisma, Drizzle, SQLAlchemy, GORM, etc.)
- **CI/CD** (GitHub Actions, GitLab CI, etc.)
- **Key commands** (build, test, lint, dev — extract from scripts in package.json or equivalent)

### 1.4 Check existing files

Before generating any file, check if the project config file already exists (based on AGENT_TYPE):

**If Claude Code:**

- If `CLAUDE.md` already exists — read it completely, preserve its content, and propose integrations without losing anything
- If `.claude/settings.json` already exists — read it, merge hooks without duplicating or overwriting
- If `.claude/skills/*` already exist — list them, do not overwrite, ask whether to update

**If Copilot:**

- If `.github/copilot-instructions.md` already exists — read it completely, preserve its content, and propose integrations without losing anything
- If `.github/hooks/` already exists — read existing hooks, merge without duplicating or overwriting
- If `.github/instructions/*` already exist — list them, do not overwrite, ask whether to update

In both cases: If `.github/workflows/*` already exist — do not touch existing ones.

## Phase 2: User Confirmation

Present a summary of what was detected. Use the correct paths based on AGENT_TYPE:

**If Claude Code:**

```
Detected stack:
  Language: [detected]
  Framework: [detected]
  Testing: [detected]
  Linter: [detected]
  ...

Files to be created:
  ✓ CLAUDE.md (new / merge with existing)
  ✓ .claude/skills/testing-patterns/SKILL.md
  ✓ .claude/skills/debugging/SKILL.md
  ✓ .claude/skills/[other relevant]/SKILL.md
  ✓ .claude/settings.json (new / merge with existing)

  ✓ .github/workflows/ (CI/CD workflows)        ← only if .github/ exists
  ? .github/workflows/ (generate CI/CD workflows?) ← only if .github/ does NOT exist

Confirm installation?
```

**If Copilot:**

```
Detected stack:
  Language: [detected]
  Framework: [detected]
  Testing: [detected]
  Linter: [detected]
  ...

Files to be created:
  ✓ .github/copilot-instructions.md (new / merge with existing)
  ✓ .github/instructions/testing-patterns.instructions.md
  ✓ .github/instructions/debugging.instructions.md
  ✓ .github/instructions/[other relevant].instructions.md
  ✓ .github/hooks/branch-protection.json (new / merge with existing)
  ✓ .github/hooks/auto-format.json (new / merge with existing)
  ✓ .github/workflows/ (CI/CD workflows)        ← only if .github/ exists
  ? .github/workflows/ (generate CI/CD workflows?) ← only if .github/ does NOT exist

Confirm installation?
```

Only ask about what you could NOT infer. If everything is clear, request a simple confirmation.

## Phase 3: File Generation

**CRITICAL**: All generated files must be portable. Never use absolute paths (e.g., `/Users/john/projects/...`). Use only relative paths or tool names without paths. Generated configuration must work on any machine that clones the repository.

### 3.1 Project configuration file

Generate the project configuration file at the path determined by AGENT_TYPE:

- **Claude Code**: `CLAUDE.md` at the project root
- **Copilot**: `.github/copilot-instructions.md`

The content is the same for both agents:

```markdown
# [Project Name]

## Stack
[Detected real stack with versions if available]

## Commands
[Real project commands: build, test, lint, dev, etc.]

## Code Conventions
[Inferred from existing code and linter configs — import style, naming conventions, etc.]

## Git Conventions
[Branch naming, commit format — ask if not inferable]

## Critical Rules
[Stack-specific rules — e.g.: no `any` in TypeScript, error handling, etc.]
```

If the configuration file already exists, integrate missing sections without modifying existing content.

### 3.2 Domain Skills

Generate domain skills adapted to the project's real stack. The content is the same for both agents — only the file format and location differ.

**Skills to generate based on detected stack:**

| Skill                  | Generate when                      |
|------------------------|------------------------------------|
| `testing-patterns`     | Always — adapt to detected runner  |
| `systematic-debugging` | Always — adapt to language & tools |
| `ui-patterns`          | Frontend framework detected        |
| `api-patterns`         | API/data layer detected            |
| `form-patterns`        | Forms library detected             |
| `state-patterns`       | State management detected          |
| `db-patterns`          | Database / ORM detected            |

Each skill must:

- Contain instructions specific to the project's real technologies
- Include patterns, anti-patterns, and examples based on existing code when possible
- Reference the project's real tools and libraries

**If Claude Code** — generate as `.claude/skills/[name]/SKILL.md`:

```yaml
---
name: [skill-name]
description: [description specific to the project's stack]
---
```

Followed by the skill content in Markdown.

**If Copilot** — generate as `.github/instructions/[name].instructions.md`:

```yaml
---
applyTo: "[glob pattern for relevant files]"
---
```

Followed by the same skill content in Markdown.

Use these `applyTo` patterns per skill type:

| Skill                  | applyTo                                                              |
|------------------------|----------------------------------------------------------------------|
| `testing-patterns`     | `**/*.test.*,**/*.spec.*,**/test/**,**/tests/**,**/__tests__/**`     |
| `systematic-debugging` | `**/*`                                                               |
| `ui-patterns`          | `**/*.tsx,**/*.vue,**/*.svelte,**/components/**`                     |
| `api-patterns`         | `**/api/**,**/routes/**,**/controllers/**,**/handlers/**`            |
| `form-patterns`        | `**/*form*,**/*Form*`                                                |
| `state-patterns`       | `**/store/**,**/stores/**,**/state/**`                               |
| `db-patterns`          | `**/models/**,**/migrations/**,**/prisma/**,**/drizzle/**`           |

### 3.3 Settings and Hooks

**If Claude Code** — generate `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "prompt",
            "prompt": "If the current branch is main or master, warn the user that they should work on a feature branch."
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "[real project format command — e.g.: npx prettier --write $FILE or ruff format $FILE]. IMPORTANT: Use only relative paths or no paths at all. Never use absolute paths — the settings file must be portable across machines."
          }
        ]
      }
    ]
  },
  "env": {
    "INSIDE_CLAUDE_CODE": "1"
  }
}
```

If `.claude/settings.json` already exists, merge preserving existing hooks.

**If Copilot** — generate separate JSON files in `.github/hooks/`:

`branch-protection.json`:

```json
{
  "type": "command",
  "bash": "branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); if [ \"$branch\" = 'main' ] || [ \"$branch\" = 'master' ]; then echo 'You are on the main branch. Create a feature branch first.'; exit 1; fi",
  "timeoutSec": 5
}
```

`auto-format.json`:

```json
{
  "type": "command",
  "bash": "[real project format command detected in Phase 1 — e.g.: npx prettier --write \"$FILE\" or ruff format \"$FILE\"]",
  "timeoutSec": 30
}
```

If `.github/hooks/` already has files, merge preserving existing hooks.

Adapt hooks to real tooling:

- **Formatter**: Prettier, Biome, Ruff, gofmt, rustfmt — whichever the project uses
- **Linter**: ESLint, Biome, Ruff, golangci-lint — whichever the project uses
- **Tests**: The real runner with the correct execution flag
- **Type checking**: tsc, mypy, pyright — if applicable

### 3.4 GitHub Workflows

If `.github/` already exists in the project, **always generate** workflows in `.github/workflows/`. If `.github/` does not exist, ask the user whether to create it.

Generate these workflows:

- **PR Review** — Automatically review PRs on open/sync
- **Code Quality** — Weekly code quality sweep
- **Dependency Audit** — Biweekly dependency audit
- **Docs Sync** — Monthly documentation sync

Each workflow must use the project's real commands. If `.github/workflows/` already has files, do not overwrite existing ones.

## Phase 4: Summary

When finished, display the appropriate summary based on AGENT_TYPE:

**If Claude Code:**

```
AAD configured successfully:

  ✓ CLAUDE.md — [created/updated]
  ✓ .claude/settings.json — [created/updated]
  ✓ .claude/skills/testing-patterns/SKILL.md — created
  ✓ .claude/skills/debugging/SKILL.md — created
  ✓ [other skills created]

Available commands:
  /aad:code-quality  — Code quality analysis
  /aad:pr-review     — PR review
  /aad:pr-summary    — Generate PR summary
  /aad:onboard       — Explore codebase for a task
  /aad:ticket        — End-to-end ticket workflow
  /aad:docs-sync     — Sync documentation

Next steps:
  1. Review the generated files and adjust to your preferences
  2. Commit the .claude/ folder and CLAUDE.md
  3. Use /aad:onboard [task] to start working
```

**If Copilot:**

```
AAD configured successfully:

  ✓ .github/copilot-instructions.md — [created/updated]
  ✓ .github/hooks/branch-protection.json — [created/updated]
  ✓ .github/hooks/auto-format.json — [created/updated]
  ✓ .github/instructions/testing-patterns.instructions.md — created
  ✓ .github/instructions/debugging.instructions.md — created
  ✓ [other instructions created]

Available skills:
  code-quality  — Code quality analysis
  pr-review     — PR review
  pr-summary    — Generate PR summary
  onboard       — Explore codebase for a task
  ticket        — End-to-end ticket workflow
  docs-sync     — Sync documentation

Next steps:
  1. Review the generated files and adjust to your preferences
  2. Commit the .github/ folder
  3. Use the onboard skill to start working
```
