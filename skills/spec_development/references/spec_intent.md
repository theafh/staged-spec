# Spec Intent

The Project Intent Summary (`specs/intent.md`) captures the non-negotiable identity of the project. It acts as a guardrail for the entire project -- every spec and every line of code must stay within the bounds it defines.

## Intent Structure

The intent document uses six sections:

### 1. Core Purpose (1-2 sentences)

What problem does this system solve, and for whom?

### 2. Architectural Commitments

Non-negotiable structural decisions -- the choices that, if violated, would mean the project has drifted from its intent. Only include commitments that are load-bearing for the project's identity.

### 3. Domain Boundaries

What this system is explicitly responsible for and what is explicitly out of scope. Frame as "This system DOES X. This system DOES NOT do Y." Be concrete -- vague boundaries don't catch drift.

### 4. Key Invariants

Properties that must hold true across all future development. If broken, they indicate either a bug or unintended scope creep.

### 5. Integration Contract Surface

External systems this project touches, and the nature of each contract: inbound vs. outbound, sync vs. async, owned vs. consumed. This defines where the system ends and the world begins.

### 6. Intentional Constraints

Decisions that look like limitations but are deliberate. These are the things a well-meaning contributor -- or agent -- might "fix" without realizing they're violating intent.

## Modification Rules

The intent document is a guardrail — it governs all other specs but is not governed by them.

- Never create, modify, or delete `specs/intent.md` as a side-effect of stage creation, refinement, implementation, or status updates.
- Changes require an explicit, direct request from the human user in the current conversation.
- When a spec change appears to conflict with the intent document, fix the spec to align with the intent. Escalate to the user when alignment requires a trade-off or when the conflict touches a core architectural commitment.

## Creation Rules

- Each item must be falsifiable -- someone should be able to hold it against a diff, a new spec stage, or an agent's output and get a binary yes/no on consistency.
- If the specs are ambiguous or silent on something that should be stated, flag it as `[UNDERSPECIFIED]` rather than inferring intent.
- Prefer 15-25 items total across all sections. Fewer if the system is genuinely simple. More means you're drifting into implementation detail.
- No implementation details (no file paths, function names, library versions) -- this is a summary of what and why, not how.

## Validation Rules

When validating specs or code against the intent document, check each item against every intent section:

- **Core Purpose** -- does it solve a different problem or serve a different audience than the one the intent defines?
- **Architectural Commitments** -- does it introduce a pattern the intent rules out?
- **Domain Boundaries** -- does it take responsibility for something the intent marks as out of scope, or ignore something the intent marks as in scope?
- **Key Invariants** -- does it introduce a path that violates a property the intent declares must always hold?
- **Integration Contract Surface** -- does it change the nature of an external contract the intent defines?
- **Intentional Constraints** -- does it remove or work around a limitation the intent marks as deliberate?

For items flagged `[UNDERSPECIFIED]` in the intent document, do not infer intent -- skip that area.

Order violations by how much damage they would cause if shipped. Place the violation most likely to produce a fundamentally wrong outcome first. For each violation, ask: "If this shipped, would the system behave in a way the intent explicitly forbids, or would it merely drift from its intended shape?" The closer the answer is to "explicitly forbidden behavior," the higher it belongs in the list.
