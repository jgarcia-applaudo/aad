# Testing the AAD Plugin

## Automated Structural Validation

The `test-plugin.sh` script validates the plugin structure for all three environments (Claude Code, Copilot CLI, Copilot VS Code) without requiring any external tool installed.

```bash
./test-plugin.sh
```

Exit code `0` means all checks passed. Any non-zero exit code indicates the number of failures.

### What the script validates

| Category | Checks |
|----------|--------|
| Manifests | `plugin.json` (CLI), `.github/plugin.json` (VS Code), `.claude-plugin/plugin.json` (Claude Code) exist, are valid JSON, and have the required `name` field |
| Directory references | `agents/`, `skills/`, `hooks/` declared in each manifest actually exist and contain files |
| Skills | Every directory inside `skills/` has a non-empty `SKILL.md` |
| Agents | Every `.agent.md` file inside `agents/` exists and is not empty |
| Hooks | Every `.json` file inside `hooks/` is valid JSON |
| Consistency | Plugin name and version match across all three manifests |
| Claude Code specific | `marketplace.json` and `settings.json` are valid JSON |
| Copilot CLI specific | Root `plugin.json` exists (the CLI requires the manifest at the root) |
| Copilot VS Code specific | `.github/plugin.json` exists |

---

## Manual Verification After Install

After installing the plugin (see [README.md](README.md#installation) for instructions), verify it works:

| Environment | Verification |
|-------------|-------------|
| Claude Code | Run `/aad:setup` — the setup flow should start. Try editing a file on `main` — branch protection should block it. |
| Copilot CLI | Run `copilot plugin list` — `aad` should appear. In a session, run `/setup` and `/agent` to confirm skills and agents load. |
| VS Code | Open Copilot Chat — AAD skills (e.g., `setup`, `code-quality`) should appear as available actions. |

---

## Troubleshooting

### Structural tests fail

| Failure | Cause | Fix |
|---------|-------|-----|
| "Missing required field: name" | Manifest is missing the `name` field | Add `"name": "aad"` to the affected `plugin.json` |
| "Directory is empty" | A declared directory has no files | Add the missing skill/agent/hook files |
| "Inconsistent plugin names" | Manifests use different names | Align all manifests to use the same `name` value |
| "Invalid JSON" | Syntax error in a JSON file | Fix the JSON syntax (missing comma, bracket, etc.) |

### Plugin not detected after install

| Environment | Check |
|-------------|-------|
| Claude Code | Run `/plugin list` and verify `aad` appears. If not, re-run `/plugin install aad`. |
| Copilot CLI | Run `copilot plugin list`. If missing, reinstall with `copilot plugin install ~/.local/share/agent-plugins/aad`. |
| VS Code | Verify `chat.pluginLocations` is set correctly (Remote Settings for WSL). Reload the window. |
