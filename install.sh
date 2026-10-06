#!/usr/bin/env bash
#
# Installs the kit into your Claude Code configuration (~/.claude):
#   - the Code Guardian agent and the 12 clean-code skills
#   - nWave (skills, agents and /nw-* commands) from the vendored snapshot
# Safe to re-run: it overwrites only the files it manages and never touches your
# other agents, skills or commands.
#
# Usage:
#   ./install.sh               # everything
#   ./install.sh --skip-nwave  # you install nWave with its own installer/plugin
#
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
NWAVE_DIR="$SCRIPT_DIR/vendor/nwave"

install_nwave=true
case "${1:-}" in
  "") ;;
  --skip-nwave) install_nwave=false ;;
  *) echo "Unknown option: $1 (usage: ./install.sh [--skip-nwave])" >&2; exit 2 ;;
esac

# Replaces each directory in the given list under the target directory.
copy_dirs() {
  local target="$1"; shift
  local dir
  for dir in "$@"; do
    rm -rf "${target:?}/$(basename "$dir")"
    cp -R "$dir" "$target/"
  done
}

echo "Installing into: $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"

# --- Code Guardian + clean-code skills ---------------------------------------
cp "$SCRIPT_DIR/agents/code-guardian.md" "$CLAUDE_DIR/agents/code-guardian.md"
clean_code_skills=("$SCRIPT_DIR"/skills/*/)
copy_dirs "$CLAUDE_DIR/skills" "${clean_code_skills[@]%/}"
echo "  ✓ code-guardian agent + ${#clean_code_skills[@]} clean-code skills"

# --- nWave ---------------------------------------------------------------------
# Same layout as nWave's own installer, so either one can update the other's
# files. The TDD enforcement hooks need nWave's Python package and are not
# vendored; install nWave the official way if you want them (see README).
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

echo ""
echo "Done. Restart Claude Code, then try:"
echo "  /nw-buddy what should I do next?"
echo "  @code-guardian Full PR review of this branch vs main"
