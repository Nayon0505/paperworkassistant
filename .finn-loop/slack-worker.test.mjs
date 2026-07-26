import assert from "node:assert/strict";
import test from "node:test";

import {
  findLatestApprovedReview,
  hasApprovedReviewForHead,
} from "./slack-worker.mjs";

const approvedBody = (sha) => `Finn-loop review of ${sha}

CI: required checks passed
Mergeability: clean

## Review

Summary: Exact-head evidence is complete.

## 1. Must fix before merge

None.

## 2. Should fix soon

None.

## 3. Safe to merge

Yes — automated evidence is complete. A human still makes the merge decision.
`;

test("stale approval label and an untrusted current-SHA marker are rejected", () => {
  const staleSha = "a".repeat(40);
  const currentSha = "b".repeat(40);
  const comments = [
    {
      body: approvedBody(staleSha),
      html_url: "https://example.test/trusted-stale",
      author_association: "OWNER",
      user: { login: "trusted-reviewer" },
    },
    {
      body: approvedBody(currentSha),
      html_url: "https://example.test/untrusted-current",
      author_association: "CONTRIBUTOR",
      user: { login: "pull-request-author" },
    },
  ];
  const pr = {
    headRefOid: currentSha,
    labels: [{ name: "loop-approved" }],
  };

  const review = findLatestApprovedReview(comments, "trusted-reviewer");

  assert.equal(review.sha, staleSha);
  assert.equal(hasApprovedReviewForHead(pr, review), false);
});

test("a trusted marker without an approving verdict is rejected", () => {
  const sha = "c".repeat(40);
  const comments = [{
    body: `Finn-loop review of ${sha}

## 3. Safe to merge

No — a must-fix finding remains.
`,
    html_url: "https://example.test/trusted-rejection",
    author_association: "OWNER",
    user: { login: "trusted-reviewer" },
  }];

  assert.equal(findLatestApprovedReview(comments, "trusted-reviewer"), undefined);
});

test("a newer trusted rejection supersedes an approval for the same SHA", () => {
  const sha = "d".repeat(40);
  const comments = [
    {
      body: approvedBody(sha),
      html_url: "https://example.test/trusted-approval",
      author_association: "OWNER",
      user: { login: "trusted-reviewer" },
    },
    {
      body: `Finn-loop review of ${sha}

## 3. Safe to merge

No — a must-fix finding remains.
`,
      html_url: "https://example.test/trusted-rejection",
      author_association: "OWNER",
      user: { login: "trusted-reviewer" },
    },
  ];

  assert.equal(findLatestApprovedReview(comments, "trusted-reviewer"), undefined);
});
