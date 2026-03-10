# AAD — Applaudo Agentic Development

A Claude Code plugin that configures Claude as an expert development companion for any project, regardless of the stack.

AAD analyzes your project's stack, conventions, and tooling, then generates tailored configuration so Claude Code understands your codebase from day one.

## What's Included

| Type | Name | Description |
|------|------|-------------|
| Skill | `init` | Detects your stack and generates all project configuration |
| Command | `code-quality` | Runs a code quality analysis beyond what linters catch |
| Command | `pr-review` | Reviews a Pull Request with categorized findings |
| Command | `pr-summary` | Generates a structured PR summary |
| Command | `onboard` | Explores the codebase to understand a task before coding |
| Command | `ticket` | End-to-end workflow: from ticket to PR |
| Command | `docs-sync` | Finds and fixes outdated documentation |
| Agent | `code-reviewer` | Senior code reviewer with structured output |
| Agent | `github-workflow` | Git/GitHub conventions enforcer |

## Installation

### Prerequisites

- [Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code) installed and authenticated

### Install the plugin

```bash
claude plugin add applaudo/aad
```

Or clone manually:

```bash
git clone https://github.com/anthropics/aad.git ~/.claude/plugins/aad
```

### Initialize in your project

Navigate to your project and run:

```
/aad:init
```

This will:
1. Scan your project for languages, frameworks, test runners, linters, etc.
2. Show you a summary of what was detected
3. After confirmation, generate:
   - `CLAUDE.md` — project context file with stack, commands, and conventions
   - `.claude/settings.json` — hooks for branch protection and auto-formatting
   - `.claude/skills/` — domain-specific skills tailored to your stack

## Usage

### `/aad:init`

Run once per project. Analyzes your stack and generates all configuration files.

```
/aad:init
```

### `/aad:onboard [task]`

Explore the codebase before starting a task. Claude reads relevant code, identifies files you'll need to touch, and proposes an approach — without making any changes.

```
/aad:onboard Add pagination to the users API endpoint
```

### `/aad:ticket [ticket-id or description]`

Full workflow from ticket to PR. Creates a branch, implements changes, runs tests, and opens a PR.

```
/aad:ticket PROJ-123
/aad:ticket #456
/aad:ticket Add dark mode toggle to settings page
```

### `/aad:code-quality`

Analyzes your codebase for issues that linters miss: logic errors, missing error handling, security concerns, dead code, and more.

```
/aad:code-quality
```

### `/aad:pr-review [PR number]`

Reviews a PR against your project's standards. Posts categorized findings (Critical / Warning / Suggestion) as PR comments.

```
/aad:pr-review 42
/aad:pr-review
```

### `/aad:pr-summary`

Generates a structured summary (Summary, Changes, Test Plan) for the current branch's PR.

```
/aad:pr-summary
```

### `/aad:docs-sync`

Finds documentation that has fallen out of sync with recent code changes and fixes verifiable inconsistencies.

```
/aad:docs-sync
```

## Built-in Protections

AAD includes hooks that activate automatically:

- **Branch protection**: Blocks edits on `main`/`master` and prompts you to create a feature branch
- **Auto-formatting**: Runs the project's formatter (Prettier, Biome, Ruff, gofmt, rustfmt) after every file edit

## Project Structure

```
.claude-plugin/
  plugin.json          # Plugin metadata and resource declarations
settings.json          # Environment, timeout, and hooks configuration
agents/
  code-reviewer.md     # Senior code review agent
  github-workflow.md   # Git/GitHub workflow agent
commands/
  code-quality.md      # Code quality analysis command
  docs-sync.md         # Documentation sync command
  onboard.md           # Task onboarding command
  pr-review.md         # PR review command
  pr-summary.md        # PR summary command
  ticket.md            # End-to-end ticket command
skills/
  init/
    SKILL.md           # Project initialization skill
```

## License

MIT — Applaudo Studios
