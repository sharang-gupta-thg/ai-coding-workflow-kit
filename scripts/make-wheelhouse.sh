#!/usr/bin/env bash
#
# Downloads the TDD hook dependencies into a folder, so they can be installed on a
# machine with no PyPI access:
#
#   scripts/make-wheelhouse.sh /path/to/wheels        # run where PyPI is reachable
#   NWAVE_WHEELHOUSE=/path/to/wheels ./install.sh --with-tdd-hooks
#
# Build it on the target's OS, CPU (arm64 or x86_64) and Python minor version, so
# the wheels match. setuptools and wheel are included for packages that ship only
# source distributions.
#
set -euo pipefail

DIR="${1:?usage: scripts/make-wheelhouse.sh <folder>}"
KIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REQUIREMENTS="$KIT_DIR/vendor/nwave-hooks/requirements.txt"

mkdir -p "$DIR"
python3 -m pip download --quiet -r "$REQUIREMENTS" setuptools wheel -d "$DIR"
echo "Wheelhouse ready: $(ls "$DIR" | wc -l | tr -d ' ') files in $DIR"
echo "Python $(python3 -c 'import sys;print(".".join(map(str, sys.version_info[:2])))'), $(uname -sm)"
