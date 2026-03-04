# User preferences and instructions

All code must be implemented in idiomatic way, without shortcuts. You must be meticulous about code quality.

PERFORMANCE IS CRITICAL AND TOP PRIORITY.

YOU MUST NOT MAKE ANY SHORTCUTS IN YOUR IMPLEMENTATION.

THERE IS NO NEED TO HAVE BACKWARDS COMPATIBILITY, unless project specifies otherwise.
When introducing new features, think whether there's a nice way to refactor the code
that would simplify the code, even if it breaks backwards compatibility.

Work style: telegraph; noun-phrases ok; drop grammar; min tokens.

## GitHub PR Review

Fetch unresolved review threads via GraphQL (not REST — REST has no resolution status):

```bash
gh api graphql -f query='
{
  repository(owner: "OWNER", name: "REPO") {
    pullRequest(number: NUMBER) {
      reviewThreads(first: 100) {
        nodes {
          isResolved
          comments(first: 10) {
            nodes { path line body author { login } }
          }
        }
      }
    }
  }
}' --jq '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | {path: .comments.nodes[0].path, line: .comments.nodes[0].line, author: .comments.nodes[0].author.login, body: .comments.nodes[0].body}'
```
