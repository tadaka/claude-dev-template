# Claude Code in a container: Node + Claude Code CLI + basic dev tools.
# Build context is this `docker/` directory (see claude-docker.sh), so only the files
# here are sent to the daemon — the project itself is bind-mounted at runtime, not copied.
FROM node:22-bookworm-slim

# Basic dev tools. `jq` is REQUIRED — the template's .claude/hooks/*.sh parse JSON with it.
# This apt list is the main knob to customize per project (add compilers, a DB client, etc.).
RUN apt-get update && apt-get install -y --no-install-recommends \
      git \
      curl \
      ca-certificates \
      jq \
      ripgrep \
      less \
      openssh-client \
      gnupg \
      procps \
      vim \
    && rm -rf /var/lib/apt/lists/*

# Claude Code CLI. Pin a version for reproducible builds, e.g.:
#   RUN npm install -g @anthropic-ai/claude-code@<version>
RUN npm install -g @anthropic-ai/claude-code

COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Run as the image's built-in non-root user (uid 1000). The project is mounted at /workspace.
USER node
WORKDIR /workspace

ENTRYPOINT ["entrypoint.sh"]
CMD ["claude"]
