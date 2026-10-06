#!/usr/bin/env bash
#
# Refreshes the vendored nWave payload (vendor/nwave: skills, agents, commands)
# from upstream and lists what changed. Review the diff, then commit.
#
# Usage:
#   scripts/sync-nwave.sh [git-ref]     # default: main
#
set -euo pipefail

REPO_URL="https://github.com/nWave-ai/nWave.git"
REF="${1:-main}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
VENDOR_DIR="$KIT_DIR/vendor/nwave"
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

echo "nWave: $current_version → $(cat "$VENDOR_DIR/VERSION")"
git -C "$KIT_DIR" add --intent-to-add -- vendor/nwave
git -C "$KIT_DIR" diff --stat -- vendor/nwave | tail -n 1
