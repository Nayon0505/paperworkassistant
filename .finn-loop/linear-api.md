# Linear access

The `finn-spec` skill uses the bundled zero-dependency CLI from the repository
root:

```powershell
node .finn-loop/linear.mjs viewer
node .finn-loop/linear.mjs team
node .finn-loop/linear.mjs ready
node .finn-loop/linear.mjs issue NAY-123
node .finn-loop/linear.mjs create-issue --title "Title" --description-file issue.md
node .finn-loop/linear.mjs claim NAY-123
node .finn-loop/linear.mjs comment NAY-123 --body-file comment.md
node .finn-loop/linear.mjs block NAY-123 --body-file question.md
node .finn-loop/linear.mjs move NAY-123 "In Review"
```

The CLI loads `.env`, reads `.finn-loop/config.json`, prints JSON, and never
prints the API key. Treat API failures as blockers; do not guess remote state.
