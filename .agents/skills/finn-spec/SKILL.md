---
name: finn-spec
description: Interview the user about a raw idea, research the repository, and create a build-ready Linear issue after explicit confirmation. Use for Finn-loop specification, feature planning, or drafting an approved issue. Interactive only; never apply agent-ready.
---

# Finn specification

Turn one raw idea into a Linear contract that two independent engineers would
implement with the same observable behavior.

## Preflight

- Read `.finn-loop/config.json` and `.finn-loop/linear-api.md`.
- Confirm the configured Linear team and intended GitHub repository.
- Research relevant code before asking questions. Do not ask what the repository
  can answer.

## Interview

Ask 1-4 product questions per round. Offer concrete choices and put the
recommended choice first. Resolve behavior, scope, permissions, empty/error
states, data migration, and other forks that change acceptance criteria.

Continue until this test passes:

> Could two different engineers read this issue and ship the same observable
> behavior?

Do not cap the number of rounds and do not guess product decisions.

## Draft

Use exactly:

```md
## Problem

One or two sentences.

## Acceptance Criteria

- [ ] AC-1 — Observable, testable outcome

## Non-goals

- NG-1 — Explicitly excluded behavior

## Relevant files

- path/to/file — why it matters

## Test expectations

- Required automated or manual coverage

## How to verify

1. Exact manual verification step covering the ACs
```

Give every criterion and non-goal a stable identifier. Ensure no AC requires an
NG. Keep one issue to one day of agent work or split it into an ordered,
blocked-by chain.

## Confirm and create

Show the complete draft. Create nothing until the user explicitly approves it
in this session. Then use `.finn-loop/linear.mjs create-issue` with the
configured team and report the exact identifier and URL returned by Linear.

Never apply `agent-ready`. Only the user may apply that label after reading the
created issue.
