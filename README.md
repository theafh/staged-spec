# StagedSpec

StagedSpec is a human-steered, AI-assisted methodology for producing implementation-ready software specifications through iterative refinement. It operates inside an agentic coding IDE where a human directs an AI assistant through repeated draft-assess-refine cycles until the spec is good enough for the AI to implement in a single pass.

## Core Model

One spec at a time. The human and AI focus on the next stage to be implemented — like a surfer riding the current wave. The AI has access to all prior specs and a living record of already-implemented features, giving it full project context. Future stages exist as sketches that sharpen only when their turn comes.

## Artifacts

All specs live in a `/specs` folder. Four shared files provide project-wide context:

- **`architecture.md`** — single index and entry point. Links every stage, tracks status, lists global constraints, and maintains an out-of-scope section and a future-features list.
- **`intent.md`** — Project Intent Summary. Captures the non-negotiable identity of the project: core purpose, architectural commitments, domain boundaries, key invariants, integration contracts, and intentional constraints. Every item is falsifiable — it can be held against a diff, a spec, or an agent's output and produce a binary yes/no on consistency. The intent document acts as a guardrail for the entire project, preventing drift in both specs and code even when individual stages are correct in isolation.
- **`features.md`** — behavior-first record of what the system currently does. Updated immediately after each stage is verified. Describes observable runtime outcomes, not internals.
- **`testing.md`** — project-wide test methodology, aligned to the stack. Pulled into every spec so testing strategy is consistent.

Optional: **`security.md`** for cross-cutting security constraints.

Each stage is a single self-contained file following strict naming:

- `v<version>-stage-<number>-<short-name>.md` when order is committed
- `v<version>-<short-name>.md` for unordered future features

Version tiers (v1 = minimum working product, v2 = core differentiators, v3 = advanced) are optional but useful for layering ambition.

## Stage Structure

Every stage file uses the same required sections:

1. **Title** — stage name
2. **Status** — Planned | In Progress | Implemented
3. **Goal** — one sentence, the outcome
4. **Dependencies and prior links** — what this stage builds on
5. **Read first** (optional) — prerequisite docs like security.md or testing.md
6. **Desired behavior (specification)** — what the stage delivers, stated concretely before any execution detail
7. **Scope boundary** — what belongs to this stage and what doesn't
8. **Implementation steps** — how to build it
9. **Tests and verification** — how to prove it works
10. **Documentation updates** — what to update in features.md and elsewhere
11. **Out of scope** — explicitly excluded, including future-stage notes when they reduce ambiguity

Paragraph discipline: one requirement per paragraph, outcomes before implementation detail, consistent terminology across all files.

## The Refinement Loop

This is where the methodology lives. The cycle:

1. **Human describes intent.** What the next stage should accomplish, any constraints, any design preferences.
2. **AI drafts the stage spec** using the stage structure, informed by architecture.md, features.md, existing specs, and any research documents the human has provided.
3. **AI assesses the draft** against implementation-readiness criteria: contradictions, missing requirements, ambiguous contracts, dependency problems, logical gaps, unstated assumptions. Issues are severity-ranked (Critical, High, Medium, Minor) and each explained in one paragraph with the problem, its implementation impact, and the minimum fix.
4. **Human reads the assessment**, decides what matters, and tells the AI what to change. The human may agree, disagree, reprioritize, or redirect.
5. **AI revises and re-assesses.** Back to step 3.

The loop repeats until the human decides to stop. Stop signals:

- AI suggestions no longer meaningfully improve the spec
- AI starts over-specifying or constraining implementation unnecessarily
- AI begins nitpicking minor wording issues

The human — not the AI — decides when "good enough" is reached. The assessment's severity classifications inform but do not control the decision.

## Research Integration

Research happens outside the refinement loop. The human investigates independently or provides reference documents (technical analyses, library comparisons, architectural decisions) that the AI incorporates during drafting. Complex aspects are documented separately and fed directly into spec creation. There is no formal research phase — the human brings knowledge in whatever form it exists.

## Scope Management

The spec set functions as a semi-manual DAG. The human manages scope through several mechanisms:

- **Splitting**: when a stage outgrows its focus, it splits into multiple stages.
- **Deferring**: features that don't belong in the current stage move to future stages or later versions.
- **Strict layering**: each stage depends only on prior stages. No forward dependencies. Each stage must be implementable, runnable, and testable without anything that comes after it.
- **Version ordering**: v2 builds on all of v1 completed, v3 on v2, and numbered stages build on earlier stages within their version.

Future stages stay unordered (no stage number) until their order is committed, then get renamed to reflect dependency order.

## Implementation Handoff

When the human calls the loop done, the AI implements the spec in a single pass. The spec is the complete implementation contract — the AI should be able to build the stage from the spec alone, without further clarification.

## Marking Done

A stage is marked Implemented only when:

- Claimed behavior is verified in the actual codebase (not inferred from plans)
- Tests are listed and reflect observable behavior
- Implemented behavior is documented in features.md in behavior-first form
- Status is synchronized across architecture.md and the stage file

A mandatory cross-file consistency check runs before any status update: statuses must match across files, and no planned or hallucinated behavior can be documented as implemented.

## Commands

Commands automate common operations within the StagedSpec workflow:

- **`spec_check`** — reviews a spec for implementation readiness against quality and structure criteria
- **`spec_audit`** — audits an implementation against its spec, reporting gaps between what was specified and what was built
- **`spec_implement`** — implements a spec in a single pass, verifying all details and running tests until everything passes
- **`spec_feature_update`** — updates `features.md` to reflect actual implemented behavior in the codebase
- **`spec_create_intent`** — analyzes all documents in `/specs` and produces the Project Intent Summary (`intent.md`). This is the foundation for intent-based guardrails: it distills the project's non-negotiable decisions, boundaries, and constraints into falsifiable items that can be validated against any future change
- **`spec_validate_intent`** — validates specs, code, or both against `intent.md` and reports violations ordered by severity. Accepts whatever the user provides as context -- a specific file, a qualifier like "only specs" or "only code", or nothing (which validates everything). This is the enforcement side of the intent guardrail, catching drift that stage-level checks would miss

Together, `spec_create_intent` and `spec_validate_intent` form a project-wide guardrail layer. Individual stage specs ensure each piece is internally sound and implementation-ready. The intent document ensures the pieces stay true to the project's identity -- its commitments, boundaries, invariants, and deliberate constraints. The auto spec check agent also validates intent alignment during its review cycle, so intent violations surface both during automated spec refinement and on-demand validation.

## Key Properties

- **Single-file contract**: everything the implementer needs is in one stage file. No cross-referencing multiple artifacts.
- **Human as quality ceiling**: iteration depth matches complexity. Simple stages get 2 rounds, complex integrations get 8. No fixed pipeline.
- **Minimal artifact overhead**: stage files + three shared files. No per-stage metadata proliferation.
- **Organic evolution**: specs sharpen as their turn approaches. Future stages remain adjustable. The system resists premature design lock-in.
- **Behavior-first documentation**: features.md records what the system does from the outside, not how it works inside.
