#!/usr/bin/env bash
# PreToolUse(Edit|Write): block edits to paths that must never change by hand.
#
# Exit 2 = blocked; the stderr message is shown to Claude as the reason.
# A hook (not a CLAUDE.md line) because "never touch X" has to hold every time.
# Keep this list SHORT — only paths with genuinely zero exceptions. A rule with
# exceptions (e.g. "prefer named exports") stays a guideline in CLAUDE.md instead.
#
# Default list is empty, so this is a no-op until you add your own paths.
set -u

PROTECTED=(
  # "src/gen/*"        # generated client — regenerate it, don't edit it
  # "migrations/*"     # applied migrations are immutable
  # "vendor/*"
)

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0

# Normalize to a repo-relative path (case patterns below treat * as matching slashes).
rel="${file#"$PWD"/}"

for pat in ${PROTECTED[@]+"${PROTECTED[@]}"}; do
  # shellcheck disable=SC2254
  case "$rel" in
    $pat)
      echo "Blocked: '$rel' is a protected path (see .claude/hooks/protect-paths.sh)." >&2
      exit 2
      ;;
  esac
done

exit 0
