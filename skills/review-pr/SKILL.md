---
name: review-pr
description: "Review and fix code against clean-code standards. 'own' mode checks your branch before you raise a PR and fixes it in place; 'pr <number>' reviews someone's PR and raises a fix branch into their branch so they can merge it whole or cherry-pick. Runs code-guardian, the Martin principle checklist and the Booch prose check, then fixes every verified finding."
user-invocable: true
argument-hint: "own | pr <number-or-url> - Example: 'own' or 'pr 123'"
---

# Review and Fix (clean-code standards)

Two modes share one review. The difference is where the fixes land.

| Mode | When | Where fixes land |
|---|---|---|
| `own` | Your own branch, before you raise its PR | Same branch, one commit per fix |
| `pr <n>` | A PR, yours or someone else's | A new `review/<n>-<topic>` branch opened as a PR into the PR's branch |

Read the shared checklist before you start: `skills/clean-code-checklist/SKILL.md`
(Martin's principles and Booch's prose questions). The same checklist is what you use
while writing code, so a clean first draft means a short review.

## 0. Resolve the target

- **`own`**: base is the repo's default branch (`main`, else `master` or `develop`).
  Review `git diff <base>...HEAD`, plus uncommitted and untracked files, which you must
  commit or stash before the fixes start.
- **`pr <n>`**: run `gh pr view <n> --json number,title,headRefName,baseRefName,author,url`.
  Fetch the head with `git fetch origin <headRefName>`. Review
  `origin/<baseRefName>...origin/<headRefName>`.
  - If the PR author is not the current GitHub user, review freely, but ask before pushing
    anything to their branch or opening a PR into it. Posting comments needs their OK too.

Read the repo's `AGENTS.md` / `CLAUDE.md` / contributing guide now. Its rules win over
the generic standards, and it tells you the test command.

## 1. Set up the branch (`pr` mode only)

```bash
git worktree add -b review/<n>-<topic> ../<repo>-review-<n> origin/<headRefName>
```

Work only in that worktree. Leave the PR's own branch untouched.

## 2. Review the changed files

Go through every changed file, not only the diff hunks. Read each file in full, because
design problems sit around the changed lines.

1. **code-guardian**: run the `code-guardian` agent on the diff (`clean-code:code-guardian`
   when installed as a plugin). It covers the twelve standards.
2. **Martin pass**: for every changed file, answer each item in the Part 1 list of
   `clean-code-checklist`. Record a violation or "clean" per item.
3. **Booch pass**: for every changed function, answer the Part 2 questions.
4. **Merge and verify**: combine the three lists and remove duplicates. Re-read the code
   for each finding and confirm it is real. Check the caller and any guard elsewhere.
   Drop what you cannot show. Keep plausible but unproven items as questions for the author.

Report findings grouped by principle, each with `file:line`, what is wrong, the concrete
consequence, and the fix. Include a **Test gaps** list.

## 3. Fix every verified finding

Fix all of them, style included. Do not defer any as "future work". Rules:

- **Tests first for behaviour changes.** A finding that changes behaviour gets a failing
  test first, then the fix. Never weaken or delete an existing test to make it pass.
- **Refactors stay green.** Pure readability fixes must keep the suite passing at every step.
- **Commit after each fix**, with a message that names the principle and the change, for
  example `Split applyDiscount flag into two methods (Martin: no flag arguments)`. Several
  findings in one file may share a commit only when they are one change.
- **Run targeted tests after each change.** Run the full suite once at the end, or leave it
  to CI, as the repo's guidance says.
- **Attribution**: do not add `Co-Authored-By`, "Generated with" or similar lines unless the
  repo's own rules require them.

## 4. Re-review

Run step 2 again on the fixed branch. Repeat until nothing verified is left, or stop after
two rounds and list what remains with the reason.

## 5. Hand over

**`own` mode**: the branch is ready. Report the commits and the test result. Open the PR
only when the user asks.

**`pr <n>` mode**:

```bash
git push -u origin review/<n>-<topic>
gh pr create --base <headRefName> --head review/<n>-<topic> \
  --title "Clean-code fixes for #<n>" --body-file <body.md>
```

The PR body lists each fix grouped by principle, with file references and commit SHAs. Do
not use severity labels such as Major or Minor in the body. Lead with the principle.

Then tell the user how to take the fixes:

- **Merge all**: merge the review PR into their branch.
- **Cherry-pick**: pick individual commits, for example `git cherry-pick <sha>`.

## Do not

- Push to the PR author's branch directly. Fixes always go through the `review/` branch.
- Post inline comments on someone else's PR without their OK.
- Report a finding you have not confirmed in the code.
- Give a merge verdict. The decision belongs to the human.
