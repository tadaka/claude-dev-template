#!/usr/bin/env bash
# Container entrypoint. Prepares git for the bind-mounted workspace, then execs the command
# (by default `claude`, see the Dockerfile CMD / the args claude-docker.sh passes in).
set -e

# The mounted /workspace is owned by the host user, not the container's `node` user, so git
# would otherwise refuse to operate on it ("detected dubious ownership"). Mark it safe.
git config --global --add safe.directory /workspace 2>/dev/null || true

exec "$@"
