#!/usr/bin/env bash
# Validates the AAD plugin structure for Claude Code and GitHub Copilot compatibility.
# Usage: ./test-plugin.sh

set -euo pipefail

PLUGIN_DIR="$(cd "$(dirname "$0")" && pwd)"
ERRORS=0
WARNINGS=0
PASS=0

red()    { printf "\033[31m%s\033[0m\n" "$1"; }
green()  { printf "\033[32m%s\033[0m\n" "$1"; }
yellow() { printf "\033[33m%s\033[0m\n" "$1"; }

pass() { PASS=$((PASS + 1)); green "  PASS: $1"; }
fail() { ERRORS=$((ERRORS + 1)); red "  FAIL: $1"; }
warn() { WARNINGS=$((WARNINGS + 1)); yellow "  WARN: $1"; }

section() { printf "\n\033[1m%s\033[0m\n" "$1"; }

# --- Manifest validation ---

validate_manifest() {
  local file="$1" label="$2"

  section "[$label] $file"

  if [[ ! -f "$PLUGIN_DIR/$file" ]]; then
    fail "File not found: $file"
    return
  fi
  pass "File exists"

  if ! python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$PLUGIN_DIR/$file" 2>/dev/null; then
    fail "Invalid JSON"
    return
  fi
  pass "Valid JSON"

  # Check required field: name
  local name
  name=$(python3 -c "import json, sys; d=json.load(open(sys.argv[1])); print(d.get('name',''))" "$PLUGIN_DIR/$file")
  if [[ -z "$name" ]]; then
    fail "Missing required field: name"
  else
    pass "Has name: $name"
  fi

  # Check description
  local desc
  desc=$(python3 -c "import json, sys; d=json.load(open(sys.argv[1])); print(d.get('description',''))" "$PLUGIN_DIR/$file")
  if [[ -z "$desc" ]]; then
    warn "Missing description"
  else
    pass "Has description"
  fi
}

# --- Directory reference validation ---

validate_dir_ref() {
  local manifest="$1" field="$2" label="$3"

  local value
  value=$(python3 -c "
import json, sys
d = json.load(open(sys.argv[1]))
v = d.get(sys.argv[2], '')
if isinstance(v, list):
    print(' '.join(v))
else:
    print(v)
" "$PLUGIN_DIR/$manifest" "$field" 2>/dev/null || echo "")

  if [[ -z "$value" ]]; then
    warn "[$label] Field '$field' not declared in $manifest"
    return
  fi

  for path in $value; do
    local full_path="$PLUGIN_DIR/$path"
    if [[ -d "$full_path" ]]; then
      local count
      count=$(find "$full_path" -maxdepth 2 -type f | wc -l | tr -d ' ')
      if [[ "$count" -eq 0 ]]; then
        fail "[$label] Directory '$path' is empty"
      else
        pass "[$label] $field -> '$path' exists ($count files)"
      fi
    elif [[ -f "$full_path" ]]; then
      pass "[$label] $field -> '$path' exists (file)"
    else
      fail "[$label] $field -> '$path' does not exist"
    fi
  done
}

# --- Skills validation ---

validate_skills() {
  section "Skills structure"

  local skills_dir="$PLUGIN_DIR/skills"
  if [[ ! -d "$skills_dir" ]]; then
    fail "skills/ directory not found"
    return
  fi

  local skill_count=0
  for skill_dir in "$skills_dir"/*/; do
    [[ -d "$skill_dir" ]] || continue
    local skill_name
    skill_name=$(basename "$skill_dir")
    skill_count=$((skill_count + 1))

    if [[ -f "$skill_dir/SKILL.md" ]]; then
      # Check SKILL.md is not empty
      if [[ -s "$skill_dir/SKILL.md" ]]; then
        pass "Skill '$skill_name' has SKILL.md"
      else
        fail "Skill '$skill_name' SKILL.md is empty"
      fi
    else
      fail "Skill '$skill_name' missing SKILL.md"
    fi
  done

  if [[ "$skill_count" -eq 0 ]]; then
    fail "No skill directories found"
  else
    pass "Found $skill_count skills"
  fi
}

# --- Agents validation ---

validate_agents() {
  section "Agents structure"

  local agents_dir="$PLUGIN_DIR/agents"
  if [[ ! -d "$agents_dir" ]]; then
    fail "agents/ directory not found"
    return
  fi

  local agent_count=0
  for agent_file in "$agents_dir"/*.agent.md; do
    [[ -f "$agent_file" ]] || continue
    local agent_name
    agent_name=$(basename "$agent_file")
    agent_count=$((agent_count + 1))

    if [[ -s "$agent_file" ]]; then
      pass "Agent '$agent_name' exists and is not empty"
    else
      fail "Agent '$agent_name' is empty"
    fi
  done

  if [[ "$agent_count" -eq 0 ]]; then
    fail "No .agent.md files found in agents/"
  else
    pass "Found $agent_count agents"
  fi
}

# --- Hooks validation ---

validate_hooks() {
  section "Hooks structure"

  local hooks_dir="$PLUGIN_DIR/hooks"
  if [[ ! -d "$hooks_dir" ]]; then
    warn "hooks/ directory not found"
    return
  fi

  for hook_file in "$hooks_dir"/*.json; do
    [[ -f "$hook_file" ]] || continue
    local hook_name
    hook_name=$(basename "$hook_file")

    if python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$hook_file" 2>/dev/null; then
      pass "Hook '$hook_name' is valid JSON"
    else
      fail "Hook '$hook_name' is invalid JSON"
    fi
  done
}

# --- Cross-manifest consistency ---

validate_consistency() {
  section "Cross-manifest consistency"

  # Check that all manifests declare the same plugin name
  local names=()
  for manifest in plugin.json .github/plugin.json .claude-plugin/plugin.json; do
    [[ -f "$PLUGIN_DIR/$manifest" ]] || continue
    local n
    n=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1])).get('name',''))" "$PLUGIN_DIR/$manifest" 2>/dev/null || echo "")
    if [[ -n "$n" ]]; then
      names+=("$manifest:$n")
    fi
  done

  local first_name=""
  local consistent=true
  for entry in "${names[@]}"; do
    local name="${entry#*:}"
    if [[ -z "$first_name" ]]; then
      first_name="$name"
    elif [[ "$name" != "$first_name" ]]; then
      consistent=false
    fi
  done

  if $consistent; then
    pass "All manifests use the same plugin name: $first_name"
  else
    fail "Inconsistent plugin names across manifests: ${names[*]}"
  fi

  # Check versions match
  local versions=()
  for manifest in plugin.json .github/plugin.json .claude-plugin/plugin.json; do
    [[ -f "$PLUGIN_DIR/$manifest" ]] || continue
    local v
    v=$(python3 -c "import json, sys; print(json.load(open(sys.argv[1])).get('version',''))" "$PLUGIN_DIR/$manifest" 2>/dev/null || echo "")
    if [[ -n "$v" ]]; then
      versions+=("$manifest:$v")
    fi
  done

  first_name=""
  consistent=true
  for entry in "${versions[@]}"; do
    local ver="${entry#*:}"
    if [[ -z "$first_name" ]]; then
      first_name="$ver"
    elif [[ "$ver" != "$first_name" ]]; then
      consistent=false
    fi
  done

  if $consistent; then
    pass "All manifests use the same version: $first_name"
  else
    fail "Inconsistent versions across manifests: ${versions[*]}"
  fi
}

# --- Claude Code specific ---

validate_claude_code() {
  section "Claude Code specific"

  if [[ -f "$PLUGIN_DIR/.claude-plugin/plugin.json" ]]; then
    pass "Claude Code manifest exists"
  else
    fail "Missing .claude-plugin/plugin.json"
  fi

  if [[ -f "$PLUGIN_DIR/.claude-plugin/marketplace.json" ]]; then
    if python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$PLUGIN_DIR/.claude-plugin/marketplace.json" 2>/dev/null; then
      pass "marketplace.json is valid JSON"
    else
      fail "marketplace.json is invalid JSON"
    fi
  else
    warn "No marketplace.json found"
  fi

  if [[ -f "$PLUGIN_DIR/settings.json" ]]; then
    if python3 -c "import json, sys; json.load(open(sys.argv[1]))" "$PLUGIN_DIR/settings.json" 2>/dev/null; then
      pass "settings.json is valid JSON"
    else
      fail "settings.json is invalid JSON"
    fi
  fi
}

# --- Copilot CLI specific ---

validate_copilot_cli() {
  section "Copilot CLI specific"

  if [[ -f "$PLUGIN_DIR/plugin.json" ]]; then
    pass "Root plugin.json exists (required by CLI)"
  else
    fail "Missing root plugin.json (CLI won't discover the plugin)"
  fi
}

# --- Copilot VS Code specific ---

validate_copilot_vscode() {
  section "Copilot VS Code specific"

  if [[ -f "$PLUGIN_DIR/.github/plugin.json" ]]; then
    pass ".github/plugin.json exists"
  else
    warn "Missing .github/plugin.json (may be needed for VS Code)"
  fi
}

# ============================
# Run all validations
# ============================

echo "============================================"
echo "  AAD Plugin Validation"
echo "  Dir: $PLUGIN_DIR"
echo "============================================"

validate_manifest "plugin.json" "Copilot CLI"
validate_manifest ".github/plugin.json" "Copilot VS Code"
validate_manifest ".claude-plugin/plugin.json" "Claude Code"

validate_dir_ref "plugin.json" "agents" "Copilot CLI"
validate_dir_ref "plugin.json" "skills" "Copilot CLI"
validate_dir_ref "plugin.json" "hooks" "Copilot CLI"

validate_dir_ref ".github/plugin.json" "agents" "Copilot VS Code"
validate_dir_ref ".github/plugin.json" "skills" "Copilot VS Code"
validate_dir_ref ".github/plugin.json" "hooks" "Copilot VS Code"

validate_skills
validate_agents
validate_hooks
validate_consistency
validate_claude_code
validate_copilot_cli
validate_copilot_vscode

# --- Summary ---

echo ""
echo "============================================"
if [[ $ERRORS -eq 0 ]]; then
  green "  RESULT: ALL CHECKS PASSED"
else
  red "  RESULT: $ERRORS FAILURE(S)"
fi
echo "  $PASS passed, $ERRORS failed, $WARNINGS warnings"
echo "============================================"

exit $ERRORS
