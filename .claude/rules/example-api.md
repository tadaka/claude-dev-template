---
paths:
  - "src/api/**/*.ts"
---
<!--
  EXAMPLE path-scoped rule. It loads ONLY when Claude is working on files that match
  `paths`, so it costs nothing on unrelated tasks (unlike CLAUDE.md, which loads always).
  Use this for a rule that matters in one part of the codebase. Replace or delete it.
-->
- Validate request bodies with the zod schemas in src/api/schemas/, don't hand-roll checks.
- Every new endpoint needs an entry in openapi.yaml — CI fails without it.
