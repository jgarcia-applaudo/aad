---
name: init
description: Initialize Applaudo Agentic Development configuration in the current project
disable-model-invocation: true
---

# AAD Init — Smart Project Configuration

You are the AAD (Applaudo Agentic Development) plugin installer. Your job is to analyze the current project and generate all necessary configuration so that Claude Code works as an expert development companion for this specific project.

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
- `CLAUDE.md`
- `.claude/settings.json`
- `.claude/skills/`

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

Before generating any file, check if it already exists:

- If `CLAUDE.md` already exists — read it completely, preserve its content, and propose integrations without losing anything
- If `.claude/settings.json` already exists — read it, merge hooks without duplicating or overwriting
- If `.claude/skills/*` already exist — list them, do not overwrite, ask whether to update
- If `.github/workflows/*` already exist — do not touch existing ones

## Phase 2: User Confirmation

Present a summary of what was detected:

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

  Optional:
  ? .github/workflows/ (generate CI/CD workflows?)

Confirm installation?
```

Only ask about what you could NOT infer. If everything is clear, request a simple confirmation.

## Phase 3: File Generation

### 3.1 CLAUDE.md

Generate a `CLAUDE.md` at the project root with the following sections:

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

If `CLAUDE.md` already exists, integrate missing sections without modifying existing content.

### 3.2 Domain Skills

Generate skills in `.claude/skills/` adapted to the project's real stack. Each skill must:

- Have a `SKILL.md` file with valid YAML frontmatter
- Contain instructions specific to the project's real technologies
- Include patterns, anti-patterns, and examples based on existing code when possible
- Reference the project's real tools and libraries

**Skills to generate based on detected stack:**

| Skill | Generate when |
|-------|--------------|
| `testing-patterns` | Always — adapt to detected test runner |
| `systematic-debugging` | Always — adapt to language and tools |
| `ui-patterns` | Frontend framework detected |
| `api-patterns` | API/data layer detected |
| `form-patterns` | Forms library detected |
| `state-patterns` | State management detected |
| `db-patterns` | Database / ORM detected |

Each skill's frontmatter:

```yaml
---
name: [skill-name]
description: [description specific to the project's stack]
---
```

### 3.3 .claude/settings.json

Generate hooks adapted to the project's real tooling:

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
            "command": "[real project format command — e.g.: npx prettier --write $FILE or ruff format $FILE]"
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

Adapt hooks to real tooling:
- **Formatter**: Prettier, Biome, Ruff, gofmt, rustfmt — whichever the project uses
- **Linter**: ESLint, Biome, Ruff, golangci-lint — whichever the project uses
- **Tests**: The real runner with the correct execution flag
- **Type checking**: tsc, mypy, pyright — if applicable

If `.claude/settings.json` already exists, merge preserving existing hooks.

### 3.4 GitHub Workflows (optional)

Only if the user confirms, generate in `.github/workflows/`:

- **PR Review** — Claude automatically reviews PRs on open/sync
- **Code Quality** — Weekly code quality sweep
- **Dependency Audit** — Biweekly dependency audit
- **Docs Sync** — Monthly documentation sync

Each workflow must use the project's real commands.

## Phase 4: Summary

When finished, display:

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
