## Clean-code workflow (ai-coding-workflow-kit)

These rules apply to every project. They are always on, so you do not need to be asked.

### While writing code

- Before you write or change code with logic, load the `clean-code-martin`,
  `code-as-prose` and `clean-code-checklist` skills, and write to them.
- Names reveal intent. No abbreviations. When a rule changes, rename everything that
  described it.
- Functions do one thing, stay short, take at most three parameters, and never take a
  boolean flag that changes behaviour.
- Validate at the edge and fail fast with specific exceptions that carry context.
- Comments explain why, never what. If code needs a comment to be understood, rewrite it.
- Match the surrounding code's idiom. Leave touched code cleaner than you found it.
- When the right home for logic is unclear, ask `@code-guardian` before writing.

### Before you finish a change

1. Run `/review-pr own`. It checks every changed file against the Martin and Booch
   checklist, runs code-guardian, and fixes every verified finding on the branch.
   Style included. Nothing is deferred as "future work".
2. Run `/code-review` for correctness. Run `/security-review` when the change touches
   auth, input, secrets or external calls.

### Tests

- Test first: RED, then GREEN, then commit. One behaviour per commit.
- Never delete or weaken a failing test to ship it.
- Run one focused test while you work. Run the full suite once at the end, or leave it to CI.

### Reviewing someone else's PR

- Run `/review-pr pr <number>`. Fixes go on a `review/<number>-<topic>` branch opened
  into the PR's branch, so the author can merge it whole or cherry-pick.
- Ask before you push to, comment on, or open anything against a branch you do not own.

### Routing by knowledge gap

| Task | Route |
|---|---|
| Config, infra or dependency bump | Do it and run the suite. Use Guardian only if a mistake could break production. |
| Bug with a known cause | `/nw-bugfix`. If the cause is unknown, `/nw-root-why` first. |
| Feature or endpoint | `/nw-discuss` → `/nw-design` → `/nw-distill` → `/nw-deliver`, lean rigor. |
| Refactor | `/nw-hotspot` → `/nw-refactor`. Stay green at every step. |

Every feature ends `DISTILL → DELIVER`. Start at the earliest wave with real uncertainty.
Repo guidance (`AGENTS.md`, `CLAUDE.md`) always wins over these rules.
