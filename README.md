# AI Coding Workflow Kit

A reproducible [Claude Code](https://claude.com/product/claude-code) setup that pairs
the **[nWave](https://github.com/nWave-ai/nWave)** feature-delivery framework with a
**Code Guardian** review agent and 12 clean-code skills, so any change, from a one-line
config edit to a brand-new service, follows the same loop:

> **Write it clean → Test it first (TDD) → Review it.**

The full playbook is **[`DEVELOPER_GUIDE.html`](DEVELOPER_GUIDE.html)**: open it in a
browser and keep it next to your editor. It has a scenario for whatever you're doing
today (config, bug, dependency bump, new endpoint, refactor, semi-greenfield,
greenfield) with the exact commands and prompts for each.

---

## What's in here

| Path | What it is |
|------|-----------|
| `DEVELOPER_GUIDE.html` | The reference: scenarios, prompts, routing, cheat sheets |
| `agents/code-guardian.md` | Review agent carrying 12 professional standards |
| `skills/` | The 12 clean-code skills, one per standard |
| `vendor/nwave/` | Snapshot of nWave's skills, agents and commands (version in `VERSION`) |
| `CLAUDE.md.template` | Drop-in workspace guidance encoding the default loop |
| `install.sh` | Copies everything into `~/.claude` |
| `scripts/sync-nwave.sh` | Refreshes `vendor/nwave` from upstream |
| `.claude-plugin/` | Lets you install the Guardian + skills as a Claude Code plugin instead |

### The two pieces

1. **nWave** structures work into seven waves (discover → diverge → discuss → design →
   devops → distill → deliver) and enforces TDD during delivery. You don't run all seven
   every time; you *route by knowledge gap* and always end `DISTILL → DELIVER`.
2. **Code Guardian** is one review agent that checks code against 12 standards: Clean
   Code, code-as-prose, SOLID, defensive programming, concurrency, error handling, the
   testing pyramid, API design, database patterns, observability, code-review practice
   and refactoring. Each standard is a skill in `skills/`, and the agent preloads all of
   them. It reads the branch or file itself, so there is nothing to paste.

Both sit alongside Claude Code's built-in reviewers: `/code-review` finds correctness
bugs, `/simplify` cleans up reuse and complexity, `/security-review` hunts
vulnerabilities. Guardian covers design and standards. The guide says when to use which.

---

## Install

### Option A: the installer (everything)

```bash
git clone https://github.com/sharang-gupta-thg/ai-coding-workflow-kit.git
cd ai-coding-workflow-kit
./install.sh
```

Installs the Guardian agent, the 12 clean-code skills, and nWave's skills, agents and
`/nw-*` commands into `~/.claude`. Restart Claude Code.

One thing the snapshot can't give you: nWave's **TDD enforcement hooks** need its Python
package. If you want them, run nWave's own installer (it writes to the same paths, so
the two can be used together):

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/nWave-ai/nWave/main/scripts/install/install.sh)"
```

Use `./install.sh --skip-nwave` if you installed nWave that way and only want the
Guardian and skills from here.

### Option B: as a plugin (Guardian + clean-code skills only)

Inside Claude Code:

```text
/plugin marketplace add sharang-gupta-thg/ai-coding-workflow-kit
/plugin install clean-code@ai-coding-workflow-kit
```

Plugin components are namespaced, so the agent is `clean-code:code-guardian` and the
skills are `clean-code:solid-principles` and so on. nWave publishes its own plugin;
see its README.

### Adopt the loop

Copy `CLAUDE.md.template` to `CLAUDE.md` in your workspace or a repo root (or merge it
into what `/init` generated) so Claude follows the write-clean → TDD → review loop by
default.

---

## Quick start

```text
# Ask where to begin on anything
/nw-buddy what should I do next?

# A bug with a known cause: packaged TDD fix
/nw-bugfix

# A new feature on a known area (lean rigor)
/nw-discuss "add email verification"  →  /nw-design  →  /nw-distill  →  /nw-deliver

# Review before a PR: standards, then bugs
@code-guardian Full PR review of this branch vs main
/code-review
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
   WRITE CLEAN  →  TDD (RED→GREEN→COMMIT)  →  @code-guardian + /code-review
   (prompt up-front)   (nWave DELIVER or by hand)      (audit the branch)
                │
                ▼
        Verified change shipped
```

---

## Keeping it current

```bash
scripts/sync-nwave.sh        # pull the latest nWave release into vendor/nwave
./install.sh                 # reinstall
claude update                # Claude Code itself
```

---

## Credits

- **nWave**: © nWave-ai, MIT-licensed; `vendor/nwave` is an unmodified snapshot. See
  [`NOTICE`](NOTICE).
- Clean-code principles draw on the work of Robert C. Martin (*Clean Code*) and Grady
  Booch; the skills are original summaries, not reproductions of those texts.
