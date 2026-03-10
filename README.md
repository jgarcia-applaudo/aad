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
  "chat.plugins.paths": {
    "~/.local/share/agent-plugins/aad": true
  }
}
```

Or if published to a marketplace repository:

```bash
copilot plugin install aad@applaudo/aad
```

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

## Usage

### `setup`

Run once per project. Analyzes your stack and generates all configuration files.

### `onboard [task]`

Explore the codebase before starting a task. Reads relevant code, identifies files you'll need to touch, and proposes an approach — without making any changes.

### `ticket [ticket-id or description]`

Full workflow from ticket to PR. Creates a branch, implements changes, runs tests, and opens a PR. Accepts Jira/Linear IDs, GitHub Issue URLs, or plain descriptions.

### `workflows`

Generates GitHub Actions workflows. Choose between Claude Code (`anthropics/claude-code-action`) or GitHub Copilot (`gh-aw` agentic workflows in Markdown). Interactive flow — lets you choose engine, configure secrets, and select which workflows to generate.

### `code-quality`

Analyzes your codebase for issues that linters miss: logic errors, missing error handling, security concerns, dead code, and more.

### `pr-review [PR number]`

Reviews a PR against your project's standards. Posts categorized findings (Critical / Warning / Suggestion) as PR comments.

### `pr-summary`

Generates a structured summary (Summary, Changes, Test Plan) for the current branch's PR.

### `docs-sync`

Finds documentation that has fallen out of sync with recent code changes and fixes verifiable inconsistencies.

## Built-in Protections

AAD includes hooks that activate automatically:

- **Branch protection**: Blocks edits on `main`/`master` and prompts you to create a feature branch
- **Auto-formatting**: Runs the project's formatter (Prettier, Biome, Ruff, gofmt, rustfmt) after every file edit

> **Note**: In GitHub Copilot, hooks are only available in the CLI, not in VS Code.

## Compatibility

| Feature | Claude Code | Copilot VS Code | Copilot CLI |
|---------|-------------|-----------------|-------------|
| Agents | Yes | Yes | Yes |
| Skills / Slash commands | Yes (`/aad:*`) | Yes | Yes |
| Hooks (branch protection) | Yes | No | Yes |
| Hooks (auto-format) | Yes | No | Yes |
| Setup (dynamic generation) | Yes | Yes | Yes |

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
├── skills/                       # Single source of truth for both agents
│   ├── setup/SKILL.md            # Detects agent and adapts output
│   ├── workflows/SKILL.md        # GitHub Actions generator
│   ├── code-quality/SKILL.md
│   ├── pr-review/SKILL.md
│   ├── pr-summary/SKILL.md
│   ├── onboard/SKILL.md
│   ├── ticket/SKILL.md
│   └── docs-sync/SKILL.md
└── README.md
```
