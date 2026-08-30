---
description: Create a spec_shape skill that runs auto_feature_update to refresh features.md, then auto_shape_specs to assess and repair the framework against the refreshed record.
scope: skills
created: 2026-06-04T17:48:01
updated: 2026-06-04T18:03:15
status: open
---

# Add a spec_shape skill that runs feature-update then framework-shaping

## Goal

Deliver a user-invocable `spec_shape` skill that shapes the whole spec framework in one pass: it first runs the `auto_feature_update` agent to bring `specs/features.md` in sync with the codebase, then runs the `auto_shape_specs` agent to assess and repair the framework against that refreshed record.

The ordering carries the value here. `auto_shape_specs` treats `specs/features.md` as the authoritative source for implemented behavior (see its Phase 1) and leaves refreshing it to a separate step. Running feature-update first hands the shaping pass an accurate behavior record to work from.

User-visible outcome: invoking `spec_shape` refreshes `features.md` and then shapes the framework, back-to-back, in a single skill.

## Context

- **Depends on the `auto_feature_update` agent** created in [the auto_feature_update agent task](agents_auto-feature-update.md). Build that first — `spec_shape` invokes the agent it produces.
- **Second agent to invoke** — `agents/auto_shape_specs.md`: a standalone agent that assesses the framework and repairs it, reading `specs/features.md` as its authoritative behavior source. `spec_shape` invokes it as-is.
- **Where the spec-framework knowledge lives** — the `spec_development` skill (`skills/spec_development/SKILL.md`) is the core of the StagedSpec framework, and both agents `spec_shape` orchestrates already ground themselves in its references. So `spec_shape` stays a thin orchestrator and relies on the agents for the framework logic.
- **Invocation pattern to mirror** — `agents/auto_spec_check.md` Step 2 shows the repo's launch-and-wait discipline. `spec_shape` applies it twice in sequence: launch `auto_feature_update`, wait for completion, then launch `auto_shape_specs`.
- **Skill conventions** — existing skills (e.g., `skills/spec_audit/SKILL.md`) use a `<task_block>` with `<role>`, `<objective>`, `<policy>`; the pseudo-XML tags are structural. `deployment.conf` disallows only `*legacy*` (which matches commands), so a new skill deploys to every target.

## Approach

Create `skills/spec_shape/SKILL.md` as a thin orchestrator.

- **Frontmatter:** `name: spec_shape` and a `description` that triggers on shaping the spec framework end-to-end.
- **Body** in the repo's skill style (`<task_block>` with `<role>`, `<objective>`, `<policy>`): state the objective — shape the framework end-to-end by refreshing the implemented-behavior record, then assessing and repairing the framework.
- **Two-step sequence:**
  1. Launch the `auto_feature_update` agent and wait for it to finish.
  2. Launch the `auto_shape_specs` agent and wait for it to finish.
- **State the ordering rationale in the skill** so the consuming model runs the steps in order: `auto_shape_specs` reads the refreshed `features.md`, so it runs after `auto_feature_update` completes. Drive each launch with a prose instruction that names the agent and follows `auto_spec_check` Step 2's launch-and-wait discipline; where a target resolves named agents through a frontmatter declaration (VS Code), mirror `auto_spec_check`'s `VSCODE_agents` form for both agents.

**Wiring:**

- Run `./scripts/deployment.sh --global --dry-run` and confirm `spec_shape` reaches the same targets `deployment.conf` allows for skills.
- Update `CLAUDE.md`, `AGENTS.md`, `agents/README.md`, and `README.md` to describe the repo as it stands after both tasks land — the new `auto_feature_update` agent, the `spec_shape` skill, and `spec_feature_update` delegating to the agent.

**Constraints / non-goals:**

- Keep `auto_feature_update` and `auto_shape_specs` unchanged — `spec_shape` invokes both as-is and holds only the orchestration.
- Keep the framework logic in `spec_development` and the two agents; `spec_shape` stays a thin sequencer.
- Preserve the cross-IDE conventions: intact pseudo-XML tag structure and the skill frontmatter shape.

## Acceptance

- `skills/spec_shape/SKILL.md` exists with `name: spec_shape`, a triggering `description`, and a `<task_block>` body in the repo's skill style.
- The skill launches `auto_feature_update` first and `auto_shape_specs` second, in that order, and states the rationale that `auto_shape_specs` consumes the refreshed `features.md`.
- Each launch follows `auto_spec_check`'s launch-and-wait discipline, with the VS Code agent declaration where required.
- `./scripts/deployment.sh --global --dry-run` lists `spec_shape` for the targets the conf allows for skills.
- `CLAUDE.md`, `AGENTS.md`, `agents/README.md`, and `README.md` describe the repo's post-implementation state — the `auto_feature_update` agent, the `spec_shape` skill, and the `spec_feature_update` delegation.
- Pseudo-XML tag structure stays well-formed in the new skill file.
- The tasks linter reports a clean result for this task file.
