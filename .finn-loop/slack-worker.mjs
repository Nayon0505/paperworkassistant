import { execFile as execFileCallback } from "node:child_process";
import { existsSync, mkdirSync, readFileSync, renameSync, writeFileSync } from "node:fs";
import { promisify } from "node:util";
import { resolve } from "node:path";
import { fileURLToPath } from "node:url";

const execFile = promisify(execFileCallback);
const root = resolve(".");
const stateDirectory = resolve(".finn-loop/state");
const statePath = resolve(stateDirectory, "slack.json");

function loadEnv(path = resolve(".env")) {
  if (!existsSync(path)) return;
  for (const raw of readFileSync(path, "utf8").split(/\r?\n/)) {
    const match = raw.match(/^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
    if (!match || raw.trimStart().startsWith("#") || process.env[match[1]]) continue;
    let value = match[2].trim();
    if ((value.startsWith('"') && value.endsWith('"')) ||
        (value.startsWith("'") && value.endsWith("'"))) value = value.slice(1, -1);
    process.env[match[1]] = value;
  }
}

function loadState() {
  if (!existsSync(statePath)) return { notifications: {}, handledEvents: [] };
  const state = JSON.parse(readFileSync(statePath, "utf8").replace(/^\uFEFF/, ""));
  for (const notification of Object.values(state.notifications ?? {})) {
    if (notification.status === "processing") notification.status = "ready";
  }
  return state;
}

function saveState(state) {
  mkdirSync(stateDirectory, { recursive: true });
  const temporary = `${statePath}.tmp`;
  writeFileSync(temporary, `${JSON.stringify(state, null, 2)}\n`, "utf8");
  renameSync(temporary, statePath);
}

async function run(file, args, options = {}) {
  const { stdout } = await execFile(file, args, {
    cwd: root,
    windowsHide: true,
    maxBuffer: 10 * 1024 * 1024,
    ...options,
  });
  return stdout.trim();
}

async function ghJson(args) {
  const output = await run("gh", args);
  return output ? JSON.parse(output) : null;
}

async function repository() {
  return (await ghJson(["repo", "view", "--json", "nameWithOwner"])).nameWithOwner;
}

async function latestReview(ownerRepo, number) {
  const comments = await ghJson([
    "api", `repos/${ownerRepo}/issues/${number}/comments`, "--paginate",
  ]);
  return [...comments].reverse().map((comment) => {
    const match = comment.body?.match(/^Finn-loop review of ([0-9a-f]{7,40})\b/i);
    return match ? { sha: match[1], url: comment.html_url } : null;
  }).find(Boolean);
}

function labelsOf(pr) {
  return new Set((pr.labels ?? []).map((label) => label.name));
}

async function requiredChecks(number) {
  try {
    return await ghJson([
      "pr", "checks", String(number), "--required",
      "--json", "bucket,name,state,link",
    ]);
  } catch (error) {
    throw new Error(`Required checks unavailable or not configured: ${error.message}`);
  }
}

async function verifyMerge(ownerRepo, notification) {
  const pr = await ghJson([
    "pr", "view", String(notification.pr),
    "--json", "number,title,url,state,headRefOid,mergeable,mergeStateStatus,labels,body",
  ]);
  const labels = labelsOf(pr);
  if (pr.state !== "OPEN") throw new Error("PR is no longer open");
  if (pr.headRefOid !== notification.sha) throw new Error("PR head changed after Slack notification");
  if (!labels.has("loop-approved")) throw new Error("loop-approved is missing");
  if (labels.has("needs-human-review")) throw new Error("needs-human-review blocks Slack merge");
  if (pr.mergeable !== "MERGEABLE") throw new Error(`PR is not mergeable (${pr.mergeable})`);
  const review = await latestReview(ownerRepo, pr.number);
  if (!review || review.sha !== pr.headRefOid) throw new Error("Latest Finn review does not match PR head");
  const checks = await requiredChecks(pr.number);
  if (!checks?.length) throw new Error("No required checks are configured");
  const failing = checks.filter((check) => check.bucket !== "pass");
  if (failing.length) throw new Error(`Required checks not green: ${failing.map((item) => item.name).join(", ")}`);
  return pr;
}

function linkedIssue(body) {
  return body?.match(/\bCloses\s+([A-Z][A-Z0-9]+-\d+)\b/i)?.[1]?.toUpperCase();
}

async function nextBlockedIssue(identifier) {
  if (!identifier) return null;
  const issue = JSON.parse(await run("node", [".finn-loop/linear.mjs", "issue", identifier]));
  const relation = issue.relations?.nodes?.find((item) =>
    item.type === "blocks" && item.relatedIssue?.state?.type !== "completed" &&
    item.relatedIssue?.state?.type !== "canceled");
  return relation?.relatedIssue ?? null;
}

function blocksForReady(pr, review) {
  return [
    {
      type: "section",
      text: {
        type: "mrkdwn",
        text: `*Merge-ready:* <${pr.url}|PR #${pr.number} — ${pr.title}>\n` +
          `Reviewed commit: \`${pr.headRefOid.slice(0, 12)}\`\n` +
          `Result: \`loop-approved\` · required CI green · mergeable`,
      },
    },
    {
      type: "context",
      elements: [{
        type: "mrkdwn",
        text: `Review evidence: <${review.url}|GitHub comment> · React with 🚀 to authorize a squash merge of this exact commit.`,
      }],
    },
  ];
}

async function postReadyNotifications(client, channel, ownerRepo, state) {
  const prs = await ghJson([
    "pr", "list", "--state", "open", "--label", "loop-approved",
    "--json", "number,title,url,headRefOid,labels",
  ]);
  for (const pr of prs) {
    if (labelsOf(pr).has("needs-human-review")) continue;
    const review = await latestReview(ownerRepo, pr.number);
    if (!review || review.sha !== pr.headRefOid) continue;
    const key = `merge:${pr.number}:${pr.headRefOid}`;
    if (state.notifications[key]) continue;
    const posted = await client.chat.postMessage({
      channel,
      text: `PR #${pr.number} is ready for merge. React with rocket to authorize.`,
      blocks: blocksForReady(pr, review),
    });
    state.notifications[key] = {
      kind: "merge", status: "ready", pr: pr.number, sha: pr.headRefOid,
      channel: posted.channel, ts: posted.ts,
    };
    saveState(state);
  }
}

function findNotification(state, event, kind) {
  return Object.values(state.notifications).find((item) =>
    item.kind === kind && item.status === "ready" &&
    item.channel === event.item.channel && item.ts === event.item.ts);
}

async function handleMergeReaction({ client, event, ownerRepo, state }) {
  const notification = findNotification(state, event, "merge");
  if (!notification) return;
  notification.status = "processing";
  saveState(state);
  try {
    const pr = await verifyMerge(ownerRepo, notification);
    const result = await ghJson([
      "api", "--method", "PUT", `repos/${ownerRepo}/pulls/${pr.number}/merge`,
      "-f", "merge_method=squash", "-f", `sha=${pr.headRefOid}`,
    ]);
    if (!result.merged) throw new Error(result.message ?? "GitHub did not merge the PR");
    notification.status = "merged";
    notification.mergeSha = result.sha;
    saveState(state);
    await client.chat.postMessage({
      channel: notification.channel,
      thread_ts: notification.ts,
      text: `✅ PR #${pr.number} was squash-merged at ${result.sha.slice(0, 12)}.`,
    });
    const next = await nextBlockedIssue(linkedIssue(pr.body));
    if (next) {
      const posted = await client.chat.postMessage({
        channel: notification.channel,
        thread_ts: notification.ts,
        text: `Next issue: ${next.identifier} — ${next.title}\nReact with ✅ to apply agent-ready after reviewing it in Linear.`,
      });
      state.notifications[`approve:${next.identifier}:${posted.ts}`] = {
        kind: "approve", status: "ready", issue: next.identifier,
        channel: notification.channel, ts: posted.ts, parentTs: notification.ts,
      };
      saveState(state);
    }
  } catch (error) {
    notification.status = "ready";
    notification.lastError = error.message;
    saveState(state);
    await client.chat.postMessage({
      channel: notification.channel,
      thread_ts: notification.ts,
      text: `⛔ Merge rejected: ${error.message}`,
    });
  }
}

async function handleApproveReaction({ client, event, state }) {
  const notification = findNotification(state, event, "approve");
  if (!notification) return;
  notification.status = "processing";
  saveState(state);
  try {
    const result = JSON.parse(await run("node", [
      ".finn-loop/linear.mjs", "add-label", notification.issue, "agent-ready",
    ]));
    if (!result.success) throw new Error("Linear did not accept the label update");
    notification.status = "approved";
    saveState(state);
    await client.chat.postMessage({
      channel: notification.channel,
      thread_ts: notification.parentTs,
      text: `✅ ${notification.issue} is now agent-ready.`,
    });
  } catch (error) {
    notification.status = "ready";
    notification.lastError = error.message;
    saveState(state);
    await client.chat.postMessage({
      channel: notification.channel,
      thread_ts: notification.parentTs,
      text: `⛔ Could not approve ${notification.issue}: ${error.message}`,
    });
  }
}

async function processReaction({ client, event, ownerRepo, state, approver, channel }) {
  if (event.user !== approver || event.item.type !== "message" ||
      event.item.channel !== channel || event.user === event.item_user) return;
  const eventKey = `${event.event_ts}:${event.user}:${event.reaction}`;
  if (state.handledEvents.includes(eventKey)) return;
  state.handledEvents.push(eventKey);
  state.handledEvents = state.handledEvents.slice(-500);
  saveState(state);
  if (event.reaction === "rocket") {
    await handleMergeReaction({ client, event, ownerRepo, state });
  } else if (event.reaction === "white_check_mark") {
    await handleApproveReaction({ client, event, state });
  }
}

async function pollAuthorizedReactions(client, ownerRepo, state, approver, channel) {
  for (const notification of Object.values(state.notifications)) {
    if (notification.status !== "ready") continue;
    const expected = notification.kind === "merge" ? "rocket" : "white_check_mark";
    const result = await client.reactions.get({
      channel: notification.channel,
      timestamp: notification.ts,
      full: true,
    });
    const reaction = result.message?.reactions?.find((item) =>
      item.name === expected && item.users?.includes(approver));
    if (!reaction) continue;
    await processReaction({
      client,
      event: {
        user: approver,
        reaction: expected,
        event_ts: `poll:${notification.channel}:${notification.ts}:${expected}:` +
          (notification.lastError ?? "initial"),
        item: { type: "message", channel: notification.channel, ts: notification.ts },
      },
      ownerRepo,
      state,
      approver,
      channel,
    });
  }
}

export async function start() {
  loadEnv();
  const required = [
    "SLACK_BOT_TOKEN", "SLACK_APP_TOKEN", "SLACK_APPROVER_USER_ID",
    "SLACK_MERGE_CHANNEL_ID",
  ];
  for (const name of required) if (!process.env[name]) throw new Error(`${name} is missing`);
  if (process.env.SLACK_MERGE_ENABLED !== "true") {
    throw new Error("SLACK_MERGE_ENABLED must be exactly true");
  }
  const bolt = await import("@slack/bolt");
  const App = bolt.App ?? bolt.default?.App;
  if (typeof App !== "function") {
    throw new Error("@slack/bolt did not expose an App constructor");
  }
  const app = new App({
    token: process.env.SLACK_BOT_TOKEN,
    appToken: process.env.SLACK_APP_TOKEN,
    socketMode: true,
  });
  const state = loadState();
  const ownerRepo = await repository();
  const approver = process.env.SLACK_APPROVER_USER_ID;
  const channel = process.env.SLACK_MERGE_CHANNEL_ID;

  app.event("reaction_added", async ({ event, client }) => {
    await processReaction({ client, event, ownerRepo, state, approver, channel });
  });

  await app.start();
  console.log(`Finn Slack worker connected for ${ownerRepo} in channel ${channel}`);
  await postReadyNotifications(app.client, channel, ownerRepo, state);
  await pollAuthorizedReactions(app.client, ownerRepo, state, approver, channel);
  setInterval(() => {
    postReadyNotifications(app.client, channel, ownerRepo, state)
      .then(() => pollAuthorizedReactions(app.client, ownerRepo, state, approver, channel))
      .catch((error) => console.error("Slack poll failed:", error.message));
  }, 60_000);
}

export async function check() {
  loadEnv();
  for (const name of ["SLACK_BOT_TOKEN", "SLACK_APP_TOKEN", "SLACK_APPROVER_USER_ID", "SLACK_MERGE_CHANNEL_ID"]) {
    if (!process.env[name]) throw new Error(`${name} is missing`);
  }
  const { WebClient } = await import("@slack/web-api");
  const client = new WebClient(process.env.SLACK_BOT_TOKEN);
  const auth = await client.auth.test();
  const appClient = new WebClient(process.env.SLACK_APP_TOKEN);
  const socket = await appClient.apps.connections.open();
  if (!socket.url?.startsWith("wss://")) throw new Error("Slack Socket Mode did not return a WebSocket URL");
  console.log(`Slack configuration OK: bot=${auth.user}, channel=${process.env.SLACK_MERGE_CHANNEL_ID}, socket=ready`);
}

if (process.argv[1] && resolve(process.argv[1]) === resolve(fileURLToPath(import.meta.url))) {
  if (process.argv.includes("--self-test")) {
    const sample = "Summary\n\nCloses NAY-5\n";
    if (linkedIssue(sample) !== "NAY-5") throw new Error("linkedIssue self-test failed");
    console.log("Slack worker self-test passed.");
  } else if (process.argv.includes("--check")) {
    check().catch((error) => {
      console.error(error.message);
      process.exitCode = 1;
    });
  } else {
    start().catch((error) => {
      console.error(error.message);
      process.exitCode = 1;
    });
  }
}
