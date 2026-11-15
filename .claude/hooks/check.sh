#!/usr/bin/env bash
# Stop hook (OPT-IN — not wired in settings.json by default).
#
# Runs your "is it actually done?" check whenever Claude tries to end its turn.
# Exit 2 sends Claude back to work with the check output (on stderr) as the reason,
# so the turn can't end until the check passes. This is the harness-enforced version
# of "run the tests and keep going until they pass".
#
# Wire it only once your check command is stable — add to .claude/settings.json:
#
#   "hooks": {
#     "Stop": [
#       { "hooks": [ { "type": "command",
#         "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/check.sh" } ] }
#     ]
#   }
#
# Claude Code overrides the block after 8 in a row (raise with CLAUDE_CODE_STOP_HOOK_BLOCK_CAP).
set -u

fail=0

# --- Replace the body below with your project's real check(s). ---
if [ -f package.json ] && grep -q '"typecheck"' package.json; then
  npm run -s typecheck 1>&2 || fail=1
fi

# Examples for other stacks (uncomment what applies):
#   pytest -q 1>&2            || fail=1
#   npx tsc --noEmit 1>&2     || fail=1
#   cargo check 1>&2          || fail=1
#   go build ./... 1>&2       || fail=1
# -----------------------------------------------------------------

[ "$fail" -eq 0 ] || exit 2
exit 0
