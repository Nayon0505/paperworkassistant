import { existsSync, readFileSync } from "node:fs";
import { resolve } from "node:path";

function loadEnv(path) {
  if (!existsSync(path)) return;
  for (const raw of readFileSync(path, "utf8").split(/\r?\n/)) {
    const match = raw.match(/^\s*(?:export\s+)?([A-Za-z_][A-Za-z0-9_]*)\s*=\s*(.*)\s*$/);
    if (!match || raw.trimStart().startsWith("#") || process.env[match[1]]) continue;
    let value = match[2].trim();
    if (
      (value.startsWith('"') && value.endsWith('"')) ||
      (value.startsWith("'") && value.endsWith("'"))
    ) {
      value = value.slice(1, -1);
    }
    process.env[match[1]] = value;
  }
}

loadEnv(resolve(".env"));
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

const command = process.argv[2];
if (command === "schema") {
  const result = await gql(`query {
    input: __type(name: "IssueRelationCreateInput") {
      inputFields {
        name
        type { kind name ofType { kind name } }
      }
    }
    relationType: __type(name: "IssueRelationType") {
      enumValues { name }
    }
  }`);
  console.log(JSON.stringify(result, null, 2));
} else if (command === "create") {
  const issueId = process.argv[3];
  const relatedIssueId = process.argv[4];
  if (!issueId || !relatedIssueId) {
    throw new Error("Usage: create <issueId> <relatedIssueId>");
  }
  const result = await gql(
    `mutation($input: IssueRelationCreateInput!) {
      issueRelationCreate(input: $input) {
        success
        issueRelation {
          id
          type
          issue { identifier }
          relatedIssue { identifier }
        }
      }
    }`,
    { input: { issueId, relatedIssueId, type: "blocks" } },
  );
  console.log(JSON.stringify(result.issueRelationCreate, null, 2));
} else {
  throw new Error("Commands: schema, create");
}
