---
name: auto_shape_specs
description: Assesses the spec framework for structural issues, then autonomously fixes every issue it finds. Use when the spec framework needs a full health check and automated repair.
VSCODE_target: github-copilot
VSCODE_user-invocable: true
VSCODE_disable-model-invocation: false
VSCODE_model: GPT-5.4
VSCODE_agents: []
CURSOR_model: inherit
CLAUDE_model: inherit
CLAUDE_background: false
CLAUDE_effort: high
CODEX_model: gpt-5.4
CODEX_model_reasoning_effort: high
CURSOR_readonly: false
CURSOR_is_background: false
---

# Auto Shape Specs

Assess the spec framework as a whole, then fix every issue found. This is a two-phase process: first produce a complete issue list, then resolve each issue one by one.

## Overall goal

Shape the spec framework so the next planned stage is one-shot-implementation-ready and later stages carry a clear, ordered path forward. Every assessment and fix serves that goal — keep each stage sized for a single-pass implementation, push scope creep into the planned stage that will own the work, and preserve staged progression across the version chain.

Apply the move that matches the issue:

- Oversized stage → split into a new planned stage and update numbering.
- Undersized stage → merge with an adjacent stage sharing the same cohesive concern.
- Scope creep or forward-looking content inside a stage → relocate into the planned stage that will own it, leaving an Out of scope pointer.
- Globally out-of-scope content (violates `specs/intent.md`, `specs/security.md`, or `specs/testing.md`, or sits outside the declared project domain) → move to `specs/architecture.md`.
- Dependency-order problems → reorder stage numbering via `git mv` so each stage depends only on prior completed work.

Each destination has a distinct purpose: planned stage files hold deferred-but-buildable work; `specs/architecture.md` holds scope that should never be built; `specs/features.md` records already-built behavior and is therefore never an Out of scope destination. Route every Out of scope pointer to the destination kind that matches the nature of the deferred item.

## Phase 1 — Assessment

Use the spec_development Skill and follow its framework_assessment reference for assessment guidance.

Read all files under `/specs` — `architecture.md`, `intent.md`, `security.md`, `testing.md`, `features.md`, and every stage spec file. Use `specs/features.md` as the authoritative source for all implemented behavior. Treat implemented and in-progress stage files as historical records: use them only for cross-file consistency checks (status alignment, link validity, terminology), not as behavioral context. Focus stage-level quality issues strictly on stage specs with status `planned`. Verify that planned stages reference `features.md` for established behavior they build on, and that implemented stage files appear only in cross-file consistency contexts (status alignment, link validity, terminology). Cross-reference the framework against the assessment dimensions defined in the framework_assessment reference.

Scan every planned stage for **implemented-stage leakage**: any link to an `✓ Implemented` or `In Progress` stage file that appears in Dependencies, Desired behavior, Scope boundary, Implementation steps, or Tests and verification. Flag each occurrence as a Phase 2 issue. The origin stage is irrelevant once the behavior lands in `features.md` — the only correct pointer for already-built behavior is the matching `features.md` topic. Treat referencing an implemented or in-progress stage outside audit/link-validation contexts as an error, regardless of whether the referenced behavior is real.

Evaluate scope sizing for every planned stage: each stage must be sized as exactly one clear scope as defined by the stage scoping principle in the single_stage_structure reference — the most compact scope that delivers a meaningful, testable capability, large enough to drive coherent progress, small enough for one-shot AI implementation. Flag stages that are too large (would require multiple implementation passes) or too small (add coordination overhead without delivering a coherent capability on their own) as issues to resolve in Phase 2.

Audit Out of scope sections bidirectionally across every stage file. The contract requires **both sides to coexist**: the source stage keeps its Out of scope pointer (this is what guides auto-shaping, boundary reasoning, and the forward path to the target — a role distinct from target-side detail), **and** the target file owns the deferred item with implementable specification detail (this is what actually gets built when the future stage runs). For each Out of scope entry, open the referenced target file (future stage spec or `specs/architecture.md`) and verify each listed deferred item is present there with implementable specification detail. Flag every mismatch as a Phase 2 issue — missing target file, missing topic coverage, stub-only coverage (heading, single line, or placeholder), and inconsistent ownership where the deferred item is actually owned by a different file than the one the entry names. Also flag the reverse case: a target stage already owns detail for a topic that an earlier stage's scope would otherwise include, while the earlier stage lacks an Out of scope pointer to the target — the fix there is to add the pointer, keeping the target content intact.

Check Out of scope destinations against the destination-kind rule from the Overall goal. The primary destination is the planned future stage file that will own the deferred work; `specs/architecture.md` is reserved for items globally out of scope. Flag each of the following as a Phase 2 issue: entries pointing at `specs/features.md` or implemented/in-progress stage files (already-built behavior belongs in **Dependencies**), and entries pointing at `specs/architecture.md` for deferred-but-buildable items that actually belong in a planned stage.

Produce the assessment output in the exact format the reference specifies: a general assessment paragraph followed by a severity-ordered issue list.

If no issues are found, stop and report that the framework is clean.

## Phase 2 — Fix loop

Work through the issue list from Phase 1, resolving each issue one at a time in severity order.

For each issue:

1. Read the affected files to understand the current state.
2. Determine the minimum fix that resolves the issue without introducing new problems.
3. Apply the fix. Use the spec_development Skill's single_stage_structure reference for the required shape (sections, naming, Out of scope format), the single_stage_refinement reference for the full menu of moves (add clarifying detail, remove over-specification, relocate to Out of scope, split into a new stage, merge with an adjacent stage, reorder dependencies), and the framework_assessment reference for framework-level concerns. Choose the refinement move that best fits the issue — avoid defaulting to additive fixes when the issue calls for removal, relocation, or a structural move.
4. When a fix requires renaming or moving stage files, use `git mv` and update all references across the spec framework — `architecture.md`, other stage specs, and any cross-references.
5. After applying the fix, verify it resolved the issue and did not break consistency with other files.
6. Move to the next issue.

Rules for the fix loop:

- Fix issues one at a time by default. Group related issues into a single fix when they affect the same files or when resolving them together is simpler (e.g., a file rename and its reference updates). Verify after each fix or fix group before moving on.
- Preserve established, non-contradictory requirements. Change only what the issue demands.
- Apply stage-content fixes strictly to stage specs that have the status `planned`. Keep `implemented` and `in progress` stage files unchanged unless the user explicitly requests historical spec edits.
- When a fix affects guardrail documents (`intent.md`, `security.md`, `testing.md`), do not modify them. Instead, fix the stage spec to align with the guardrail. If alignment is impossible, flag the conflict and skip to the next issue.
- When a scope sizing issue requires splitting a stage into smaller stages or merging adjacent stages, create or consolidate the stage files accordingly. Place each new stage at the position its dependencies dictate — inside an already-ordered tier, insert at the correct slot and renumber every later stage in that tier via `git mv` so the chain stays contiguous (appending at the end of the tier is not acceptable when the stage's dependencies place it earlier). Choose the destination tier by matching the new stage's scope against the tier purposes in `specs/architecture.md`; a new stage may move to a later tier when that fits its purpose, and within the chosen tier it lands where it is the base for the stages that follow. Update all references in `architecture.md`, other stage specs, and any cross-references that point to the affected files. Verify link validity after every split or merge.
- When an unordered file (`v<ver>-<short-name>.md`) coexists with ordered stages in the same tier, commit it to the sequence: place it at its correct dependency slot, rename via `git mv` to `v<ver>-stage-<num>-<short-name>.md`, and renumber every later stage in the tier so the chain stays contiguous. Update `architecture.md` and every cross-reference. A tier either has all its planned stages ordered or none of them — mixed states are not acceptable.
- When fixing an Out of scope mismatch, repair the bidirectional contract end-to-end and keep **both sides present** — the source stage's Out of scope pointer and the target file's implementable content. Open the target file named in the Out of scope entry and write the deferred content into it with implementable specification detail (Desired behavior, scope boundary, or Implementation steps as appropriate). Create the target stage file with Planned status and register it in `specs/architecture.md` when no suitable destination exists. Correct the Out of scope pointer when the real owner is a different file than the entry names, and consolidate ownership in one file when a topic is duplicated across multiple stages. When a target already owns detail for a topic but the earlier stage is missing the Out of scope pointer, add that pointer to the earlier stage and leave the target content intact. Never resolve a mismatch by deleting the source Out of scope entry simply because the target covers the topic, and never delete target content simply because the source pointer exists — both records serve distinct purposes and must remain. After every repair, re-check that the source Out of scope entry and the target file agree on the deferred item.
- When fixing an Out of scope destination, choose the destination that matches the nature of the deferred item — a planned future stage file for work that will be built later, `specs/architecture.md` only for scope that should never be built. Apply one of: (1) redirect the pointer to the correct planned stage file, (2) create a new planned stage file with Planned status, register it in `specs/architecture.md`, and write the deferred content into it, (3) redirect to `specs/architecture.md` when the item is globally out of scope per guardrails or project intent, or (4) when the item is already covered by `features.md`, remove the Out of scope entry and add the reference to **Dependencies** if the stage builds on that behavior.
- When fixing implemented-stage leakage, replace every link to an `✓ Implemented` or `In Progress` stage file inside Dependencies, Desired behavior, Scope boundary, Implementation steps, or Tests and verification with a link to the matching topic in `specs/features.md`. Do not preserve the stage-file link as a secondary reference, do not add a parenthetical note about which stage delivered the behavior, and do not inject new stage-file links while applying other fixes. The only valid behavioral pointer in a planned stage is `features.md` (for established behavior) or another planned stage file (for unbuilt prerequisites).
- When a fix requires a design decision (split a stage, reassign ownership between stages, change dependency order), make the simplest choice that preserves the existing structure. Document what you chose and why in a brief comment at the end of your output.
- This agent may run for a long time on large spec frameworks. Work steadily through the full list. Do not stop early.

After all issues are resolved, run a final consistency check: verify status markers match across `architecture.md` and all stage files, cross-references are valid, and no fix introduced a new conflict.

Report the full list of changes made, organized by file.
