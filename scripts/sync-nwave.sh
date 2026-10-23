#!/usr/bin/env bash
#
# Refreshes the vendored nWave payload from the open nWave repo (MIT):
#   vendor/nwave        skills, agents and /nw-* commands
#   vendor/nwave-hooks  TDD enforcement hooks (Python) and their dependency list
# Lists what changed. Review the diff, then commit.
#
# Usage:
#   scripts/sync-nwave.sh [git-ref]     # default: main; use a release tag to pin
#
set -euo pipefail

REPO_URL="https://github.com/nWave-ai/nWave.git"
REF="${1:-main}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$KIT_DIR/vendor/nwave"
HOOKS_DIR="$KIT_DIR/vendor/nwave-hooks"
CHECKOUT="$(mktemp -d)"
trap 'rm -rf "$CHECKOUT"' EXIT

git -c advice.detachedHead=false clone --quiet --depth 1 --branch "$REF" "$REPO_URL" "$CHECKOUT"
current_version="$(cat "$VENDOR_DIR/VERSION" 2>/dev/null || echo none)"

mkdir -p "$VENDOR_DIR"
rm -rf "$VENDOR_DIR/skills" "$VENDOR_DIR/agents" "$VENDOR_DIR/commands"
cp -R "$CHECKOUT/nWave/skills" "$VENDOR_DIR/skills"
cp -R "$CHECKOUT/nWave/agents" "$VENDOR_DIR/agents"
cp -R "$CHECKOUT/nWave/tasks/nw" "$VENDOR_DIR/commands"
cp "$CHECKOUT/LICENSE" "$VENDOR_DIR/LICENSE"
cp "$CHECKOUT/nWave/VERSION" "$VENDOR_DIR/VERSION"

# --- TDD hooks: the same files the nWave plugin ships in plugins/nw -------------
PLUGIN="$CHECKOUT/plugins/nw"
mkdir -p "$HOOKS_DIR/scripts"
rm -rf "$HOOKS_DIR/scripts/des"
rsync -a --exclude __pycache__ "$PLUGIN/scripts/des" "$HOOKS_DIR/scripts/"
cp "$PLUGIN/scripts/des-hook" "$HOOKS_DIR/scripts/des-hook"
cp "$PLUGIN/hooks/hooks.json" "$HOOKS_DIR/hooks.json"
cp "$CHECKOUT/LICENSE" "$HOOKS_DIR/LICENSE"
cp "$CHECKOUT/nWave/VERSION" "$HOOKS_DIR/VERSION"
# Dependencies are read from upstream's pyproject, so they never drift from it.
python3 - "$CHECKOUT/pyproject.toml" > "$HOOKS_DIR/requirements.txt" <<'PY'
import sys, tomllib
deps = tomllib.load(open(sys.argv[1], "rb"))["project"]["dependencies"]
print("# Copied from nWave's pyproject.toml (dependencies). Installed into a private venv.")
print("\n".join(deps))
PY

echo "nWave: $current_version → $(cat "$VENDOR_DIR/VERSION")"
git -C "$KIT_DIR" add --intent-to-add -- vendor/nwave vendor/nwave-hooks
git -C "$KIT_DIR" diff --stat -- vendor/nwave vendor/nwave-hooks | tail -n 1
