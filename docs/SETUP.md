# Setup guide

Pick the use case that matches your machine, then follow its steps. The commands assume
you are in the kit folder (`~/ai-coding-workflow-kit`). Everything installs into `~/.claude`
unless noted.

- [Choose a use case](#choose-a-use-case)
- [What needs the network](#what-needs-the-network)
- [Corporate networks (Netskope, Zscaler and similar)](#corporate-networks)
- [Offline and locked-down machines](#offline-and-locked-down-machines)
- [Check the install](#check-the-install)
- [Troubleshooting](#troubleshooting)
- [Turn things off or remove them](#turn-things-off-or-remove-them)

---

## Choose a use case

| You want | Run | Needs |
|---|---|---|
| Skills, agents and `/review-pr` in any session, no shell | `/plugin marketplace add sharang-gupta-thg/ai-coding-workflow-kit`, then `/plugin install clean-code@ai-coding-workflow-kit` and `/plugin install nwave@ai-coding-workflow-kit` | GitHub, once |
| The standard kit: nWave skills, Guardian, `/review-pr`, always-on rules | `./install.sh` | Nothing online |
| The above plus the TDD enforcement hooks | `./install.sh --with-tdd-hooks` | Python 3.10+, PyPI once (or a wheelhouse) |
| To keep your existing nWave install | `./install.sh --skip-nwave` | Nothing online |
| Only the review workflow and clean-code skills, no nWave, no global rules | `./install.sh --skip-nwave --no-global-rules` | Nothing online |
| Skills and rules only, hooks off (the default) | `./install.sh` | Nothing online |
| A single repo, with no changes to your global setup | Manual copy (see below) | Nothing online |
| A machine with no PyPI access but some Python | Wheelhouse, then `--with-tdd-hooks` | A connected machine, once |
| Team machines or a devcontainer image | Wheelhouse baked into the image | A connected build step |
| Plugin install instead of the installer | `/plugin marketplace add` (see below) | GitHub access |

### Standard install

```bash
./install.sh
```

Restart Claude Code. The installer copies the Guardian agent, the clean-code skills,
`/review-pr` and nWave's skills, agents and commands, then merges the always-on rules into
`~/.claude/CLAUDE.md`. Re-running it updates only those files.

### With the TDD enforcement hooks

```bash
./install.sh --with-tdd-hooks
```

This also:

- creates a private virtualenv at `~/.claude/lib/nwave-venv` and installs the hook dependencies into it;
- copies the hook package to `~/.claude/lib/python/des`;
- adds the hook entries to `~/.claude/settings.json`, keeping your own hooks and permissions,
  and saves a one-time backup at `settings.json.before-nwave-tdd`;
- sets nWave's update check to `never` in `~/.nwave/global-config.json`, replacing any existing value.

The hooks need the default `~/.claude` folder. The installer refuses if `CLAUDE_CONFIG_DIR`
points elsewhere.

### Keep your existing nWave

If you installed nWave with its own installer or plugin, skip the bundled copy:

```bash
./install.sh --skip-nwave
```

Add `--with-tdd-hooks` if you want the kit's hooks too. Check first that they don't duplicate
the hooks your nWave install already registered (search `~/.claude/settings.json` for
`des-hook`).

### Review workflow and clean-code skills only

```bash
./install.sh --skip-nwave --no-global-rules
```

You get `/review-pr`, `/clean-code-checklist`, the 12 clean-code skills and the Guardian
agent. Your `~/.claude/CLAUDE.md` is untouched, so the always-on rules are off. Paste
`workflow-rules.md` into your own `CLAUDE.md` if you want them.

### A single repo only

The installer writes to `~/.claude`, which affects every project. For one repo, copy the
parts you need into the repo's `.claude` folder:

```bash
mkdir -p .claude/skills .claude/agents
cp -R ~/ai-coding-workflow-kit/skills/review-pr ~/ai-coding-workflow-kit/skills/clean-code-checklist .claude/skills/
cp ~/ai-coding-workflow-kit/agents/code-guardian.md .claude/agents/
cp ~/ai-coding-workflow-kit/CLAUDE.md.template CLAUDE.md   # then edit it for this repo
```

Project-level copies are not updated by `install.sh`. Re-copy them after a `git pull` of the kit.

### Plugin install (any session, no shell)

```text
/plugin marketplace add sharang-gupta-thg/ai-coding-workflow-kit
/plugin install clean-code@ai-coding-workflow-kit
/plugin install nwave@ai-coding-workflow-kit
```

`clean-code` gives you the Guardian agent, `/review-pr` and the clean-code skills, namespaced
as `clean-code:…`. `nwave` gives you nWave's skills, agents and commands, namespaced as
`nwave:…`. Both are read from the repo's `.claude-plugin` manifests. They need GitHub access
once.

Plugins do not add the always-on rules or the TDD hooks. The hooks need Python, which a plugin
cannot install. Use the installer for those.

The same steps from a terminal, for example when Claude runs them for you:

```bash
claude plugin marketplace add sharang-gupta-thg/ai-coding-workflow-kit
claude plugin install clean-code@ai-coding-workflow-kit
claude plugin install nwave@ai-coding-workflow-kit
```

Check what loaded with `claude plugin details nwave@ai-coding-workflow-kit`.

---

## What needs the network

| Step | Contacts |
|---|---|
| `./install.sh` | Nothing. Everything comes from the kit folder. |
| `./install.sh --with-tdd-hooks` | PyPI (`pypi.org`, `files.pythonhosted.org`), once. Not needed with `NWAVE_WHEELHOUSE`. |
| Hooks at run time | Nothing. The update check is set to `never`. |
| Cloning the kit | `github.com`, once. |
| `/review-pr own` | Nothing. |
| `/review-pr pr <n>` | GitHub, through `gh`, to read and push the PR. |
| `scripts/sync-nwave.sh` | `github.com`. Maintainers only. |
| `claude update` | Anthropic. Optional. |

---

## Corporate networks

Networks that inspect HTTPS (Netskope, Zscaler, Aikido Endpoint Protection and similar) replace
the certificate for sites like PyPI with one signed by a company root CA. Tools that trust
only the public CA list fail with `CERTIFICATE_VERIFY_FAILED`.

### Check whether your network inspects HTTPS

```bash
openssl s_client -connect pypi.org:443 -servername pypi.org </dev/null 2>/dev/null \
  | openssl x509 -noout -issuer
```

If the issuer names your company, a security vendor or a proxy, your traffic is inspected.
A public issuer such as Sectigo, DigiCert or Let's Encrypt means it is not.

### Point the tools at your CA bundle

Ask your IT or security team for the root CA certificate, or a bundle that includes it. On
macOS you can also export the trusted roots from Keychain:

```bash
mkdir -p ~/certs
security find-certificate -a -p /Library/Keychains/System.keychain > ~/certs/system-roots.pem
```

Then set these for the install (add them to your shell profile to keep them):

```bash
export PIP_CERT=~/certs/corporate-ca.pem         # pip, used by --with-tdd-hooks
export REQUESTS_CA_BUNDLE=~/certs/corporate-ca.pem   # requests and other Python tools
export SSL_CERT_FILE=~/certs/corporate-ca.pem    # OpenSSL-based Python, curl
./install.sh --with-tdd-hooks
```

If `PIP_CERT` alone is enough, leave the others out. Use the bundle file your team gives you
in place of `corporate-ca.pem`.

Git and `gh` use the system trust store and usually need no change. If `git clone` fails, set
`git config --global http.sslCAInfo ~/certs/corporate-ca.pem`.

### Proxies

pip, git and `gh` honour `HTTPS_PROXY`, `HTTP_PROXY` and `NO_PROXY`. Set them if your network
needs a proxy and your tools do not already know about it.

### Last resort: trusted hosts

```bash
PIP_TRUSTED_HOST="pypi.org files.pythonhosted.org" ./install.sh --with-tdd-hooks
```

This turns off certificate checks for those two hosts for this install. Use it only if your
security team approves it. The CA bundle above is the right fix.

---

## Offline and locked-down machines

Use a wheelhouse: a folder of the dependency files, built once on a machine that can reach
PyPI, then copied to the target.

On the connected machine:

```bash
scripts/make-wheelhouse.sh ~/nwave-wheels
```

Copy `~/nwave-wheels` to the target machine, then:

```bash
NWAVE_WHEELHOUSE=~/nwave-wheels ./install.sh --with-tdd-hooks
```

The wheelhouse is not stored in the repo; it lives wherever you copy it. Build it on the
target's operating system, CPU (Apple silicon or Intel/x86_64) and Python minor version
(3.10, 3.11, 3.12 and so on). Packages with no wheel for that Python are built from source, and
the wheelhouse includes `setuptools` and `wheel` for that case.

Without a wheelhouse and without PyPI, `--with-tdd-hooks` stops after the rest of the kit has
installed. Nothing in `settings.json` is changed, so you can run it again later.

---

## Check the install

```bash
ls ~/.claude/skills/review-pr ~/.claude/skills/clean-code-checklist ~/.claude/agents/code-guardian.md
grep -c "BEGIN ai-coding-workflow-kit" ~/.claude/CLAUDE.md          # expect 1
ls ~/.claude/skills | grep -c '^nw-'                              # expect 151 or more with the bundled nWave
```

With the TDD hooks:

```bash
grep -c "des-hook" ~/.claude/settings.json                         # expect a non-zero count
PYTHONPATH=~/.claude/lib/python ~/.claude/lib/nwave-venv/bin/python \
  -c "import des.adapters.drivers.hooks.claude_code_hook_adapter; print('hooks: ok')"
```

Restart Claude Code, then run `/review-pr own` or `/nw-buddy what should I do next?` in a repo
to confirm the commands are available.

---

## Troubleshooting

| You see | Cause | Fix |
|---|---|---|
| `SSL: CERTIFICATE_VERIFY_FAILED` from pip | Your network inspects HTTPS and the company CA is not trusted | [Corporate networks](#corporate-networks): set `PIP_CERT` |
| `pip could not install the TDD hook dependencies` | PyPI unreachable, or a CA problem | Fix the CA or use a wheelhouse. The rest of the kit is already installed. |
| `No matching distribution found` with `NWAVE_WHEELHOUSE` | The wheelhouse was built for another OS, CPU or Python | Rebuild it on the target with `scripts/make-wheelhouse.sh` |
| `Could not create a virtualenv` | `python3 -m venv` is unavailable | Debian/Ubuntu: `sudo apt install python3-venv`. Then re-run. |
| `--with-tdd-hooks needs Python 3.10 or newer` | Your `python3` is older | Install a newer Python (for example `brew install python@3.12`), put it first on `PATH`, then re-run |
| `--with-tdd-hooks assumes the default ~/.claude` | `CLAUDE_CONFIG_DIR` points elsewhere | Unset `CLAUDE_CONFIG_DIR`, or drop the flag |
| Hooks do not seem to run | Claude Code started before the install | Restart Claude Code. Check the `des-hook` entries in `settings.json` and that `~/.claude/lib/python/des` exists |
| `/review-pr pr <n>` cannot reach GitHub | `gh` is not logged in, or GitHub is blocked | `gh auth status`; ask IT for GitHub access. `/review-pr own` needs neither. |
| `nWave update available` at session start | The update check is on, for example after you changed the setting by hand | Re-run `./install.sh --with-tdd-hooks`, or set `update_check.frequency` to `never` in `~/.nwave/global-config.json` |

Re-running `./install.sh` (with the same flags) is always safe. It replaces the kit's files and
its own settings entries, and leaves the rest alone.

---

## Turn things off or remove them

Turn off the TDD hooks: delete the `des-hook` and `execution-log` entries from
`~/.claude/settings.json`, or restore `settings.json.before-nwave-tdd`.

Remove the kit's files:

```bash
rm -rf ~/.claude/skills/review-pr ~/.claude/skills/clean-code-checklist ~/.claude/agents/code-guardian.md
rm -rf ~/.claude/lib/nwave-venv ~/.claude/lib/python/des
```

Then delete the lines from `<!-- BEGIN ai-coding-workflow-kit` to `<!-- END ai-coding-workflow-kit -->`
in `~/.claude/CLAUDE.md`. The other clean-code skills and nWave's files are listed in
`install.sh`. Remove them the same way.
