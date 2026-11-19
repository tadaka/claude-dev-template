#!/usr/bin/env bash
# Run Claude Code inside a disposable container, with the current project bind-mounted.
#
#   docker/claude-docker.sh [--build] [--yolo] [-- CLAUDE ARGS...]
#
#   --build   (re)build the image before running (also happens automatically if it's missing)
#   --yolo    add --dangerously-skip-permissions. Safe here BECAUSE the container is
#             disposable and isolated from your host — don't pass this on a bare-metal session.
#   anything else is passed straight through to `claude`, e.g.:
#   docker/claude-docker.sh -p "reply OK"      docker/claude-docker.sh --yolo
#
# Auth (both supported): if ANTHROPIC_API_KEY is set it's passed in; and if ~/.claude exists
# it's mounted so your claude.ai login and session history persist across runs.
set -euo pipefail

IMAGE="claude-dev:local"
# Resolve the docker/ dir regardless of where the script is called from — it's the build context.
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

command -v docker >/dev/null 2>&1 || { echo "error: docker is not installed or not on PATH." >&2; exit 1; }

build=0
yolo=0
claude_args=()
while [ "$#" -gt 0 ]; do
  case "$1" in
    --build) build=1 ;;
    --yolo)  yolo=1 ;;
    --help|-h)
      awk 'NR>1 && /^#/ {sub(/^# ?/,""); print; next} NR>1 {exit}' "$0"
      exit 0 ;;
    --) shift; claude_args+=("$@"); break ;;
    *) claude_args+=("$1") ;;
  esac
  shift
done

if [ "$build" -eq 1 ] || ! docker image inspect "$IMAGE" >/dev/null 2>&1; then
  echo "Building $IMAGE ..." >&2
  docker build -t "$IMAGE" "$SCRIPT_DIR"
fi

run_args=(-it --rm -v "$PWD:/workspace" -w /workspace)

# Auth: API key if present, mounted login if present (either or both).
if [ -n "${ANTHROPIC_API_KEY:-}" ]; then
  run_args+=(-e ANTHROPIC_API_KEY)
fi
if [ -d "$HOME/.claude" ]; then
  run_args+=(-v "$HOME/.claude:/home/node/.claude")
fi
# Reuse the host's git identity for commits made in the container.
if [ -f "$HOME/.gitconfig" ]; then
  run_args+=(-v "$HOME/.gitconfig:/home/node/.gitconfig:ro")
fi

if [ "$yolo" -eq 1 ]; then
  claude_args+=(--dangerously-skip-permissions)
fi

exec docker run "${run_args[@]}" "$IMAGE" claude ${claude_args[@]+"${claude_args[@]}"}
