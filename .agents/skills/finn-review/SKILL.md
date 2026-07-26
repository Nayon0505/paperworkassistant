---
name: finn-review
description: Independently review one open Finn-loop pull request against its linked Linear contract, exact head commit, mergeability, and required GitHub checks. Use for Finn-loop review queue passes. Posts one verdict and labels, but never pushes, merges, or formally reviews.
---

# Finn reviewer

Review exactly one PR. Stay independent from the builder's context.

## Select

Read `.finn-loop/config.json` and `.finn-loop/linear-api.md`. List open,
non-draft PRs with current head SHAs and labels. Find the latest comment whose
first line is `Finn-loop review of COMMIT_SHA`.

Skip a PR when that SHA is current and it already has `loop-approved`,
`loop-changes-requested`, or `needs-human-review`. Review again after any new
commit. If nothing needs review, report it and stop.

## Read the contract and code

Parse `Closes TEAM-NNN` from the PR body and fetch the full Linear issue,
comments, and relations. A missing issue is a must-fix finding. Read the entire
diff and every changed file in context.

Review only for contract gaps, defects, broken data flow, security problems,
scope expansion, missing loading/error behavior, and maintainability problems
inside scope. Prefix must-fix findings with:

- `[AC-N]`
- `[DEFECT]`
- `[SECURITY]`
- `[CI]`

If a fix would violate `NG-N`, record
`[SCOPE-CONFLICT AC-N ↔ NG-N]` and require human review.

## Verify exact evidence

Run:

```bash
gh pr view NUMBER --json headRefOid,mergeable,mergeStateStatus
gh pr checks NUMBER --required --json bucket,name,state,link
```

Pending checks or unknown mergeability mean wait without a verdict. Failed
required checks are `[CI]`; conflicts are `[DEFECT]`. No required checks means
`needs-human-review`, never `loop-approved`.

Re-fetch the head SHA immediately before posting. If it changed, discard the
review.

## Post one verdict

Use:

```md
Finn-loop review of COMMIT_SHA

CI: required checks passed | failed | not configured
Mergeability: clean | conflicting

## Review

Summary: ...

## 1. Must fix before merge

None.

## 2. Should fix soon

None.

## 3. Safe to merge

Yes — automated evidence is complete. A human still makes the merge decision.
```

Label outcomes:

- clean: add `loop-approved`, remove `loop-changes-requested`, preserve an
  existing `needs-human-review`;
- must-fix: add `loop-changes-requested`, remove `loop-approved`;
- scope conflict or missing required CI: add `needs-human-review`, remove both
  automated labels, and state that a human decision is required.

Never merge, enable auto-merge, push to the PR, or submit a formal GitHub
review. Use one comment plus labels because self-reviews may be rejected.
