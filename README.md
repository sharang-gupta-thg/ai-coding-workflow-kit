# AI Coding Workflow Kit

A reproducible [Claude Code](https://claude.com/product/claude-code) setup that pairs
the **[nWave](https://github.com/nWave-ai/nWave)** feature-delivery framework with a
custom **Code Guardian** review agent and 12 clean-code skills — so any change, from a
one-line config edit to a brand-new service, follows the same disciplined loop:

> **Write it clean → Test it first (TDD) → Review it.**

The full playbook is in **[`DEVELOPER_GUIDE.html`](DEVELOPER_GUIDE.html)** — open it in a
browser and keep it alongside your editor. It has a scenario for whatever you're doing
today (config, bug, dependency bump, new endpoint, refactor, semi-greenfield, greenfield)
with the exact commands and prompts for each.

---

## What's in here

| Path | What it is |
|------|-----------|
| `DEVELOPER_GUIDE.html` | The reference — scenarios, prompts, routing, cheat sheets |
| `agents/code-guardian.md` | Review agent carrying 12 professional standards |
| `skills/` | The 12 clean-code skills (+ optionally the nWave skills) |
| `CLAUDE.md.template` | Drop-in workspace guidance encoding the default loop |
| `install.sh` | Copies the agent + skills into `~/.claude` |

### The two pieces

1. **nWave** — structures work into seven "waves" (discover → diverge → discuss →
   design → devops → distill → deliver) and enforces TDD during delivery. You don't run
   all seven every time; you *route by knowledge gap* and always end
   `DISTILL → DELIVER`. Install it from the upstream project (below).
2. **Code Guardian** — a single review agent that checks any code against 12 standards:
   Clean Code, Code-as-Prose, SOLID, defensive programming, concurrency, error handling,
   the testing pyramid, API design, database patterns, observability, code-review
   practice, and refactoring. Each standard is a skill in `skills/`.

---

## Install

### 1. Prerequisites
- [Claude Code](https://claude.com/product/claude-code) installed and signed in.
- Python 3.10+ (only needed for nWave).

### 2. Install nWave (gives you the `/nw-*` commands + TDD hooks)
Follow the upstream instructions at **https://github.com/nWave-ai/nWave**. The one-liner:
```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/nWave-ai/nWave/main/scripts/install/install.sh)"
```
Restart Claude Code afterwards. (nWave is MIT-licensed; this kit does not redistribute it —
see `NOTICE`.)

### 3. Install the Code Guardian agent + clean-code skills
```bash
git clone https://github.com/<your-username>/<this-repo>.git
cd <this-repo>
./install.sh
```
This copies `agents/code-guardian.md` and the 12 clean-code skills into `~/.claude`.
Restart Claude Code.

> The installer also offers to copy any bundled `nw-*` skill files if you vendored them.
> Prefer installing nWave via its own installer (step 2) so you get the commands and
> hooks, not just the skill text.

### 4. Adopt the loop
Copy `CLAUDE.md.template` to `CLAUDE.md` in your workspace or a repo root so Claude
follows the write-clean → TDD → review loop by default.

---

## Quick start

```text
# Ask where to begin on anything
/nw-buddy "what should I do next?"

# A bug with a known cause — packaged TDD fix
/nw-bugfix

# A new feature on a known area (lean rigor)
/nw-discuss "add email verification"  →  /nw-design  →  /nw-distill  →  /nw-deliver

# Review any change before a PR
@code-guardian Full PR review vs main. [paste: git diff main]
```

Set your default rigor once:
```text
/nw-rigor lean       # fast, no reviewer, ~40% of the tokens — good default
```

See `DEVELOPER_GUIDE.html` for the full scenario-by-scenario walkthrough.

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
   WRITE CLEAN  →  TDD (RED→GREEN→COMMIT)  →  @code-guardian review
   (prompt up-front)   (nWave DELIVER or by hand)   (audit the diff)
                │
                ▼
        Verified change shipped
```

---

## Credits

- **nWave** — © nWave-ai, MIT-licensed. Install from
  [nWave-ai/nWave](https://github.com/nWave-ai/nWave). See [`NOTICE`](NOTICE) for the
  bundled skill files.
- Clean-code principles draw on the work of Robert C. Martin (*Clean Code*) and Grady
  Booch; the skills are original summaries, not reproductions of those texts.
