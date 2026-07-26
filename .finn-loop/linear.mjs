import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

function loadEnv(path) {
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

loadEnv(resolve(".env"));
const configPath = resolve(".finn-loop/config.json");
if (!existsSync(configPath)) throw new Error("Missing .finn-loop/config.json");
const config = JSON.parse(readFileSync(configPath, "utf8").replace(/^\uFEFF/, ""));
const apiKey = process.env.LINEAR_API_KEY;
if (!apiKey) throw new Error("LINEAR_API_KEY is missing");

async function gql(query, variables = {}) {
  const response = await fetch("https://api.linear.app/graphql", {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: apiKey },
    body: JSON.stringify({ query, variables }),
  });
  const payload = await response.json();
  if (!response.ok || payload.errors?.length) {
    throw new Error(JSON.stringify(payload.errors ?? payload, null, 2));
  }
  return payload.data;
}

const issueFields = `
  id identifier title description priority createdAt updatedAt url
  assignee { id name }
  state { id name type }
  labels { nodes { id name } }
  comments { nodes { id body createdAt user { name } } }
  relations { nodes { id type relatedIssue { id identifier title state { type name } } } }
`;

async function team() {
  const data = await gql(
    `query($key: String!) { teams(filter: { key: { eq: $key } }) {
      nodes { id key name states { nodes { id name type } } labels { nodes { id name } } }
    } }`,
    { key: config.linearTeamKey },
  );
  const found = data.teams.nodes[0];
  if (!found) throw new Error(`Linear team ${config.linearTeamKey} not found`);
  return found;
}

async function issue(identifier) {
  const data = await gql(
    `query($identifier: String!) { issue(id: $identifier) { ${issueFields} } }`,
    { identifier },
  );
  if (!data.issue) throw new Error(`Issue ${identifier} not found`);
  return data.issue;
}

async function labelId(name) {
  const current = await team();
  const label = current.labels.nodes.find((item) => item.name.toLowerCase() === name.toLowerCase());
  if (!label) throw new Error(`Linear label "${name}" not found on team ${current.key}`);
  return label.id;
}

function arg(name) {
  const index = process.argv.indexOf(name);
  return index >= 0 ? process.argv[index + 1] : undefined;
}

function fileArg(name) {
  const path = arg(name);
  if (!path) throw new Error(`${name} is required`);
  return readFileSync(resolve(path), "utf8");
}

const command = process.argv[2];
let result;

if (command === "viewer") {
  result = (await gql(`query { viewer { id name email } }`)).viewer;
} else if (command === "ready") {
  const current = await team();
  const data = await gql(
    `query($teamId: ID!) { issues(
      filter: { team: { id: { eq: $teamId } } }
      first: 100
    ) { nodes { ${issueFields} } } }`,
    { teamId: current.id },
  );
  const ready = config.labels?.ready ?? "agent-ready";
  const blocked = config.labels?.blocked ?? "blocked";
  result = data.issues.nodes
    .filter((item) => !item.assignee)
    .filter((item) => item.labels.nodes.some((label) => label.name === ready))
    .filter((item) => !item.labels.nodes.some((label) => label.name === blocked))
    .sort((a, b) => (a.priority || 99) - (b.priority || 99) ||
      a.createdAt.localeCompare(b.createdAt));
} else if (command === "issue") {
  result = await issue(process.argv[3]);
} else if (command === "create-issue") {
  const current = await team();
  const title = arg("--title");
  const description = fileArg("--description-file");
  if (!title) throw new Error("--title is required");
  const data = await gql(
    `mutation($input: IssueCreateInput!) {
      issueCreate(input: $input) { success issue { id identifier title url } }
    }`,
    { input: { teamId: current.id, title, description } },
  );
  result = data.issueCreate;
} else if (command === "comment") {
  const currentIssue = await issue(process.argv[3]);
  const data = await gql(
    `mutation($input: CommentCreateInput!) {
      commentCreate(input: $input) { success comment { id body } }
    }`,
    { input: { issueId: currentIssue.id, body: fileArg("--body-file") } },
  );
  result = data.commentCreate;
} else if (command === "move") {
  const currentIssue = await issue(process.argv[3]);
  const stateName = process.argv[4];
  const current = await team();
  const state = current.states.nodes.find((item) => item.name.toLowerCase() === stateName?.toLowerCase());
  if (!state) throw new Error(`State "${stateName}" not found`);
  result = (await gql(
    `mutation($id: String!, $input: IssueUpdateInput!) {
      issueUpdate(id: $id, input: $input) { success issue { ${issueFields} } }
    }`,
    { id: currentIssue.id, input: { stateId: state.id } },
  )).issueUpdate;
} else if (command === "claim") {
  const currentIssue = await issue(process.argv[3]);
  const current = await team();
  const viewer = (await gql(`query { viewer { id name } }`)).viewer;
  const preferred = config.startedState?.toLowerCase();
  const state = current.states.nodes.find((item) => item.name.toLowerCase() === preferred) ??
    current.states.nodes.find((item) => item.type === "started");
  if (!state) throw new Error("No started Linear workflow state found");
  result = (await gql(
    `mutation($id: String!, $input: IssueUpdateInput!) {
      issueUpdate(id: $id, input: $input) { success issue { ${issueFields} } }
    }`,
    { id: currentIssue.id, input: { assigneeId: viewer.id, stateId: state.id } },
  )).issueUpdate;
} else if (command === "block") {
  const currentIssue = await issue(process.argv[3]);
  const blockedId = await labelId(config.labels?.blocked ?? "blocked");
  const existing = currentIssue.labels.nodes.map((item) => item.id);
  await gql(
    `mutation($input: CommentCreateInput!) {
      commentCreate(input: $input) { success }
    }`,
    { input: { issueId: currentIssue.id, body: fileArg("--body-file") } },
  );
  result = (await gql(
    `mutation($id: String!, $input: IssueUpdateInput!) {
      issueUpdate(id: $id, input: $input) { success issue { ${issueFields} } }
    }`,
    { id: currentIssue.id, input: { assigneeId: null, labelIds: [...new Set([...existing, blockedId])] } },
  )).issueUpdate;
} else {
  throw new Error("Commands: viewer, ready, issue, create-issue, claim, comment, move, block");
}

console.log(JSON.stringify(result, null, 2));
