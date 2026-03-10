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
  ✓ .claude/.gitignore
  ✓ .claude/settings.json (new / merge with existing)

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

### 3.2.1 Claude Code .gitignore

**If Claude Code** — generate `.claude/.gitignore` to exclude local-only files from version control:

```gitignore
settings.local.json
user-team-info.json
tasks/
```

If `.claude/.gitignore` already exists, do not overwrite it.

### 3.3 Settings and Hooks

**If Claude Code** — generate `.claude/settings.json` with ALL applicable hooks from the table below:

| Hook | Event | Matcher | Type | When to include |
|------|-------|---------|------|-----------------|
| Branch protection | PreToolUse | `Edit\|Write` | prompt | Always |
| Auto-format | PostToolUse | `Edit\|Write` | command | Always (adapt to detected formatter) |
| Auto-lint fix | PostToolUse | `Edit\|Write` | command | If linter supports auto-fix (ESLint --fix, Ruff --fix) |
| Auto-install deps | PostToolUse | `Edit\|Write` | command | Always (detect package manager changes) |
| Auto-run tests | PostToolUse | `Edit\|Write` | command | Always (run related tests when test files change) |
| Type-check | PostToolUse | `Edit\|Write` | command | If project uses typed language (TypeScript, Python w/ mypy/pyright) |

**Hook implementation reference** — adapt commands to the real project tools:

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
            "command": "Auto-format hook. Filter $CLAUDE_FILE_PATHS by relevant extensions, then run the formatter. Examples by stack:\n  - JS/TS: if echo \"$CLAUDE_FILE_PATHS\" | grep -qE '\\.(js|ts|jsx|tsx)$'; then npx prettier --write $CLAUDE_FILE_PATHS 2>/dev/null; fi\n  - Python: if echo \"$CLAUDE_FILE_PATHS\" | grep -q '\\.py$'; then ruff format $CLAUDE_FILE_PATHS 2>/dev/null; fi\n  - Go: if echo \"$CLAUDE_FILE_PATHS\" | grep -q '\\.go$'; then gofmt -w $CLAUDE_FILE_PATHS 2>/dev/null; fi\n  - Rust: if echo \"$CLAUDE_FILE_PATHS\" | grep -q '\\.rs$'; then rustfmt $CLAUDE_FILE_PATHS 2>/dev/null; fi",
            "timeout": 30000
          },
          {
            "type": "command",
            "command": "Auto-lint fix hook. Same filter pattern as formatter, then run linter with auto-fix. Examples:\n  - JS/TS: if echo \"$CLAUDE_FILE_PATHS\" | grep -qE '\\.(js|ts|jsx|tsx)$'; then npx eslint --fix $CLAUDE_FILE_PATHS 2>/dev/null; fi\n  - Python: if echo \"$CLAUDE_FILE_PATHS\" | grep -q '\\.py$'; then ruff check --fix $CLAUDE_FILE_PATHS 2>/dev/null; fi",
            "timeout": 30000
          },
          {
            "type": "command",
            "command": "Auto-install deps hook. Detect if a dependency manifest changed, then reinstall. Examples:\n  - npm: if echo \"$CLAUDE_FILE_PATHS\" | grep -q 'package\\.json'; then npm install 2>/dev/null; fi\n  - Python: if echo \"$CLAUDE_FILE_PATHS\" | grep -q 'pyproject\\.toml\\|requirements.*\\.txt'; then pip install -e . 2>/dev/null || pip install -r requirements.txt 2>/dev/null; fi",
            "timeout": 60000
          },
          {
            "type": "command",
            "command": "Auto-run tests hook. If a test file was edited, run only that test. Examples:\n  - Jest: if echo \"$CLAUDE_FILE_PATHS\" | grep -qE '\\.(test|spec)\\.(js|ts|jsx|tsx)$'; then npx jest --bail --findRelatedTests $CLAUDE_FILE_PATHS 2>/dev/null; fi\n  - Pytest: if echo \"$CLAUDE_FILE_PATHS\" | grep -qE 'test_.*\\.py$|.*_test\\.py$'; then python -m pytest $CLAUDE_FILE_PATHS --no-header -q 2>/dev/null; fi\n  - Go: if echo \"$CLAUDE_FILE_PATHS\" | grep -q '_test\\.go$'; then go test ./... 2>/dev/null; fi",
            "timeout": 90000
          },
          {
            "type": "command",
            "command": "Type-check hook (only if applicable). Examples:\n  - TypeScript: if echo \"$CLAUDE_FILE_PATHS\" | grep -qE '\\.(ts|tsx)$'; then npx tsc --noEmit 2>/dev/null; fi\n  - Python (mypy): if echo \"$CLAUDE_FILE_PATHS\" | grep -q '\\.py$'; then mypy $CLAUDE_FILE_PATHS 2>/dev/null; fi",
            "timeout": 30000
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

**IMPORTANT**: The JSON above is a REFERENCE with all possible hooks. You must:

1. Only include hooks relevant to the detected stack
2. Replace the example commands with the project's REAL tools and commands
3. Use only relative paths — never absolute paths
4. Filter `$CLAUDE_FILE_PATHS` by the correct file extensions for the project
5. If the project uses a combined tool (e.g., Biome for both format and lint), merge into a single hook
6. Set appropriate timeouts: format/lint 30s, deps install 60s, tests 90s, type-check 30s

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
  "bash": "[real project format command — e.g.: npx prettier --write \"$FILE\" or ruff format \"$FILE\"]",
  "timeoutSec": 30
}
```

`auto-lint.json` (if linter supports auto-fix):

```json
{
  "type": "command",
  "bash": "[real project lint-fix command — e.g.: npx eslint --fix \"$FILE\" or ruff check --fix \"$FILE\"]",
  "timeoutSec": 30
}
```

If `.github/hooks/` already has files, merge preserving existing hooks.

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
  /aad:workflows     — Generate GitHub Actions workflows

Next steps:
  1. Review the generated files and adjust to your preferences
  2. Commit the .claude/ folder and CLAUDE.md
  3. Run /aad:workflows to generate CI/CD workflows
  4. Use /aad:onboard [task] to start working
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
