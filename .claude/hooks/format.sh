#!/usr/bin/env bash
# PostToolUse(Edit|Write): format the file Claude just edited.
#
# Why a hook and not a CLAUDE.md line: "always format after editing" is a rule with
# zero exceptions, so it belongs where the harness enforces it, not where the model
# may decide to skip it. See docs/how-to-use.md — "Enforce the rules that can't bend".
#
# Safe for any project: it only runs a formatter that is ALREADY installed locally,
# never auto-installs, and always exits 0 so a formatting hiccup can't block Claude.
set -u

input=$(cat)
file=$(printf '%s' "$input" | jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$file" ] && exit 0
[ -f "$file" ] || exit 0

run() { "$@" >/dev/null 2>&1 || true; }

# JS/TS/web: only if the project vendored prettier (never `npx`, which would install it).
if [ -x node_modules/.bin/prettier ]; then
  case "$file" in
    *.js|*.jsx|*.ts|*.tsx|*.mjs|*.cjs|*.json|*.css|*.scss|*.less|*.md|*.mdx|*.yaml|*.yml|*.html)
      run node_modules/.bin/prettier --write --ignore-unknown "$file" ;;
  esac
fi

case "$file" in
  *.py)  command -v ruff    >/dev/null 2>&1 && run ruff format "$file" ;;
  *.rs)  command -v rustfmt >/dev/null 2>&1 && run rustfmt "$file" ;;
  *.go)  command -v gofmt   >/dev/null 2>&1 && run gofmt -w "$file" ;;
esac

exit 0
