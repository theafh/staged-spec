---
name: spec-development
description: "StagedSpec: Guides iterative development and assessment of project specs in /specs with an architecture index, staged specs, implemented status tracking, and feature documentation. Use when creating, refining, or checking specs, architecture.md, stage files, features.md, security.md, or testing.md."
---

# StagedSpec — Spec Development

## General

- Use a `/specs` folder at the project root for all specification documents.
- Use `specs/architecture.md` as the single index and entry point with stage links, status markers, global constraints, and future features.
- Treat the full `/specs` set as one system: improve clarity and consistency without eroding already-established valid behavior.
- Keep specs contradiction-free and outcome-focused; include implementation detail only when required for correctness, safety, or integration.
- Keep global constraints visible in `specs/architecture.md`, including links to `specs/intent.md`, `specs/security.md`, and `specs/testing.md`.
- Suggest `specs/security.md` and `specs/testing.md` when they do not exist and prefill them with best practices aligned to the stack and threat model.
- Add an explicit out-of-scope section in `specs/architecture.md` to prevent scope creep.
- Preserve history when restructuring tracked spec files: use `git mv` for renames/moves and `git rm` for permanent retirement.
- Plan staged work to reduce avoidable refactors by keeping scope cohesive, dependencies explicit, and build order free of forward dependencies.
- Use the staged plan to guide steady progress while balancing over-engineering with under-specification.
- The skill drives iterative, human-in-the-loop refinement; the target quality bar is a spec that a one-shot AI coding agent can implement correctly from the spec alone.

## Guardrail documents

The following files are project-level guardrails, not regular stage deliverables:

- `specs/intent.md` — project identity and non-negotiable boundaries.
- `specs/security.md` — security constraints and threat model.
- `specs/testing.md` — testing strategy and quality requirements.

Rules for guardrail documents:

- Never create, modify, or delete a guardrail document as a side-effect of stage creation, refinement, implementation, or status updates.
- Changes to guardrail documents require an explicit, direct request from the human user in the current conversation.
- When a stage update conflicts with a guardrail document, fix the stage spec to align with the guardrail. Escalate to the user when alignment requires a trade-off or when the conflict touches a core constraint.
- Stage specs may reference guardrail documents (e.g., in a **Read first** section) but must not alter their content.
- Automated or batch workflows that touch multiple specs must skip guardrail documents entirely.

## Workflow routing

- When creating, refining, or implementing specs, read [references/spec_structure.md](references/spec_structure.md).
- When reviewing or checking a spec for implementation readiness, read [references/spec_assessment.md](references/spec_assessment.md).
- When creating, validating, or checking alignment against the project intent, read [references/spec_intent.md](references/spec_intent.md).
