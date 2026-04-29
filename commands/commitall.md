---
description: Stage and commit all current changes in logical groups
agent: main
---

Review all current repository changes.

Use `git status`, `git diff`, and other safe read-only git commands to
understand the working tree.

Stage and commit the changes in logically related groups.

For each commit:

- stage only the files or hunks that belong together
- write a clear, detailed commit message
- keep unrelated changes in separate commits
- use an appropriate conventional commit type if it fits naturally

Do not squash unrelated work into one large commit.

After all commits are complete, show a brief summary of the commits created and
any remaining uncommitted changes.
