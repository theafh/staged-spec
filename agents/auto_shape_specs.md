---
name: auto_shape_specs
description: Assesses the spec framework for structural issues, then autonomously fixes every issue it finds. Use when the spec framework needs a full health check and automated repair.
CURSOR_model: inherit
CLAUDE_model: inherit
CLAUDE_background: false
CLAUDE_effort: high
CODEX_model: inherit
CURSOR_readonly: false
CURSOR_is_background: false
---

# Auto Shape Specs

Assess the spec framework as a whole, then fix every issue found. This is a two-phase process: first produce a complete issue list, then resolve each issue one by one.

## Phase 1 — Assessment

Use the spec_development Skill and follow its framework_assessment reference for assessment guidance.

Read all files under `/specs` — `architecture.md`, `intent.md`, `security.md`, `testing.md`, `features.md`, and every stage spec file. Treat stage files marked implemented as historical records: use them for cross-file checks (status alignment, dependencies, terminology, and link validity), and focus stage-level quality issues on stages that are not marked implemented. Cross-reference the framework against the assessment dimensions defined in the framework_assessment reference.

Produce the assessment output in the exact format the reference specifies: a general assessment paragraph followed by a severity-ordered issue list.

If no issues are found, stop and report that the framework is clean.

## Phase 2 — Fix loop

Work through the issue list from Phase 1, resolving each issue one at a time in severity order.

For each issue:

1. Read the affected files to understand the current state.
2. Determine the minimum fix that resolves the issue without introducing new problems.
3. Apply the fix. Use the spec_development Skill's single_stage_structure reference for stage spec edits, and follow the framework_assessment reference for framework-level concerns.
4. When a fix requires renaming or moving stage files, use `git mv` and update all references across the spec framework — `architecture.md`, other stage specs, and any cross-references.
5. After applying the fix, verify it resolved the issue and did not break consistency with other files.
6. Move to the next issue.

Rules for the fix loop:

- Fix issues one at a time by default. Group related issues into a single fix when they affect the same files or when resolving them together is simpler (e.g., a file rename and its reference updates). Verify after each fix or fix group before moving on.
- Preserve established, non-contradictory requirements. Change only what the issue demands.
- Apply stage-content fixes to non-implemented stage files. Keep implemented stage files unchanged unless the user explicitly requests historical spec edits.
- When a fix affects guardrail documents (`intent.md`, `security.md`, `testing.md`), do not modify them. Instead, fix the stage spec to align with the guardrail. If alignment is impossible, flag the conflict and skip to the next issue.
- When a fix requires a design decision (split a stage, reassign ownership between stages, change dependency order), make the simplest choice that preserves the existing structure. Document what you chose and why in a brief comment at the end of your output.
- This agent may run for a long time on large spec frameworks. Work steadily through the full list. Do not stop early.

After all issues are resolved, run a final consistency check: verify status markers match across `architecture.md` and all stage files, cross-references are valid, and no fix introduced a new conflict.

Report the full list of changes made, organized by file.
