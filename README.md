# AAD — Applaudo Agentic Development

A plugin that configures your AI coding agent as an expert development companion for any project, regardless of the stack.

AAD analyzes your project's stack, conventions, and tooling, then generates tailored configuration so your agent understands your codebase from day one.

**Supports both Claude Code and GitHub Copilot** from a single plugin.

## What's Included

| Type | Name | Description |
|------|------|-------------|
| Skill | `init` | Detects your stack and generates all project configuration |
| Skill | `code-quality` | Runs a code quality analysis beyond what linters catch |
| Skill | `pr-review` | Reviews a Pull Request with categorized findings |
| Skill | `pr-summary` | Generates a structured PR summary |
| Skill | `onboard` | Explores the codebase to understand a task before coding |
| Skill | `ticket` | End-to-end workflow: from ticket to PR |
| Skill | `docs-sync` | Finds and fixes outdated documentation |
| Agent | `code-reviewer` | Senior code reviewer with structured output |
| Agent | `github-workflow` | Git/GitHub conventions enforcer |

> Claude Code also has these skills available as `/aad:*` slash commands for backward compatibility.

## Installation

### Claude Code

```bash
git clone https://github.com/jgarcia-applaudo/aad.git ~/.claude/plugins/aad
```

Then inside Claude Code:

```
/plugin marketplace add ~/.claude/plugins/aad
/plugin install aad
```

### GitHub Copilot (VS Code)

Register the plugin locally in your VS Code settings:

```json
{
  "chat.plugins.paths": {
    "/path/to/aad": true
  }
}
```

Or if published to a marketplace repository:

```
copilot plugin install aad@applaudo/aad
```

### Initialize in your project

Navigate to your project and run the init skill:

- **Claude Code**: `/aad:init`
- **Copilot**: Use the `init` skill from the AAD plugin in chat

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

### `init`

Run once per project. Analyzes your stack and generates all configuration files.

### `onboard [task]`

Explore the codebase before starting a task. Reads relevant code, identifies files you'll need to touch, and proposes an approach — without making any changes.

### `ticket [ticket-id or description]`

Full workflow from ticket to PR. Creates a branch, implements changes, runs tests, and opens a PR. Accepts Jira/Linear IDs, GitHub Issue URLs, or plain descriptions.

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
| Skills | Yes | Yes | Yes |
| Slash commands | Yes (`/aad:*`) | No | No |
| Hooks (branch protection) | Yes | No | Yes |
| Hooks (auto-format) | Yes | No | Yes |
| Init (dynamic generation) | Yes | Yes | Yes |

## Project Structure

```
aad/
├── .claude-plugin/
│   └── plugin.json              # Claude Code plugin metadata
├── .github/
│   └── plugin/
│       └── plugin.json          # Copilot plugin metadata
├── agents/
│   ├── code-reviewer.md         # Shared — works in both agents
│   └── github-workflow.md       # Shared — works in both agents
├── skills/
│   ├── init/SKILL.md            # Shared — detects agent and adapts
│   ├── code-quality/SKILL.md    # Shared
│   ├── pr-review/SKILL.md       # Shared
│   ├── pr-summary/SKILL.md      # Shared
│   ├── onboard/SKILL.md         # Shared
│   ├── ticket/SKILL.md          # Shared
│   └── docs-sync/SKILL.md       # Shared
├── commands/                     # Claude Code only (backward compat)
├── hooks/                        # Copilot CLI only
│   ├── branch-protection.json
│   └── auto-format.json
├── settings.json                 # Claude Code hooks
└── README.md
```

## License

MIT — Applaudo Studios
