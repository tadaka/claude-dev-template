#!/usr/bin/env bash
# PreToolUse(Bash) hook (OPT-IN — not wired in settings.json by default).
#
# Scans staged changes for secrets before a `git commit`. No-op for any other command.
# Exit 2 blocks the commit. Pair it with "onFailure": "block" in settings so the commit
# is still stopped if the scanner itself crashes or times out:
#
#   "hooks": {
#     "PreToolUse": [
#       { "matcher": "Bash", "onFailure": "block", "hooks": [ { "type": "command",
#         "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/scan-secrets.sh" } ] }
#     ]
#   }
#
# Uses gitleaks if installed; otherwise it exits 0 (install gitleaks to make it real).
set -u

input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null)

case "$cmd" in
  *"git commit"*) ;;   # proceed
  *) exit 0 ;;
esac

if command -v gitleaks >/dev/null 2>&1; then
  if ! gitleaks protect --staged --redact 1>&2; then
    echo "Blocked: gitleaks found a potential secret in the staged changes." >&2
    exit 2
  fi
fi

exit 0
