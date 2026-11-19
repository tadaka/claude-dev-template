# claude-dev-template

A reusable Claude Code setup to drop into every new project. It turns the
[Best practices for Claude Code](https://code.claude.com/docs/en/best-practices) into concrete
files so each project starts with the same habits already wired in.

The one idea behind all of it: **decide what Claude gets to decide, and nail down what it
doesn't.** Guidance goes where the model reads it (CLAUDE.md, rules, skills). Rules that must
never bend go where the harness enforces them (hooks, deny rules). See
[`docs/how-to-use.md`](docs/how-to-use.md) for the full walkthrough and
[`docs/diagrams.md`](docs/diagrams.md) for the diagrams.

## Quick start

```bash
# From this template directory:
./bootstrap.sh /path/to/your/project
```

Then, in the new project:

1. Open it with Claude Code and run `/init` to draft `CLAUDE.md` from the real code — then **cut** it down.
2. Fill the **Commands** section of `CLAUDE.md` with your real install / test / typecheck / lint commands.
3. Keep the skills, rules, and hooks you want; **delete the rest**. The examples exist to be cut.
4. Copy `CLAUDE.local.md.example` → `CLAUDE.local.md` and `.claude/settings.local.json.example`
   → `.claude/settings.local.json` for anything that's yours alone (both are gitignored).

Prefer not to script it? `git clone` this repo, copy `CLAUDE.md` and `.claude/` into your
project, and delete the `.git` history.

## What's in here

| Path | Kind | What it's for |
| :-- | :-- | :-- |
| `CLAUDE.md` | non-deterministic | Short, always-loaded context. Only what Claude can't read from the code. |
| `CLAUDE.local.md.example` | non-deterministic | Your personal, gitignored preferences. |
| `.claude/rules/example-api.md` | non-deterministic | A rule scoped to one part of the tree (`paths:` filter). |
| `.claude/skills/pr-description/` | non-deterministic | Team knowledge Claude may use on its own. |
| `.claude/skills/spec/` | non-deterministic | `/spec` — interview-to-spec workflow (you invoke it). |
| `.claude/skills/release/` | non-deterministic | `/release` — side-effectful, model can't self-start it. |
| `.claude/agents/reviewer.md` | non-deterministic | Read-only reviewer subagent (can't edit — enforced). |
| `.mcp.json.example` | non-deterministic | Sample MCP servers; copy to `.mcp.json` to connect tools Claude can't see. |
| `.claude/settings.json` | **deterministic** | Permission deny/ask rules + active hooks. |
| `.claude/hooks/format.sh` | **deterministic** | Formats every edited file (guarded, safe no-op). |
| `.claude/hooks/protect-paths.sh` | **deterministic** | Blocks edits to paths you list (empty by default). |
| `.claude/hooks/check.sh` | **deterministic** | Opt-in Stop hook: don't finish until the check passes. |
| `.claude/hooks/scan-secrets.sh` | **deterministic** | Opt-in: block a commit if gitleaks finds a secret. |
| `.worktreeinclude` | harness | Gitignored files to copy into parallel worktrees. |
| `docker/Dockerfile` | — | Node + Claude Code CLI + basic dev tools (git, jq, ripgrep). |
| `docker/entrypoint.sh` | — | Container entrypoint (marks the mounted workspace safe for git). |
| `docker/claude-docker.sh` | — | Runs Claude Code in a disposable container with the project mounted. |
| `bootstrap.sh` | — | Copies this setup into another project. |

## The two active hooks are safe anywhere

`format.sh` only runs a formatter that's **already installed** (never `npx`-installs one) and
always exits 0, so it can't block. `protect-paths.sh` has an **empty** list by default, so it's
a no-op until you add paths. The `check.sh` and `scan-secrets.sh` hooks are **opt-in** — their
headers show the `settings.json` snippet to wire them once you're ready.

## Run in a container (optional)

Prefer not to install Node and Claude Code on the host, or want a disposable sandbox? From a
project that has the `docker/` files (Docker required):

```bash
docker/claude-docker.sh            # build on first run, then start Claude Code in ./ mounted at /workspace
docker/claude-docker.sh --build    # force a rebuild (e.g. after editing the Dockerfile)
docker/claude-docker.sh --yolo     # add --dangerously-skip-permissions — safe only because the container is disposable
docker/claude-docker.sh -p "..."   # pass any args straight through to claude (headless, etc.)
```

Auth works either way: export `ANTHROPIC_API_KEY` and it's passed in, and/or your host `~/.claude`
(claude.ai login + history) is mounted when it exists. The image ships `git`, `jq` (the template
hooks need it), and `ripgrep`. See [`docs/how-to-use.md`](docs/how-to-use.md#run-claude-code-in-a-container).

## Keep the enforced set small

Every hook and deny rule occasionally fires when it shouldn't, and each one is yours to
maintain. If you reach for a fortieth, most are probably preferences Claude could have weighed
on its own — move those back to `CLAUDE.md` or delete them.
