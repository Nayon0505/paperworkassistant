# Linear access

Use the bundled CLI from the repository root:

```powershell
node .finn-loop/linear.mjs viewer
node .finn-loop/linear.mjs ready
node .finn-loop/linear.mjs issue ENG-123
node .finn-loop/linear.mjs create-issue --title "Title" --description-file issue.md
node .finn-loop/linear.mjs claim ENG-123
node .finn-loop/linear.mjs comment ENG-123 --body-file comment.md
node .finn-loop/linear.mjs block ENG-123 --body-file question.md
node .finn-loop/linear.mjs move ENG-123 "In Review"
```

The CLI loads `.env`, reads `.finn-loop/config.json`, prints JSON, and never
prints the API key. Treat API failures as blockers; do not guess remote state.

`ready` excludes assigned and blocked issues. Before claiming, inspect returned
relations and skip issues with unresolved blockers. After `claim`, re-fetch the
issue and verify ownership and labels.
