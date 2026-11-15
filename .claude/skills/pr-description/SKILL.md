---
name: pr-description
description: Write the pull-request description for the current branch. Use when opening a PR or summarizing a branch's changes for review.
---
This is team knowledge, not a secret — Claude may pick it up on its own when it opens a PR.
Write the PR body from the actual diff, not from memory.

1. Get the diff against the base branch: `git diff "$(git merge-base HEAD origin/main)"...HEAD`.
2. Structure it as:
   - **What changed** — one or two sentences, framed for a user/reviewer.
   - **Why** — the problem, bug, or ticket this closes.
   - **How to verify** — the exact commands a reviewer runs and what they should see.
   - **Risk / rollout** — migrations, feature flags, anything that needs ordering.
3. Keep it to what a reviewer needs. Link the spec or issue rather than restating it.
