import assert from "node:assert/strict";
import test from "node:test";

import {
  findLatestApprovedReview,
  handleMergeReaction,
  hasApprovedReviewForHead,
  retryPostMergeFollowUps,
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

function mergeReactionFixture(overrides = {}) {
  const sha = "e".repeat(40);
  const notification = {
    kind: "merge",
    status: "ready",
    pr: 2,
    sha,
    channel: "C123",
    ts: "100.200",
  };
  const state = {
    notifications: { [`merge:2:${sha}`]: notification },
    handledEvents: [],
  };
  const messages = [];
  const client = {
    chat: {
      postMessage: async (message) => {
        messages.push(message);
        return { channel: message.channel, ts: String(messages.length) };
      },
    },
  };
  const dependencies = {
    verifyMerge: async () => ({
      number: 2,
      headRefOid: sha,
      body: "Closes NAY-15",
    }),
    mergePullRequest: async () => ({ merged: true, sha: "f".repeat(40) }),
    nextBlockedIssue: async () => ({
      identifier: "NAY-16",
      title: "Next approved issue",
    }),
    saveState: () => {},
    ...overrides,
  };
  return {
    client,
    dependencies,
    event: { item: { channel: notification.channel, ts: notification.ts } },
    messages,
    notification,
    state,
  };
}

test("a Linear failure after merge stays merged and retries the next-issue path", async () => {
  let attempts = 0;
  const fixture = mergeReactionFixture({
    nextBlockedIssue: async () => {
      attempts += 1;
      if (attempts === 1) throw new Error("Linear temporarily unavailable");
      return { identifier: "NAY-16", title: "Next approved issue" };
    },
  });

  await handleMergeReaction({
    client: fixture.client,
    event: fixture.event,
    ownerRepo: "owner/repo",
    reviewerLogin: "trusted-reviewer",
    state: fixture.state,
    dependencies: fixture.dependencies,
  });

  assert.equal(fixture.notification.status, "merged");
  assert.equal(fixture.notification.followUpStatus, "pending");
  assert.equal(fixture.notification.followUpError, "Linear temporarily unavailable");
  assert.equal(fixture.messages.some((message) => message.text.includes("Merge rejected")), false);

  await retryPostMergeFollowUps(
    fixture.client,
    fixture.state,
    fixture.dependencies,
  );

  assert.equal(fixture.notification.status, "merged");
  assert.equal(fixture.notification.followUpStatus, "complete");
  assert.ok(fixture.notification.approvalNotificationKey);
  assert.equal(
    fixture.state.notifications[fixture.notification.approvalNotificationKey].issue,
    "NAY-16",
  );
});

test("a Slack failure after merge stays merged and retries the approval prompt", async () => {
  const fixture = mergeReactionFixture();
  let approvalPromptAttempts = 0;
  fixture.client.chat.postMessage = async (message) => {
    fixture.messages.push(message);
    if (message.text.startsWith("Next issue:")) {
      approvalPromptAttempts += 1;
      if (approvalPromptAttempts === 1) throw new Error("Slack temporarily unavailable");
    }
    return { channel: message.channel, ts: String(fixture.messages.length) };
  };

  await handleMergeReaction({
    client: fixture.client,
    event: fixture.event,
    ownerRepo: "owner/repo",
    reviewerLogin: "trusted-reviewer",
    state: fixture.state,
    dependencies: fixture.dependencies,
  });

  assert.equal(fixture.notification.status, "merged");
  assert.equal(fixture.notification.followUpStatus, "pending");
  assert.equal(fixture.notification.followUpError, "Slack temporarily unavailable");

  await retryPostMergeFollowUps(
    fixture.client,
    fixture.state,
    fixture.dependencies,
  );

  assert.equal(fixture.notification.status, "merged");
  assert.equal(fixture.notification.followUpStatus, "complete");
  assert.equal(approvalPromptAttempts, 2);
  assert.ok(fixture.notification.approvalNotificationKey);
  assert.equal(fixture.messages.some((message) => message.text.includes("Merge rejected")), false);
});
