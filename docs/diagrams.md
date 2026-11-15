# Diagrams

Mermaid diagrams for the practices in [`how-to-use.md`](how-to-use.md). They render on GitHub and
in most Markdown viewers.

## 1. Where does this instruction go?

The single most useful decision. Start from what you want and follow it to the right file.

```mermaid
flowchart TD
    A["I want Claude to behave a certain way"] --> B{"Must it happen<br/>EVERY time<br/>(zero exceptions)?"}
    B -- "No, it's a guideline" --> C{"Does it apply<br/>everywhere, or just<br/>one part of the tree?"}
    C -- "Everywhere" --> D["CLAUDE.md<br/>(keep it short)"]
    C -- "One area" --> E[".claude/rules/*.md<br/>with a paths: filter"]
    C -- "It's a procedure<br/>or team knowledge" --> F[".claude/skills/<name>/SKILL.md"]
    B -- "Yes, always/never" --> G{"Is it about what<br/>Claude may TOUCH?"}
    G -- "Yes" --> H["permissions deny / ask<br/>in .claude/settings.json<br/>(+ sandbox for OS-level)"]
    G -- "No, it's a STEP<br/>to run" --> I["Hook in .claude/settings.json<br/>→ .claude/hooks/*.sh"]
    F --> J{"Does it have<br/>side effects<br/>(deploy, publish)?"}
    J -- "Yes" --> K["add disable-model-invocation: true<br/>→ runs only when you type /name"]
    J -- "No" --> L["Claude may start it on its own"]

    classDef nd fill:#e8f0fe,stroke:#4285f4,color:#111;
    classDef det fill:#fde8e8,stroke:#db4437,color:#111;
    class D,E,F,K,L nd;
    class H,I det;
```

Blue = **non-deterministic** (Claude decides). Red = **deterministic** (the harness enforces).

## 2. What loads, and when

`CLAUDE.md` costs attention on every task; skills and rules are nearly free until needed.

```mermaid
flowchart LR
    S(["Session starts"]) --> L1["CLAUDE.md — loaded ALWAYS"]
    S --> L2["Skill names + descriptions — loaded ALWAYS<br/>(full SKILL.md only when a task needs it)"]
    S --> L3[".claude/settings.json — permissions & hooks active"]
    T(["Claude edits a file<br/>under a rule's paths:"]) --> L4[".claude/rules/*.md — loaded ON DEMAND"]
    S -.-> N["CLAUDE.local.md — your prefs, gitignored"]

    classDef always fill:#fef7e0,stroke:#f9ab00,color:#111;
    classDef ondemand fill:#e6f4ea,stroke:#34a853,color:#111;
    class L1,L2,L3 always;
    class L4 ondemand;
```

> Takeaway: put always-relevant, can't-read-from-code facts in `CLAUDE.md`; push area-specific
> rules into `.claude/rules/` and long procedures into skills so they don't weigh on every task.

## 3. The "give Claude a check" loop

A check that returns pass/fail lets Claude close the loop itself instead of making you the test suite.

```mermaid
flowchart TD
    A["Claude makes a change"] --> B["Run the check<br/>(test / build / lint / screenshot)"]
    B --> C{"Pass?"}
    C -- "No" --> D["Read the failure output"] --> A
    C -- "Yes" --> E["Report evidence:<br/>the command + its output"]
    E --> F["Human reviews / signs off"]
```

Enforcement ladder for the same check — pick as much teeth as the task needs:

```mermaid
flowchart LR
    P["Prompt:<br/>'keep going until tests pass'"] --> G["/goal:<br/>checked after every turn"]
    G --> H["Stop hook (check.sh):<br/>turn can't end until it passes"]
    H --> R["/code-review or reviewer subagent:<br/>fresh eyes, never saw the code"]

    classDef soft fill:#e8f0fe,stroke:#4285f4,color:#111;
    classDef hard fill:#fde8e8,stroke:#db4437,color:#111;
    class P,G soft;
    class H hard;
    class R soft;
```

## 4. How a tool call is evaluated

Your deterministic controls run **before** auto mode's classifier, so a deny rule always wins.

```mermaid
flowchart TD
    A["Claude wants to run a tool"] --> B{"deny rule matches?"}
    B -- "Yes" --> X["Blocked — every mode, no exceptions"]
    B -- "No" --> C{"ask rule matches?"}
    C -- "Yes" --> Q["Prompt you first"]
    C -- "No" --> D{"PreToolUse hook?<br/>(e.g. protect-paths.sh)"}
    D -- "exit 2" --> X
    D -- "ok" --> E{"Auto mode classifier:<br/>risky? (curl|bash, prod<br/>deploy, force push…)"}
    E -- "Yes" --> Y["Blocked — you get notified,<br/>can approve a retry"]
    E -- "No" --> Z["Runs"]
    Z --> F["PostToolUse hook<br/>(e.g. format.sh)"]

    classDef det fill:#fde8e8,stroke:#db4437,color:#111;
    classDef cls fill:#fff3e0,stroke:#f9ab00,color:#111;
    class B,C,D,F det;
    class E cls;
```

## 5. Before you leave a run unattended

The five questions. If you can't answer one, the run isn't ready to go unwatched.

```mermaid
flowchart LR
    Q1["1. Knows what<br/>DONE looks like?<br/>goal / SPEC.md /<br/>failing test"] --> Q2["2. Can CHECK<br/>its own work?<br/>tests / Stop hook /<br/>review"]
    Q2 --> Q3["3. What can it<br/>TOUCH?<br/>deny rules / sandbox /<br/>worktree / one branch"]
    Q3 --> Q4["4. What STOPS it?<br/>--max-turns /<br/>--max-budget-usd /<br/>spend limit"]
    Q4 --> Q5["5. Where does the<br/>RESULT go, who<br/>SIGNS OFF?<br/>PR + human approves merge"]

    classDef q fill:#e8f0fe,stroke:#4285f4,color:#111;
    class Q1,Q2,Q3,Q4,Q5 q;
```
