# CLAUDE.md
<!--
  Starter CLAUDE.md — copy into a new project and fill in. This file loads into EVERY
  session, so every line spends a little of Claude's attention on every task. Keep it
  short (aim < 200 lines) and write ONLY what Claude can't get by reading the repo.

  Test before adding a line:  Could Claude find this by reading the code?  AND
  would it actually go look?   If both are yes, leave it out.

  - `/init`               drafts this from a real codebase (then the work is mostly cutting)
  - `/doctor`             suggests lines Claude could already work out from the code
  - `/doctor prompt-audit`flags stale, dead, or contradictory lines
  - `/context all`        confirms, in a session, that this file loaded

  Personal preferences go in CLAUDE.local.md (gitignored), not here.
  Rules for just one part of the tree go in .claude/rules/ with a `paths:` filter.
  Rules that must NEVER bend go in a hook or deny rule, not here — see docs/how-to-use.md.
-->

# Commands
<!-- The exact commands, so Claude can check its own work as it goes. Replace these. -->
- Install: <e.g. npm install>
- Run one test file: <e.g. npx vitest run path/to/file.test.ts>
- Typecheck: <e.g. npx tsc --noEmit>
- Lint: <e.g. npm run lint>

# Conventions
<!-- Decisions that aren't visible in the code, and misleading patterns to avoid. -->
- <e.g. Use the error helpers in src/lib/errors.ts, never throw raw strings.>
- <e.g. src/legacy/ is still live but don't copy its patterns into new code.>

# Gotchas
<!-- Things that cost time to rediscover every session. Delete if you have none. -->
- <e.g. Integration tests need DATABASE_URL set — see .env.example.>
