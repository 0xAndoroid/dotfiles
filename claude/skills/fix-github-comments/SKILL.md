---
name: fix-github-comments
description: 'Fix all unresolved GitHub PR review comments on the current branch. USE FOR: - Resolving PR review feedback in bulk - Implementing reviewer suggestions across files - Marking review threads as resolved after fixing TRIGGERS: - "fix PR comments", "resolve PR comments", "address review feedback" - "fix review comments", "PR feedback", "address PR comments" - "implement reviewer suggestions", "fix PR feedback"'
---

Fix all unresolved review comments on the current branch's PR.

## Steps

1. **Detect PR**: Use `gh pr view` to get owner, repo, and PR number from the current branch.

2. **Fetch unresolved threads** via GraphQL (REST has no resolution status):

```bash
gh api graphql -f query='
{
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: NUMBER) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          comments(first: 10) {
            nodes { path line body author { login } }
          }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | {id: .id, path: .comments.nodes[0].path, line: .comments.nodes[0].line, author: .comments.nodes[0].author.login, body: .comments.nodes[0].body}'
```

3. **Fix each comment**: Read the referenced file, understand the reviewer's request, and implement the fix.

4. **Resolve threads** after fixing — use the thread `id` from step 2:

```bash
gh api graphql -f query='
mutation {
  resolveReviewThread(input: {threadId: "THREAD_NODE_ID"}) {
    thread { isResolved }
  }
}'
```

5. **Commit and push** the fixes.
