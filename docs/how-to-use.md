# How to use this template

A practical walk through the Claude Code best practices, with each idea pointing at the file in
this template that implements it. Read [`diagrams.md`](diagrams.md) alongside this — the pictures
carry a lot of it.

## The mental model: who decides?

Every instruction you give Claude is one of two kinds. Getting a result you want reliably is
mostly about putting each instruction in the right kind.

| | Non-deterministic — **Claude decides** | Deterministic — **the harness enforces** |
| :-- | :-- | :-- |
| What to do | prompt, `CLAUDE.md`, rules, skills Claude self-starts | hooks, skills only you can start |
| What it can touch | auto mode's classifier | deny rules, the sandbox |
| When it's done | asking for evidence, `/code-review`, `/goal` | tests, a `Stop` hook, CI |
| How much it spends | effort level, Claude's own pace | `--max-turns`, `--max-budget-usd`, spend limit |

Most of the time you *want* Claude to decide — with the code in front of it, it judges whether a
guideline fits better than a rule you wrote in advance. Reach for the deterministic kind only for
things that must **always** or **never** happen.

> Rule of thumb: if you keep adding emphasis to a `CLAUDE.md` line and Claude still misses it,
> that line belongs in a hook. If you have hooks for things that are only preferences, delete them.

The four sections below are the four ways a session goes wrong, and the fix for each.

---

## 1. Tell Claude what it can't see

*Symptom: Claude built the wrong thing, or rediscovers the same fact every session.*

Claude reads your code at the start of every task and is very good at it — it already knows your
layout, conventions, and test framework. Only write down what was **never in the repo**, or what
costs real time to re-dig every session.

- **`CLAUDE.md`** — keep it short (aim < 200 lines); it loads on *every* task. The template's
  version has three sections (Commands, Conventions, Gotchas) and nothing else. Use `/init` to
  draft it from a real codebase, then cut; `/doctor` and `/doctor prompt-audit` suggest cuts;
  `/context all` confirms it loaded.
- **`.claude/rules/example-api.md`** — a rule that only matters in one part of the tree. The
  `paths:` filter means it loads only when Claude works there, so it costs nothing elsewhere.
- **Skills** (`.claude/skills/*/SKILL.md`) — team procedures and knowledge. Lighter than
  `CLAUDE.md`: Claude sees only the name and description until a task actually needs the file.
  `pr-description` is knowledge Claude may use on its own; `spec` and `release` set
  `disable-model-invocation: true` so they run only when you type `/spec` or `/release`.
- **Write specific prompts.** Name the file, describe the symptom, say what "fixed" looks like.
  Hand over what you have — `@path/to/file`, a pasted screenshot, `cat err.log | claude -p "…"`.
  Say `be ambitious` when you want the fuller version (that's scope, which only you know).
  `ultrathink` on a single prompt buys deeper reasoning for that turn.
- **Brainstorm first** when you're not sure what you want: that's what `/spec` is for — it
  interviews you until the answers add up to `SPEC.md`, then you build from it in a fresh session.
- **Connect tools** Claude can't see: a CLI like `gh` just works; otherwise add an MCP server —
  either `claude mcp add …` or copy `.mcp.json.example` → `.mcp.json` (project-scoped and
  committed, so it's shared with the repo). Each connected server adds its tool names and
  instructions to context even when idle, so turn off the ones you're not using.

---

## 2. Give Claude a check to run

*Symptom: Claude said it was done and it wasn't — it had no way to check its own work.*

Give Claude something that comes back pass/fail and it closes the loop itself: change, run,
read the failure, fix, run again. The check can be a test, a build exit code, a linter, or a
screenshot next to a mockup. **The single most useful line in `CLAUDE.md` is the command that
runs your check** — that's why the template's Commands section exists.

Strictness runs from "Claude decides" to "harness enforces":

- **In the prompt:** `run the auth tests after and keep going until they pass`. No setup.
- **As a goal:** `/goal all tests in tests/auth pass and lint is clean` — a separate model checks
  after every turn and sends Claude back if it ended early. Mostly for long background runs.
- **As a Stop hook:** `.claude/hooks/check.sh` (opt-in). Exit 2 blocks the turn from ending until
  the check passes. Its header has the `settings.json` snippet. Wire it once your check is stable.
- **A fresh reviewer:** `/code-review` in the terminal, or the **`reviewer` subagent** in this
  template — it has `tools: Read, Grep, Glob`, so it literally can't edit, and it never saw the
  conversation that produced the code.

Two rules for reviews: **always ask for evidence** (the command and its output, or the
screenshot — "all tests pass" tells you nothing), and when reviewing against a spec, **say
`skip style`** — a reviewer told to find problems always finds something, and fixing every
finding buries you in needless abstraction. `/verify` has Claude build and run the app to catch
what tests miss.

---

## 3. Enforce the rules that can't bend

*Symptom: Claude did something that must never happen, or skipped a step that must always happen.*

A `CLAUDE.md` line is followed *almost* every time. For the cases where "almost" isn't good
enough, move it into config the harness applies itself.

- **Hooks** (`.claude/settings.json` + `.claude/hooks/`) run your command at fixed points:
  - `PostToolUse` → `format.sh`: formats every edited file. Active, safe anywhere.
  - `PreToolUse` → `protect-paths.sh`: blocks edits to paths you list (exit 2). Empty by default.
  - `scan-secrets.sh`: opt-in, blocks a commit when gitleaks finds a secret. Add
    `"onFailure": "block"` so the commit is stopped even if the scanner itself crashes.
  - A `prompt`/`agent` hook asks *another model* to decide, so it is **not** deterministic — use
    `command` or `http` hooks for real enforcement.
- **Permission rules** (`.claude/settings.json` → `permissions`): `deny` holds in *every* mode,
  including auto and bypass — which is why `Read(./.env)` lives there. `ask` prompts you first
  (the template asks before `git push`). Rules match **tool calls, not intent**: the `Read` deny
  catches `cat .env`, but not a script that opens the file.
- **The sandbox** (`/sandbox`) adds an OS-level limit on filesystem/network and picks up your
  `Read` deny and `WebFetch(domain:…)` rules — turn it on for anything security-sensitive, since
  a `WebFetch` deny alone won't stop `curl` to the same domain.
- **Who a rule applies to** is decided by where it lives: `.claude/settings.local.json` and
  `~/.claude/settings.json` are yours alone; committed `.claude/settings.json` applies to everyone
  in the repo; managed settings belong to the org and can't be overridden.

Keep the enforced set small. A rule with real exceptions (`prefer named exports`) stays a
guideline in `CLAUDE.md` — a hook is only for zero-exception rules.

---

## 4. Change a default

*Symptom: Claude got it right, but it cost more time, tokens, or prompts than it should have.
Run `/usage` to see where it went.*

- **Permission mode** — interactive sessions start in **auto mode**: Claude runs routine actions
  without asking, and a classifier stops the dramatic things (`curl | bash`, prod deploys, force
  pushes over others' work). This runs *after* your deny/ask rules and hooks, so those still win.
  `Shift+Tab` cycles modes; `/fewer-permission-prompts` builds an allowlist from your transcripts.
  Tune a classifier that keeps stopping routine work via `autoMode` in `~/.claude/settings.json`
  (keep `"$defaults"` in every list).
- **Effort** — the real control for how hard Claude thinks (not `think harder` in the prompt).
  Default `medium`. `/effort high` or `xhigh` for bugs in code you didn't write, flaky tests, or
  wide schema changes; `/effort low` for quick back-and-forth you're reviewing anyway; `max` only
  for a hard problem you want solved unattended. `/model fable` or `/model sonnet` to switch model.
- **Subagents** — Claude delegates on its own (Explore for searches, forks for side tasks). They
  buy parallelism, a clean main context, and fresh-eyes review — **not** a smarter answer on the
  same task. Each one spends its own tokens. Give simple ones `model: haiku`, ask for short
  summaries back, and check `/usage` to see which earn their cost.
- **Cost & context** — every request re-sends the whole conversation. `/clear` between unrelated
  tasks (name it: `/clear oauth-migration`), `/compact keep the API changes` to summarize with a
  focus, and watch background work (`/loop`, a goal's per-turn check) that keeps spending while
  you're idle.

---

## Steer the session

No config replaces watching the first minute.

- **`Esc`** stops Claude mid-action and keeps the work so far — redirect without losing it.
- **`/rewind`** (or `Esc` twice on an empty prompt) rolls code, conversation, or both back to an
  earlier point. Makes it cheap to try the bolder approach and undo if it misses. *Caveat:*
  checkpoints only cover files Claude edited with its file tools — a file changed by a Bash
  command isn't restored. Use git alongside it.
- **`/clear`** after two failed corrections. A third correction just adds to a context that
  already holds two failed attempts; `/clear` + one better prompt wins almost every time.
- **`/btw`** answers a side question without touching history. **`/rename oauth-migration`** names
  a multi-day session so `claude --resume oauth-migration` picks it up later.

---

## Let Claude run without you

Everything above matters more when nobody's watching. Before an unattended run, answer these five
for that specific task (see the checklist diagram in [`diagrams.md`](diagrams.md)):

1. **Does it know what done looks like?** A goal condition, `SPEC.md`, or a failing test to turn green.
2. **Can it check its own work?** The test suite, the `check.sh` Stop hook, a review step.
3. **What can it touch?** Deny rules, the sandbox, a worktree, the one branch it may push to.
4. **What stops it?** `--max-turns`, `--max-budget-usd`, a spend limit.
5. **Where does the result go, and who signs off?** A PR or summary, then a person approving the merge.

Mechanisms:

- **Headless:** `claude -p "…"` runs once and exits. Add `--allowedTools`, `--permission-mode
  dontAsk`, `--max-turns`. `--bare` skips all project/machine config for a reproducible run
  (so hooks and `CLAUDE.md` don't load). Test on three inputs before looping over the rest.
- **On a schedule/event:** `/loop 15m check CI and fix it if red` repeats inside the session (each
  run is another turn — don't leave it in a long conversation). `/schedule` sets up a cloud task
  that runs while your laptop is closed. **Protect `main` with a branch rule the task can't
  bypass**, and watch the first few runs.
- **In parallel:** `claude -w feature-auth` starts a session in its own worktree so edits can't
  collide. `.worktreeinclude` (in this template) lists the gitignored files to copy in, like
  `.env`. `/batch …` splits one big mechanical change into many worktree units with a plan to approve.

---

## Maintenance

- Re-run `/doctor` and `/doctor prompt-audit` periodically — they catch `CLAUDE.md` lines that
  went stale, point at deleted files, or contradict each other.
- When a hook or deny rule keeps firing where it shouldn't, it was probably a preference, not a
  zero-exception rule. Move it back to `CLAUDE.md` or delete it.
- **What you can stop doing** (current models made these unnecessary): managing the context window
  aggressively, adding `IMPORTANT`/ALL CAPS to lines Claude misses, `think harder`/`be thorough`,
  "keep going, don't be lazy", and describing your architecture and file layout in `CLAUDE.md`.
  Claude reads the repo itself — only write what isn't in there.
