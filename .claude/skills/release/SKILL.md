---
name: release
description: Cut a new release. Bumps the version, writes the changelog entry, tags it and pushes the tag so CI can publish.
disable-model-invocation: true
---
This has side effects, so `disable-model-invocation: true` keeps Claude from ever starting it
on its own. It runs only when I type `/release`.

1. Confirm you're on the main branch with a clean working tree. If not, stop and ask.
2. <!-- REPLACE with your version bump, e.g. `npm version minor` or `pnpm changeset version` -->
   bump the version and commit the result.
3. Summarize the PRs merged since the last tag into CHANGELOG.md — one line each,
   user-facing changes only.
4. Tag `v<new version>` and push the tag. CI publishes from the tag.
   Never publish from your machine.
