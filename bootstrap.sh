#!/usr/bin/env bash
# Copy this template's Claude Code setup into another project.
#
#   ./bootstrap.sh /path/to/your/project
#
# Copies CLAUDE.md, .claude/, .gitignore entries, .worktreeinclude, and the examples.
# Never overwrites an existing file — it skips and tells you. Safe to re-run.
set -euo pipefail

dest="${1:-}"
if [ -z "$dest" ]; then
  echo "usage: ./bootstrap.sh /path/to/your/project" >&2
  exit 1
fi
if [ ! -d "$dest" ]; then
  echo "error: '$dest' is not a directory" >&2
  exit 1
fi

src="$(cd "$(dirname "$0")" && pwd)"

copy() {
  local rel="$1" from="$src/$1" to="$dest/$1"
  [ -e "$from" ] || return 0
  if [ -e "$to" ]; then
    echo "  skip (exists): $rel"
    return 0
  fi
  mkdir -p "$(dirname "$to")"
  cp "$from" "$to"
  echo "  copied:        $rel"
}

echo "Seeding Claude Code template into: $dest"

copy "CLAUDE.md"
copy "CLAUDE.local.md.example"
copy ".worktreeinclude"
copy ".mcp.json.example"
copy ".claude/settings.json"
copy ".claude/settings.local.json.example"
copy ".claude/agents/reviewer.md"
copy ".claude/rules/example-api.md"
copy ".claude/skills/pr-description/SKILL.md"
copy ".claude/skills/spec/SKILL.md"
copy ".claude/skills/release/SKILL.md"
copy ".claude/hooks/format.sh"
copy ".claude/hooks/protect-paths.sh"
copy ".claude/hooks/check.sh"
copy ".claude/hooks/scan-secrets.sh"
chmod +x "$dest"/.claude/hooks/*.sh 2>/dev/null || true

# Merge .gitignore entries without clobbering an existing one.
ignore_block=$'\n# --- Claude Code (added by template bootstrap) ---\nCLAUDE.local.md\n.claude/settings.local.json\n.env\n.env.*\n!.env.example\nsecrets/\n'
if [ -f "$dest/.gitignore" ]; then
  if ! grep -q "CLAUDE.local.md" "$dest/.gitignore"; then
    printf '%s' "$ignore_block" >> "$dest/.gitignore"
    echo "  appended:      .gitignore (Claude Code entries)"
  else
    echo "  skip (exists): .gitignore already has Claude Code entries"
  fi
else
  copy ".gitignore"
fi

cat <<'EOF'

Done. Next, in the new project:
  1. Open it with Claude Code and run `/init` to draft CLAUDE.md from the real code, then trim.
  2. Fill the Commands section of CLAUDE.md with your real install/test/typecheck/lint commands.
  3. Keep the skills/rules/hooks you want; delete the rest (the examples are there to be cut).
  4. See docs/how-to-use.md in the template for what each piece is for.
EOF
