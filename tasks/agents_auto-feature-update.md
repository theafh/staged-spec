---
description: Create an auto_feature_update agent that runs the existing spec_feature_update prompt, and rewire the spec_feature_update skill to invoke it.
scope: agents
created: 2026-06-04T17:48:01
updated: 2026-06-04T18:03:15
status: open
---

# Add an auto_feature_update agent and route spec_feature_update through it

## Goal

Move the feature-update prompt out of the `spec_feature_update` skill into a standalone `auto_feature_update` agent, then rewire the skill to invoke that agent. The behavior stays exactly what `spec_feature_update` does today — it just lives in the agent now, so the skill and any future caller share one source.

User-visible outcome: invoking `spec_feature_update` runs the agent and updates `specs/features.md` exactly as before.

## Context

- **Behavior to preserve, unchanged** — `skills/spec_feature_update/SKILL.md`: objective "Update `specs/features.md` to reflect actual implemented behavior in the current codebase," with one rule — inspect the implementation end-to-end, then add or update every implemented user-facing and app-behavior-defining feature in `specs/features.md`. The agent does exactly this; follow it as written and keep the work to `features.md`.
- **File format to copy** — `agents/auto_shape_specs.md`: copy its frontmatter into the new agent. Feature-update is a simpler job than framework shaping, so the agent stays a single straightforward pass.
- **Deployment** — `deployment.conf` leaves `auto_shape_specs` enabled everywhere, so the new agent follows the same config and reaches the same targets.

## Approach

1. **Create `agents/auto_feature_update.md`.** Copy the frontmatter from `agents/auto_shape_specs.md`, set `name: auto_feature_update` and a fitting `description`. Write the body as the `spec_feature_update` objective and rule in agent form: inspect the implementation end-to-end, then add or update every implemented user-facing and app-behavior-defining feature in `specs/features.md`. One pass, `features.md` only.

2. **Rewire `skills/spec_feature_update/SKILL.md`.** Replace the inline prompt with an instruction to run the `auto_feature_update` agent, leaving the skill a thin front end. Keep the `<task_block>` and tags intact, and update the `description` to state it delegates to the agent.

**Wiring:**

- Run `./scripts/deployment.sh --global --dry-run` and confirm the new agent reaches the same targets `deployment.conf` allows for `auto_shape_specs`.

**Keep in scope:** the new agent and the skill rewire. Leave `auto_shape_specs` and the `spec_development` references as they are. The repo-description docs (`CLAUDE.md`, `AGENTS.md`, `agents/README.md`, `README.md`) are refreshed once, at the end of the `spec_shape` task, to describe the final state.

## Acceptance

- `agents/auto_feature_update.md` exists with the frontmatter copied from `auto_shape_specs.md` and a body that runs the `spec_feature_update` objective and rule as a single pass, writing `specs/features.md` only.
- `skills/spec_feature_update/SKILL.md` invokes `auto_feature_update` in place of the inline prompt, with the `<task_block>` intact and the `description` updated.
- `./scripts/deployment.sh --global --dry-run` shows the agent reaching the same targets the conf allows for `auto_shape_specs`.
- The tasks linter reports a clean result for this task file.
