#!/usr/bin/env bash
#
# Installs the custom Code Guardian agent and the clean-code skills into your
# Claude Code configuration (~/.claude). Safe to re-run — it overwrites only the
# files it manages and never touches your other agents or skills.
#
# Usage:
#   ./install.sh
#
set -euo pipefail

CLAUDE_DIR="${CLAUDE_CONFIG_DIR:-$HOME/.claude}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# The 12 original clean-code skills shipped by this kit. The nWave skills
# (prefixed nw-) are installed separately via the nWave installer — see README.
CUSTOM_SKILLS=(
  clean-code-martin
  code-as-prose
  solid-principles
  defensive-programming
  concurrency-patterns
  error-handling
  testing-pyramid
  api-design
  database-patterns
  observability
  code-review-practices
  refactoring-strategies
)

echo "Installing into: $CLAUDE_DIR"
mkdir -p "$CLAUDE_DIR/agents" "$CLAUDE_DIR/skills"

# --- Agent -----------------------------------------------------------------
cp "$SCRIPT_DIR/agents/code-guardian.md" "$CLAUDE_DIR/agents/code-guardian.md"
echo "  ✓ agent: code-guardian"

# --- Clean-code skills -----------------------------------------------------
installed=0
for skill in "${CUSTOM_SKILLS[@]}"; do
  if [ -d "$SCRIPT_DIR/skills/$skill" ]; then
    rm -rf "${CLAUDE_DIR:?}/skills/$skill"
    cp -R "$SCRIPT_DIR/skills/$skill" "$CLAUDE_DIR/skills/$skill"
    installed=$((installed + 1))
  fi
done
echo "  ✓ skills: $installed clean-code skills"

# --- Optional: bundled nWave skills ---------------------------------------
# If you vendored the full nWave skill set into ./skills (nw-*), copy them too.
# Recommended instead: install nWave via its own installer (see README) so you
# get the agents, commands, and TDD hooks as well — not just the skill files.
nw_count=$(find "$SCRIPT_DIR/skills" -maxdepth 1 -type d -name 'nw-*' | wc -l | tr -d ' ')
if [ "$nw_count" -gt 0 ]; then
  echo ""
  read -r -p "Also copy $nw_count bundled nWave skill files into ~/.claude/skills? [y/N] " reply
  if [[ "$reply" =~ ^[Yy]$ ]]; then
    for dir in "$SCRIPT_DIR"/skills/nw-*; do
      name="$(basename "$dir")"
      rm -rf "${CLAUDE_DIR:?}/skills/$name"
      cp -R "$dir" "$CLAUDE_DIR/skills/$name"
    done
    echo "  ✓ copied $nw_count nWave skill files"
    echo "  ⚠ skill files only — for nWave commands (/nw-*) and TDD hooks, run the"
    echo "    nWave installer as well (see README)."
  else
    echo "  → skipped. Install nWave via its own installer (see README)."
  fi
fi

echo ""
echo "Done. Restart Claude Code, then try:"
echo "  @code-guardian review this code for quality issues"
