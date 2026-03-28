# Spec Structure

## Spec creation

- Use one stage per staged spec file and keep each stage focused on one cohesive, implementable unit.
- Use consistent staged file naming (use hyphens or underscores as separators, but stay consistent within a project):
  - `v<version>-stage-<number>-<short-name>.md` when order is committed.
  - `v<version>-<short-name>.md` for future features that are not yet ordered.
- Keep stage layering strict: each stage depends only on prior stages and must be implementable, runnable, and testable without later stages.
- Use version tiers when useful:
  - v1: minimum working product.
  - v2: core differentiators.
  - v3: advanced enhancements.
- Enforce version dependency order: each version builds on all prior completed versions, and each numbered stage builds on earlier stages within its version.
- Name future spec files without stage numbers until order is committed; when order is committed, rename them to staged filenames that reflect dependency order.
- Use this required stage structure and section titles:
  - Title line with the stage name
  - `**Status**:` Planned | In Progress | ✓ Implemented
  - `**Goal**:` one-sentence outcome
  - **Dependencies and prior links**: required prior stage/spec links when this stage extends or builds on them
  - Optional **Read first** for prerequisite docs when relevant (for example `specs/security.md`, `specs/testing.md`)
  - **Desired behavior (specification)**
  - **Scope boundary**
  - **Implementation steps**
  - **Tests and verification**
  - **Documentation updates**
  - **Out of scope**
- Apply paragraph discipline:
  - one requirement per paragraph,
  - consistent terminology across stage/index/features,
  - outcomes and constraints before implementation detail,
  - ordering that builds from foundation to dependent behavior.
- For any new/changed flags or environment variables, include a config contract in the stage spec:
  - accepted values and normalization/parsing rules,
  - defaults for missing/empty values,
  - invalid-value behavior (error/warning/coercion) and where visible,
  - deterministic fallback behavior.

## Reference and scope discipline

- Keep the main stage content implementation-focused: clearly state what the current stage will implement.
- In `Desired behavior (specification)`, describe the implementation target clearly and concretely before detailing execution steps.

### Reference discipline

- Link referenced spec files with valid relative markdown links; include a section anchor when it adds precision or clarity.
- When a stage extends or depends on prior work, place one canonical dependency reference within the content. Treat this as a reference to prior/current dependencies, not future-stage ownership.
- If the same prior spec is referenced multiple times across sections, treat that as a consolidation signal: combine into one clearer paragraph/section with one reference per target spec where possible.
- When consolidating repeated references, preserve required constraints and context; improve clarity without skipping requirements, introducing scope creep, or over-compressing intent.

### Scope boundary discipline

- Keep stage spec content implementation-focused: describe only behavior implemented in the current stage.
- Treat future specs/stages after the current one as out of scope for the current stage. Behavior or requirements that belong to later stages must not appear in implementation sections — their presence means the spec is not implementation-ready.
- When relocating an aspect from implementation sections to Out of scope, always check whether the target later-stage file already contains the detail. If it does not, add the relocated content there so the information is preserved. Do not drop details during relocation.
- Reference prior specs sparingly and only when the reference reduces ambiguity needed for implementation-ready clarity.
- Record future-stage ownership only when needed to prevent scope ambiguity, and keep it as one short boundary note with one concise reference per target.
- Use `Out of scope` to add clarity: you can capture follow-up future-stage details there when they reduce ambiguity, while keeping implementation-focused sections centered on current-stage behavior.

## Spec refinement

- Guardrail documents (`specs/intent.md`, `specs/security.md`, `specs/testing.md`) are out of scope for refinement passes. When a refinement conflicts with a guardrail, fix the stage spec to align with the guardrail. Escalate to the user when alignment requires a trade-off or touches a core constraint.
- Refine with restraint: do not over-specify a single implementation path unless required.
- Preserve established, non-contradictory requirements; remove or rewrite only for explicit reasons (contradiction resolution, scope change, or relocation due to split/restructure).
- When moving content between specs, do not drop required behavior; relocate it to the correct file and keep the full spec set complete.
- Reassess dependency quality during refinement:
  - validate prerequisites for every stage N against stages `1..N-1`,
  - evaluate intent as well as wording,
  - reorder or split when forward dependencies or cycles appear.
- Use the iterative refinement workflow:
  1. Confirm scope, dependencies, and expected outcome with the user.
  2. Draft with the standard stage structure.
  3. Review for internal consistency and scope fit.
  4. Propose stage splits when topics are independent.
  5. Refine until implementation-ready.
  6. Re-verify dependency chain before finalizing.
  7. Treat refinement as an open-ended iterative loop until the stage is implementation-ready.
- Keep future stages adjustable until implementation; do not treat planned text as fixed design prematurely.
- Allow changes to already implemented stages when required, and use forward-facing stage design to reduce churn.

## After spec execution

- Do not modify guardrail documents (`specs/intent.md`, `specs/security.md`, `specs/testing.md`) during post-execution updates. If implemented code violates a guardrail, always escalate to the user — do not mark the stage as implemented or adjust documentation to paper over the conflict.
- Mark a stage `✓ Implemented` only when definition of done is met:
  - claimed behavior is verified in the actual codebase (and tests/verifications where applicable), not inferred from plans/drafts,
  - tests/verifications are listed and reflect observable behavior,
  - implemented behavior is documented in `specs/features.md` in behavior-first form,
  - status is synchronized across `specs/architecture.md` and the corresponding `v*-stage-*.md` file.
- Run a mandatory cross-file consistency check before finishing any spec/status update:
  - verify status markers match across `specs/architecture.md` and referenced `v*-stage-*.md` files,
  - verify no planned or hallucinated behavior is documented as implemented.
- Update `specs/features.md` immediately after implementation and verification; do not defer.
- Keep `specs/features.md` behavior-first: document observable runtime outcomes and constraints, not internal implementation details.
- Organize `specs/features.md` by stable topic headings; each topic should group related observable behaviors and constraints.
- Update `specs/architecture.md` links/status to reflect the implemented state and maintain the future-features list for deferred items.
- Add or maintain a verification checklist in completed stages and include implementation tasks when a traceable audit trail is needed.
