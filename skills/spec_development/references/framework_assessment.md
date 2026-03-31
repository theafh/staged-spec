# Framework Assessment

Assess the spec framework as a whole for completeness, coherence, and readiness. This guide evaluates the `/specs` system — the full set of files and their relationships — in contrast to [single_stage_assessment.md](single_stage_assessment.md), which evaluates individual stage specs.

Goal:
Determine whether the spec framework is mature enough that a one-shot AI coding agent could pick up any planned stage and implement it correctly, or whether the framework has structural gaps that would cause confusion, misalignment, or incorrect implementations regardless of how good individual specs are.

## Assessment dimensions

Evaluate each dimension and report its state.

### 1. Index completeness (`architecture.md`)

- Links every existing stage file (planned, in progress, and implemented).
- Status markers in `architecture.md` match the status inside each linked stage file.
- Contains a one-paragraph project summary linking to `specs/intent.md`.
- Global constraints section links to all guardrail documents (`intent.md`, `security.md`, `testing.md`).
- Out-of-scope section exists and aligns with `intent.md` domain boundaries.
- Future-features list captures deferred work that has a known home but is unordered.

### 2. Guardrail coverage

- `specs/intent.md` exists, has all six sections, and every item is falsifiable.
- `specs/security.md` exists and covers authentication, data classification, trust boundaries, and secrets management aligned to the stack.
- `specs/testing.md` exists and covers test levels, framework choices, coverage policy, and CI requirements aligned to the stack.
- Guardrail documents contain outcome-focused constraints, with no implementation details leaking in.
- Stage specs reference guardrail documents where relevant (via **Read first** sections) and comply with their constraints.

### 3. Dependency graph integrity

- Every stage depends only on completed, prior stages.
- The graph contains no forward dependencies or cycles.
- Ordered stages (`v<ver>-stage-<num>-*`) form a linear chain within each version — no gaps in numbering, no orphaned stages.
- The current working version has its stages ordered and numbered. Future versions beyond the current one can remain unordered until their turn comes.
- Each stage is implementable, runnable, and testable using only its own content and prior completed stages.

### 4. Scope distribution

- Each requirement lives in exactly one stage — no duplicated ownership across files.
- Requirements that span stages have clear ownership in one file with explicit cross-references where needed.
- The boundary between consecutive stages is unambiguous: given a requirement, it is obvious which stage owns it.
- Out-of-scope sections in stage files align with what later stages actually cover.
- Deferred items in `architecture.md` future-features list are consistent with out-of-scope entries in stage files.

### 5. Version tier progression

- v1 covers a minimum working product — enough to run and validate the core idea.
- v2 adds core differentiators that distinguish this project from alternatives.
- v3 covers advanced enhancements, optimizations, or extended capabilities.
- Each version tier builds on completed prior versions, with no forward references into later tiers.
- The progression tells a coherent story: each tier is a meaningful milestone, with no arbitrary splitting.

### 6. Feature documentation alignment

- `specs/features.md` exists when the project has implemented behavior.
- Every behavior documented in `features.md` is actually implemented in the codebase.
- `features.md` contains no planned or hallucinated behavior — only verified runtime outcomes.
- `features.md` is organized by feature topics, not by stages — it describes what the system does, not which stage delivered it.
- `features.md` uses behavior-first form (runtime outcomes, not internals).

### 7. Terminology and cross-file consistency

- Key terms (component names, concepts, flag names, API surfaces) use the same wording across all spec files.
- Cross-references between files use valid relative markdown links; section anchors are present when they add precision.
- Config contracts (flags, environment variables) defined in one stage are referenced consistently when reused or extended in later stages.

## Output format

Use exactly this structure:

```markdown
# Framework assessment

Write one short paragraph stating the overall maturity of the spec framework and whether it is ready for implementation work.

## Issues

If no issues exist, output exactly:
No issues found.

Otherwise, list all issues as a single ordered list. Order by severity — issues most likely to cause incorrect or divergent implementations across multiple stages rank highest.

1. **[short title]** — one paragraph: what is wrong, which files are affected, and the minimum fix needed.
2. **[short title]** — same structure.
(continue as needed)
```

## Inclusion rule

Include every identified issue regardless of size. Even minor cross-file inconsistencies belong at the bottom of the list.
