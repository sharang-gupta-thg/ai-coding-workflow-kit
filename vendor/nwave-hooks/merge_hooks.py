#!/usr/bin/env python3
"""Merges nWave's TDD enforcement hooks into Claude Code settings.

Standard library only, so it runs before any dependency is installed. It is
called by install.sh --with-tdd-hooks and never runs otherwise.

Usage:
    merge_hooks.py --hooks hooks.json --settings ~/.claude/settings.json \
                   --python /path/to/venv/bin/python \
                   [--global-config ~/.nwave/global-config.json]

What it does:
- Rewrites every `python3` in the hook commands to the venv interpreter, so the
  hooks use the dependencies installed for them.
- Removes hook entries it installed earlier (matched by markers), so re-running
  never duplicates them. Entries you added yourself are kept.
- Keeps a one-time backup of settings.json before the first change.
- Sets update_check.frequency to "never" in nWave's global config, if unset,
  so the session hook makes no network calls.
"""

import argparse
import json
import re
import shutil
import sys
from pathlib import Path

# A hook command containing any of these was installed by this script.
OWNED_MARKERS = ("des.adapters", "des-hook", "des.cli", "execution-log")
PYTHON_TOKEN = re.compile(r"(?<![\w/.\-])python3(?=\s)")
BACKUP_SUFFIX = ".before-nwave-tdd"


def load_json(path: Path, default):
    if not path.exists():
        return default
    try:
        return json.loads(path.read_text() or "null") or default
    except json.JSONDecodeError as error:
        sys.exit(f"Refusing to edit {path}: not valid JSON ({error}). Fix it, then re-run.")


def is_owned(group: dict) -> bool:
    return any(
        any(marker in hook.get("command", "") for marker in OWNED_MARKERS)
        for hook in group.get("hooks", [])
    )


def with_venv_python(group: dict, python: str) -> dict:
    rewritten = json.loads(json.dumps(group))
    for hook in rewritten.get("hooks", []):
        command = hook.get("command", "")
        hook["command"] = PYTHON_TOKEN.sub(f"'{python}'", command)
    return rewritten


def merge_hooks(settings: dict, plugin_hooks: dict, python: str) -> dict:
    event_hooks = settings.setdefault("hooks", {})
    for event, groups in plugin_hooks.get("hooks", {}).items():
        kept = [group for group in event_hooks.get(event, []) if not is_owned(group)]
        event_hooks[event] = kept + [with_venv_python(group, python) for group in groups]
    return settings


def back_up_once(path: Path) -> None:
    backup = path.with_name(path.name + BACKUP_SUFFIX)
    if path.exists() and not backup.exists():
        shutil.copy2(path, backup)


def write_json(path: Path, data: dict) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, indent=2) + "\n")


def set_update_check_never(path: Path) -> str:
    config = load_json(path, {})
    update_check = config.setdefault("update_check", {})
    if "frequency" in update_check:
        return f"kept your update_check.frequency = {update_check['frequency']!r}"
    update_check["frequency"] = "never"
    write_json(path, config)
    return "set update_check.frequency = 'never' (no network call at session start)"


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    parser.add_argument("--hooks", required=True, type=Path)
    parser.add_argument("--settings", required=True, type=Path)
    parser.add_argument("--python", required=True)
    parser.add_argument("--global-config", type=Path)
    args = parser.parse_args()

    plugin_hooks = load_json(args.hooks, {})
    settings = load_json(args.settings, {})
    back_up_once(args.settings)
    write_json(args.settings, merge_hooks(settings, plugin_hooks, args.python))
    print(f"  ✓ TDD hooks merged into {args.settings}")

    if args.global_config:
        print(f"  ✓ nWave global config: {set_update_check_never(args.global_config)}")


if __name__ == "__main__":
    main()
