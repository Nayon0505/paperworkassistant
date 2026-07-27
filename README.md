# Paperwork Assistant

Fresh, intentionally empty project template. Product and technical decisions
start with a reviewed specification instead of inherited application code.

## Start here

1. Open this directory as the project in Codex.
2. Copy `.env.example` to `.env` and add the Linear API key.
3. Start a new Codex chat and invoke:

   ```text
   $finn-spec
   ```

4. Describe the product idea. The skill interviews you, drafts an explicit
   contract, and creates a Linear issue only after your approval.

There is deliberately no framework, application code, build system, or
deployment configuration yet. Those choices belong in the first approved
specification.

## Finn workflow

- `$finn-spec` turns an idea into an approved Linear contract.
- After you apply `agent-ready`, `$finn-build` implements one issue and opens a
  pull request.
- In a separate fresh chat, `$finn-review` independently reviews one pull
  request against its Linear contract and required GitHub checks.

Humans approve specifications, apply `agent-ready`, and merge pull requests.
