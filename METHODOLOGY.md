# StagedSpec Methodology

This document is the full reference for the StagedSpec methodology. For a project overview, setup, and commands, see the [README](README.md).

## Core Model

One spec at a time. The human and AI focus on the next stage to be implemented. The AI has access to all prior specs and a living record of already-implemented features, giving it full project context. Future stages exist as sketches that sharpen only when their turn comes.

## Artifacts

All specs live in a `/specs` folder. Five shared files provide project-wide context:

- **`architecture.md`** — single index and entry point. Links every stage, tracks status, lists global constraints, and maintains an out-of-scope section and a future-features list.
- **`intent.md`** — Project Intent Summary. Captures the non-negotiable identity of the project: core purpose, architectural commitments, domain boundaries, key invariants, integration contracts, and intentional constraints. Every item is falsifiable — it can be held against a diff, a spec, or an agent's output and produce a binary yes/no on consistency. The intent document acts as a guardrail for the entire project, preventing drift in both specs and code even when individual stages are correct in isolation.
- **`features.md`** — behavior-first record of what the system currently does. Updated immediately after each stage is verified. Describes observable runtime outcomes, not internals.
- **`testing.md`** — project-wide test methodology, aligned to the stack. Pulled into every spec so testing strategy is consistent.
- **`security.md`** — cross-cutting security constraints.

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
5. **Desired behavior (specification)** — what the stage delivers, stated concretely before any execution detail
6. **Scope boundary** — what belongs to this stage and what doesn't
7. **Implementation steps** — how to build it
8. **Tests and verification** — each top-level item is a verification topic grouping related behavioral checks
9. **Out of scope** — explicitly excluded, including future-stage notes when they reduce ambiguity

Paragraph discipline: one requirement per paragraph, outcomes before implementation detail, consistent terminology across all files.

## The Refinement Loop

This is where the methodology lives. The cycle:

1. **Human describes intent.** What the next stage should accomplish, any constraints, any design preferences.
2. **AI drafts the stage spec** using the stage structure, informed by architecture.md, features.md, existing specs, and any research documents the human has provided.
3. **AI assesses the draft** against implementation-readiness criteria: contradictions, missing requirements, ambiguous contracts, dependency problems, logical gaps, unstated assumptions. Issues are severity-ranked (Critical, High, Medium, Minor) and each explained in one paragraph with the problem, its implementation impact, and the minimum fix.
4. **Human reads the assessment**, decides what matters, and tells the AI what to change. The human may agree, disagree, reprioritize, or redirect.
5. **AI revises and re-assesses.** Back to step 3.

The loop repeats until the driver decides to stop. In manual mode, the human reads each assessment and steers. In automated mode, the committee agent (see below) runs the loop autonomously, using majority-vote consensus to decide what qualifies as a meaningful improvement. Stop signals are the same either way:

- Suggestions no longer meaningfully improve the spec
- The process starts over-specifying or constraining implementation unnecessarily
- Remaining issues are minor wording or style preferences

## Automated Spec Refinement

StagedSpec supports fully automated spec refinement through a majority-vote committee agent (currently Cursor only). An orchestrator launches three independent reviewers — each running on a different model — in parallel against the same spec. Only findings raised by at least two of the three reviewers survive as consensus issues. The orchestrator filters these for genuine implementation value, applies the improvements directly to the spec, checks stage appropriateness and intent alignment, then repeats the full cycle until no qualifying consensus issues remain.

This setup replaces human judgement in the refinement loop with model diversity: where a single model might hallucinate an issue or miss one, requiring agreement across architecturally different models filters for real problems. The committee produces high-confidence improvements without human intervention, while guardrail documents and verification commands ensure the autonomous process stays within project boundaries.

## Research Integration

Research happens outside the refinement loop. The human investigates independently or provides reference documents (technical analyses, library comparisons, architectural decisions) that the AI incorporates during drafting. Complex aspects are documented separately and fed directly into spec creation. There is no formal research phase — the human brings knowledge in whatever form it exists.

## Scope Management

The spec set functions as a dependency graph managed by the human through several mechanisms:

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

## Guardrail Enforcement

When agents refine specs autonomously, the project needs hard boundaries they cannot cross. Guardrail documents (`intent.md`, `security.md`, `testing.md`) define these boundaries — project-wide invariants that no spec refinement, manual or automated, should change without deliberate intent.

StagedSpec enforces this at two levels. Pre-built hooks for Claude Code and Cursor block file-level edits to guardrail documents unless the active git branch contains both `guardrail` and `spec` in its name (e.g. `guardrail/spec-security-update`). The verification commands (`spec_validate_intent`, `spec_check`) let humans or agents check any spec or code against the guardrails without being able to modify them. Together, this means automated refinement can run freely within the boundaries while the boundaries themselves require a deliberate human action to change.

Hook configs live in `hooks/` and share a single shell script, so the protection logic stays consistent across tools.
