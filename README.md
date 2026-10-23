# AI Coding Workflow Kit

A reproducible [Claude Code](https://claude.com/product/claude-code) setup that pairs
the **[nWave](https://github.com/nWave-ai/nWave)** feature-delivery framework with a
**Code Guardian** review agent, a `/review-pr` workflow and 12 clean-code skills. Once
installed, every change follows the same loop, from a one-line config edit to a new service:

> **Write it clean → Test it first (TDD) → Review it.**

The full playbook is **[`DEVELOPER_GUIDE.html`](DEVELOPER_GUIDE.html)**. Open it in a
browser and keep it next to your editor.

---

## Set up with Claude (easiest)

Open Claude Code anywhere and paste this:

```text
Set up the AI coding workflow kit on this machine.

1. Check that `claude`, `git` and `gh` are installed and that `gh auth status` is logged in.
   If something is missing, tell me what to install and stop.
2. Get the kit into ~/ai-coding-workflow-kit. If it is already on this machine (for example
   copied in or unzipped), use that folder. Otherwise clone
   https://github.com/sharang-gupta-thg/ai-coding-workflow-kit. Only this step needs internet.
3. Run ~/ai-coding-workflow-kit/install.sh. It installs everything from the folder itself,
   including nWave, and makes no network calls. Do not download anything else.
   Ask me first whether I want the optional TDD enforcement hooks. If yes, run
   ./install.sh --with-tdd-hooks instead. That needs Python 3.10+ and PyPI access once.
5. Confirm the output reports the workflow rules merged into ~/.claude/CLAUDE.md and the
   review-pr skill installed. Do not edit anything else in ~/.claude.
6. Tell me to restart Claude Code, and show me the three commands to try:
   /review-pr own, /review-pr pr <number>, /nw-buddy what should I do next?
```

Claude does the steps and reports back. Or run them yourself (below).

---

## Install by hand

```bash
git clone https://github.com/sharang-gupta-thg/ai-coding-workflow-kit.git
cd ai-coding-workflow-kit
./install.sh
```

Then restart Claude Code. The installer needs no internet access. Everything it installs
is in this folder:

- copies the Code Guardian agent, the clean-code skills and `/review-pr` into `~/.claude`;
- installs nWave's skills, agents and `/nw-*` commands from `vendor/nwave/`;
- merges the always-on workflow rules (`workflow-rules.md`) into `~/.claude/CLAUDE.md`,
  inside a marked block. Your own text outside that block is never touched, and re-running
  the installer replaces the block rather than adding a second one;
- checks that the files are in place, and warns if `claude` or `gh` is missing.

Options:

| Flag | Use when |
|---|---|
| `--skip-nwave` | you installed nWave with its own installer or plugin |
| `--no-global-rules` | you want the skills but not the rules in `~/.claude/CLAUDE.md` |
| `--with-tdd-hooks` | you want nWave's TDD enforcement (see below). Needs Python 3.10+ and PyPI once |

If you already run nWave another way, use `./install.sh --skip-nwave` to avoid copying the
bundled version over it.

### TDD enforcement hooks (optional)

nWave's TDD gate is a Python package (`des`) that runs as Claude Code hooks. It is vendored
in `vendor/nwave-hooks/` from the open [nWave repo](https://github.com/nWave-ai/nWave) (MIT).
It is off by default. Turn it on with:

```bash
./install.sh --with-tdd-hooks
```

What this does, and what it needs:

- **Needs:** Python 3.10 or newer on your PATH, and PyPI access once to install its
  dependencies (rich, typer, pydantic, pyyaml, httpx and so on). Everything else is offline.
- **Installs:** a private virtualenv at `~/.claude/lib/nwave-venv`, the package at
  `~/.claude/lib/python/des`. Your system Python is not changed.
- **Edits:** `~/.claude/settings.json`. It adds the hook entries and keeps your own hooks
  and permissions. The first change saves a backup at `settings.json.before-nwave-tdd`.
  Re-running the flag replaces the kit's entries rather than duplicating them.
- **Sets:** `update_check.frequency` to `never` in `~/.nwave/global-config.json` (only if
  unset), so nothing calls out to GitHub or PyPI at session start. To get update notices,
  change it to `daily` or `weekly`.
- **Requires** the default `~/.claude` folder. It refuses if `CLAUDE_CONFIG_DIR` points elsewhere.

To turn the hooks off, remove the `des-hook` and `execution-log` entries from
`~/.claude/settings.json`, or restore the backup.

Once they are on, `/nw-deliver` enforces the TDD phases. Bash commands that edit
`execution-log.json` directly are blocked. Use `/nw-*` for phase logging, not hand edits.

### As a plugin instead (needs GitHub access)

```text
/plugin marketplace add sharang-gupta-thg/ai-coding-workflow-kit
/plugin install clean-code@ai-coding-workflow-kit
```

Installing the plugin fetches from GitHub, so it is not offline.

The plugin gives you the agent and skills, namespaced as `clean-code:code-guardian` and
`clean-code:review-pr`. It does **not** merge the always-on rules. For those, either run
`./install.sh` or paste the contents of `workflow-rules.md` into your `CLAUDE.md`.

---

## What your Claude does by default

Two kinds of guidance work together:

- **Always on** (`~/.claude/CLAUDE.md`, from `workflow-rules.md`). Every session starts
  with the rules: load the clean-code skills before writing logic, run `/review-pr own`
  before finishing a change, test first, and route by knowledge gap. Claude follows them
  without being asked.
- **On demand** (skills and the agent). `/review-pr`, `/nw-*` and the clean-code skills
  load when they're invoked or when the work calls for them.

Repo guidance (`AGENTS.md`, `CLAUDE.md` in a project) still wins over both.

### Clean code at three points

The same standards apply at each stage, so most violations never reach a PR.

1. **While writing.** Claude loads `clean-code-martin`, `code-as-prose` and
   `clean-code-checklist` before it changes code.
2. **Before you raise a PR.** `/review-pr own` runs Guardian, then checks every changed
   file against each Martin principle and the Booch prose questions. It fixes every
   verified finding on your branch, one commit per fix.
3. **When reviewing a PR.** `/review-pr pr 123` runs the same checks on someone's PR and
   opens a `review/123-…` branch with the fixes, targeted at their branch. The author can
   merge the whole branch or cherry-pick individual commits.

### Using `/review-pr`

**`own`** (your branch, before the PR exists):

1. Diffs the branch against `main` (or `master`/`develop`).
2. Runs the `code-guardian` agent, then the Martin checklist and the Booch check on every
   changed file.
3. Fixes every verified finding, one commit each. Tests run after each change.
4. Repeats the review until it is clean, or lists what is left and why.

**`pr <n>`** (someone's PR, or your own):

1. Fetches the PR's branch and creates `review/<n>-<topic>` from it in a separate worktree.
2. Runs the same review and fixes every verified finding there.
3. Pushes the review branch and opens a PR into the original PR's branch, with the fixes
   grouped by principle.
4. Reports the commit SHAs, so the author can merge the whole branch or cherry-pick.

If the PR is not yours, the skill reviews freely but asks before pushing or opening
anything against their branch.

---

## What's in here

| Path | What it is |
|------|-----------|
| `workflow-rules.md` | The always-on rules, merged into `~/.claude/CLAUDE.md` by the installer |
| `DEVELOPER_GUIDE.html` | The reference: scenarios, prompts, routing, cheat sheets |
| `agents/code-guardian.md` | Review agent carrying 12 professional standards |
| `skills/review-pr/` | The `/review-pr` workflow: `own` (before your PR) and `pr <n>` (someone's PR) |
| `skills/clean-code-checklist/` | Every Martin principle and Booch prose question as a checklist item |
| `skills/` | The 12 clean-code skills, one per standard, plus the two above |
| `vendor/nwave/` | Snapshot of nWave's skills, agents and commands (version in `VERSION`) |
| `CLAUDE.md.template` | Project-level guidance: the same loop, plus a place for your stack's facts |
| `vendor/nwave-hooks/` | nWave's TDD enforcement hooks (Python, MIT), used by `--with-tdd-hooks` |
| `install.sh` | Installs everything into `~/.claude` (`CLAUDE_CONFIG_DIR` overrides the target) |
| `scripts/sync-nwave.sh` | Refreshes `vendor/nwave` and `vendor/nwave-hooks` from the open nWave repo (pass a tag to pin) |
| `.claude-plugin/` | Installs the Guardian, skills and `/review-pr` as a Claude Code plugin |

### The two pieces

1. **nWave** structures work into seven waves (discover → diverge → discuss → design →
   devops → distill → deliver) and enforces TDD during delivery. You don't run all seven
   every time; you *route by knowledge gap* and always end `DISTILL → DELIVER`.
2. **Code Guardian** is one review agent that checks code against 12 standards: Clean
   Code, code-as-prose, SOLID, defensive programming, concurrency, error handling, the
   testing pyramid, API design, database patterns, observability, code-review practice
   and refactoring. It preloads the standards as skills and reads the branch or file
   itself, so there is nothing to paste.

Both sit alongside Claude Code's built-in reviewers: `/code-review` finds correctness
bugs, `/simplify` cleans up reuse and complexity, `/security-review` hunts
vulnerabilities. Guardian covers design and standards. The guide says when to use which.

---

## Quick start

```text
# Ask where to begin on anything
/nw-buddy what should I do next?

# A bug with a known cause: packaged TDD fix
/nw-bugfix

# A new feature on a known area (lean rigor)
/nw-discuss "add email verification"  →  /nw-design  →  /nw-distill  →  /nw-deliver

# Before you raise a PR: standards fixed on your branch, then bugs
/review-pr own
/code-review

# Review someone's PR: standards findings and fixes on review/<n>-<topic>
/review-pr pr 123
```

Set your default rigor once:

```text
/nw-rigor lean       # fast, no reviewer, ~40% of the tokens: a good default
```

---

## How it fits together

```
        You describe a task
                │
     ┌──────────┴───────────┐
     │  Route by knowledge  │   config/bump → just do it
     │        gap           │   bug → /nw-bugfix
     └──────────┬───────────┘   feature → DISCUSS…DELIVER
                │               new service → all 7 waves
                ▼
   WRITE CLEAN  →  TDD (RED→GREEN→COMMIT)  →  /review-pr own  →  PR
   (rules always on)  (nWave DELIVER or by hand)   (guardian + checklist, fixes on branch)
                │
                ▼
   PR review:  /review-pr pr <n>  →  review branch into their branch  →  merge or cherry-pick
```

---

## Uninstall

Remove the kit's files and its block from the rules file:

```bash
rm -rf ~/.claude/skills/review-pr ~/.claude/skills/clean-code-checklist ~/.claude/agents/code-guardian.md
# then delete the lines from "<!-- BEGIN ai-coding-workflow-kit" to "<!-- END ai-coding-workflow-kit -->" in ~/.claude/CLAUDE.md
```

The other clean-code skills and nWave's files are listed in `install.sh`; remove them the
same way if you no longer want them.

---

## Keeping it current

```bash
~/ai-coding-workflow-kit/install.sh      # offline: updates the skills and the rules block
git -C ~/ai-coding-workflow-kit pull     # needs GitHub: get the latest kit
scripts/sync-nwave.sh [tag]              # maintainers, needs GitHub: refresh vendor/nwave and vendor/nwave-hooks
claude update                            # needs internet: Claude Code itself
```

Only `/review-pr pr <n>` needs GitHub at run time, since it reads and pushes PRs.
`/review-pr own` works offline.

---

## Credits

- **nWave**: © nWave-ai, MIT-licensed; `vendor/nwave` is an unmodified snapshot. See
  [`NOTICE`](NOTICE).
- Clean-code principles draw on the work of Robert C. Martin (*Clean Code*) and Grady
  Booch; the skills are original summaries, not reproductions of those texts.
