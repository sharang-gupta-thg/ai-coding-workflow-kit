#!/usr/bin/env bash
#
# Installs the kit into your Claude Code configuration (~/.claude):
#   - the Code Guardian agent and the clean-code skills (incl. /review-pr)
#   - nWave (skills, agents and /nw-* commands) from the vendored snapshot
#   - the always-on workflow rules, merged into ~/.claude/CLAUDE.md
# Safe to re-run: it overwrites only the files it manages, updates only its own
# marked block in CLAUDE.md, and never touches your other agents, skills or notes.
#
# Usage:
#   ./install.sh                  # everything
#   ./install.sh --skip-nwave     # you installed nWave with its own installer/plugin
#   ./install.sh --no-global-rules  # install skills only, leave CLAUDE.md alone
#
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NWAVE_DIR="$SCRIPT_DIR/vendor/nwave"
RULES_FILE="$SCRIPT_DIR/workflow-rules.md"
GLOBAL_MEMORY="$CLAUDE_DIR/CLAUDE.md"
BLOCK_BEGIN="<!-- BEGIN ai-coding-workflow-kit (managed by install.sh; edit outside this block) -->"
BLOCK_END="<!-- END ai-coding-workflow-kit -->"

install_nwave=true
merge_rules=true
for arg in "$@"; do
  case "$arg" in
    --skip-nwave) install_nwave=false ;;
    --no-global-rules) merge_rules=false ;;
    -h|--help)
      sed -n '2,11p' "$0"; exit 0 ;;
    *) echo "Unknown option: $arg (see ./install.sh --help)" >&2; exit 2 ;;
  esac
done

# Replaces each directory in the given list under the target directory.
copy_dirs() {
  local target="$1"; shift
  local dir
  for dir in "$@"; do
    rm -rf "${target:?}/$(basename "$dir")"
    cp -R "$dir" "$target/"
  done
}

# Writes the rules into the marked block of CLAUDE.md. Text outside the block is
# kept as it is; a block that is already there is replaced, not duplicated.
merge_managed_block() {
  local file="$1" source="$2" tmp
  mkdir -p "$(dirname "$file")"
  touch "$file"
  tmp="$(mktemp)"
  awk -v begin="$BLOCK_BEGIN" -v end="$BLOCK_END" -v source="$source" '
    $0 == begin { print begin; while ((getline line < source) > 0) print line; print end; skipping = 1; written = 1; next }
    $0 == end   { skipping = 0; next }
    !skipping   { print }
    END {
      if (!written) {
        if (NR > 0) print ""
        print begin
        while ((getline line < source) > 0) print line
        print end
      }
    }' "$file" > "$tmp"
  cat "$tmp" > "$file"
  rm -f "$tmp"
}

echo "Installing into: $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"

# --- Code Guardian + clean-code skills ---------------------------------------
cp "$SCRIPT_DIR/agents/code-guardian.md" "$CLAUDE_DIR/agents/code-guardian.md"
clean_code_skills=("$SCRIPT_DIR"/skills/*/)
copy_dirs "$CLAUDE_DIR/skills" "${clean_code_skills[@]%/}"
echo "  ✓ code-guardian agent + ${#clean_code_skills[@]} clean-code skills (incl. /review-pr)"

# --- nWave ---------------------------------------------------------------------
# Copied from vendor/nwave, so no network access is needed. The TDD enforcement
# hooks need nWave's Python package, which is not in this repo (see README).
if $install_nwave; then
  mkdir -p "$CLAUDE_DIR/agents/nw" "$CLAUDE_DIR/commands/nw"
  nwave_skills=("$NWAVE_DIR"/skills/nw-*/)
  copy_dirs "$CLAUDE_DIR/skills" "${nwave_skills[@]%/}"
  cp "$NWAVE_DIR"/agents/*.md "$CLAUDE_DIR/agents/nw/"
  cp "$NWAVE_DIR"/commands/*.md "$CLAUDE_DIR/commands/nw/"
  echo "  ✓ nWave $(cat "$NWAVE_DIR/VERSION"): ${#nwave_skills[@]} skills," \
       "$(ls "$NWAVE_DIR"/agents/*.md | wc -l | tr -d ' ') agents," \
       "$(ls "$NWAVE_DIR"/commands/*.md | wc -l | tr -d ' ') commands"
else
  echo "  → nWave skipped"
fi

# --- Always-on rules -----------------------------------------------------------
# Skills only load when invoked. The rules in this block are loaded in every
# session, so Claude writes clean code and runs the review loop by default.
if $merge_rules; then
  merge_managed_block "$GLOBAL_MEMORY" "$RULES_FILE"
  echo "  ✓ workflow rules merged into $GLOBAL_MEMORY"
else
  echo "  → workflow rules skipped"
fi

# --- Verify --------------------------------------------------------------------
missing=0
for path in "$CLAUDE_DIR/agents/code-guardian.md" "$CLAUDE_DIR/skills/review-pr/SKILL.md" \
            "$CLAUDE_DIR/skills/clean-code-checklist/SKILL.md"; do
  if [ ! -f "$path" ]; then echo "  ✗ missing: $path" >&2; missing=1; fi
done
if $merge_rules && ! grep -qF "$BLOCK_BEGIN" "$GLOBAL_MEMORY"; then
  echo "  ✗ rules block not found in $GLOBAL_MEMORY" >&2; missing=1
fi
[ "$missing" -eq 0 ] || { echo "Install incomplete. Re-run ./install.sh." >&2; exit 1; }

command -v claude >/dev/null || echo "  ! 'claude' not on PATH: install Claude Code first (https://claude.com/product/claude-code)"
command -v gh >/dev/null || echo "  ! 'gh' not on PATH: /review-pr pr <n> needs the GitHub CLI (brew install gh)"

echo ""
echo "Done. Restart Claude Code (or start a new session), then try:"
echo "  /review-pr own            # before you raise a PR: fixes your branch"
echo "  /review-pr pr 123         # review someone's PR: fixes land on a review branch"
echo "  /nw-buddy what should I do next?"
