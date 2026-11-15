---
name: spec
description: Interview me about a feature until the answers add up to a spec, then write SPEC.md. Start here when the work isn't fully thought through yet.
disable-model-invocation: true
---
`disable-model-invocation: true` means Claude can't start this on its own — it runs only when
I type `/spec`. Don't start building. Interview me first.

1. Ask multiple-choice questions, a few at a time, about the parts I haven't pinned down:
   scope boundaries, the shape of the data, failure behavior, what's explicitly out of scope.
2. Keep going until you could write the spec without guessing.
3. Write SPEC.md with: **Goal**, **Non-goals**, **Behavior**, **Edge cases** (each one testable),
   **Open questions**.
4. Stop. Tell me to review SPEC.md and start a FRESH session to build from it — so the build
   begins with a clean context and a written definition of done.
