---
name: finn-build
description: Claim one safe agent-ready Linear issue or repair one Finn review, implement only its contract, verify it, and open or update a GitHub pull request. Use for Finn-loop building, approved queue work, and loop-changes-requested repairs. One invocation performs one unit of work and never merges.
---

# Finn builder

One invocation handles one repair PR or one approved issue.

## Preflight

Read `.finn-loop/config.json` and `.finn-loop/linear-api.md`. Before any
mutation:

- Verify `origin` and detect the default branch with
  `gh repo view --json defaultBranchRef --jq .defaultBranchRef.name`.
- Require `git status --porcelain` to be empty. Report dirty paths and stop;
  never stash, reset, overwrite, or commit unrelated changes.
- Verify GitHub and Linear access.

## Repair queue first

List open PRs labeled `loop-changes-requested`. Exclude
`needs-human-review`, choose the least recently updated, and read the linked
Linear issue plus the latest `Finn-loop review of COMMIT_SHA` comment.

Fix only must-fix findings, run relevant checks, push, remove
`loop-changes-requested`, and comment what changed. If the fix crosses an
`NG-N` or needs a product decision, add `needs-human-review`, remove
`loop-changes-requested`, explain the exact conflict, and stop.

## Pick and claim

Use `.finn-loop/linear.mjs ready` and select by priority then oldest. Eligible
means all of:

- team matches configuration;
- labeled `agent-ready`;
- unassigned;
- not labeled `blocked`;
- no unresolved blocker relation.

If empty, report it and stop. Assign the issue to the authenticated Linear user
and move it to a started state before deep reading. Re-fetch immediately. If it
is no longer eligible or belongs to somebody else, do not work it.

Only one builder loop may run per Linear team because assignment is not an
atomic lock between sessions using the same user.

## Read and build

Fetch the full issue, comments, and relations. Compare every `AC-N` with every
`NG-N`. Non-goals bind. If ambiguous, conflicting, or blocked, use the blocked
procedure.

Fetch the default branch and create or resume
`TEAM-NNN-short-slug`. Implement only the acceptance criteria using existing
architecture and conventions. Add tests for changed logic, data flow,
permissions, integrations, and user-visible behavior. Do not refactor
opportunistically.

## Verify and ship

Run relevant lint, typecheck, build, and narrow tests. Disclose unrelated
pre-existing failures with targeted passing evidence. Inspect `git diff` and
`git status`; stop for unrelated work or secrets.

Push and open a PR containing:

- what changed and why;
- `Closes TEAM-NNN`;
- one evidence line per `AC-N`;
- one preservation line per `NG-N`;
- `Other behavior changes: None`;
- numbered manual tests;
- automated checks and results;
- risk: Low, Medium, or High.

If “Other behavior changes: None” is false, stop and require the Linear contract
to be amended. Comment the PR URL on Linear and move to a review state when
configured. Never merge or enable auto-merge.

## Blocked

Comment one answerable question with options and the affected `AC-N`, add
`blocked`, and unassign. Keep `agent-ready`; the queue excludes blocked issues.
Stop so another issue can be selected on the next invocation.
