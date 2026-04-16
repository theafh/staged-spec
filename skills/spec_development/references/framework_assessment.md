<task_block>
  <role>Framework Assessment</role>

  <objective>
    <summary>Assess the spec framework as a whole for completeness, coherence, and readiness. This guide evaluates the `/specs` system — the full set of files and their relationships — in contrast to [single_stage_assessment.md](single_stage_assessment.md), which evaluates individual stage specs.</summary>
    <goal>Determine whether the spec framework is mature enough that a one-shot AI coding agent could pick up any planned stage and implement it correctly, or whether the framework has structural gaps that would cause confusion, misalignment, or incorrect implementations regardless of how good individual specs are.</goal>
  </objective>

  <policy>
    <intent>
      <rule>Evaluate each dimension and report its state.</rule>
      <rule>Treat `specs/features.md` as the authoritative source for all implemented behavior. Use implemented stage files only for cross-file consistency checks (status markers, link validity, terminology) — not as behavioral context. Assess stage-level quality and readiness only for stages with status `planned`.</rule>
    </intent>

    <assessment_dimensions>
      <index_completeness>
        <criterion>Links every existing stage file (planned, in progress, and implemented).</criterion>
        <criterion>Status markers in `architecture.md` match the status inside each linked stage file.</criterion>
        <criterion>Contains a one-paragraph project summary linking to `specs/intent.md`.</criterion>
        <criterion>Global constraints section links to all guardrail documents (`intent.md`, `security.md`, `testing.md`).</criterion>
        <criterion>Out-of-scope section exists and aligns with `intent.md` domain boundaries.</criterion>
        <criterion>Future-features list captures deferred work that has a known home but is unordered.</criterion>
      </index_completeness>

      <guardrail_coverage>
        <criterion>`specs/intent.md` exists, has all six sections, and every item is falsifiable.</criterion>
        <criterion>`specs/security.md` exists and covers authentication, data classification, trust boundaries, and secrets management aligned to the stack.</criterion>
        <criterion>`specs/testing.md` exists and covers test levels, framework choices, coverage policy, and CI requirements aligned to the stack.</criterion>
        <criterion>Guardrail documents contain outcome-focused constraints, with implementation details kept out.</criterion>
        <criterion>Stage specs reference guardrail documents where relevant (via **Read first** sections) and comply with their constraints.</criterion>
      </guardrail_coverage>

      <dependency_graph_integrity>
        <criterion>Every stage depends only on completed, prior stages.</criterion>
        <criterion>The graph contains no forward dependencies or cycles.</criterion>
        <criterion>Ordered stages (`v&lt;ver&gt;-stage-&lt;num&gt;-*`) form a linear chain within each version — no gaps in numbering, no orphaned stages.</criterion>
        <criterion>The current working version has its stages ordered and numbered. Future versions beyond the current one can remain unordered until their turn comes.</criterion>
        <criterion>Each stage is implementable, runnable, and testable using only its own content and prior completed stages.</criterion>
      </dependency_graph_integrity>

      <scope_distribution>
        <criterion>Each requirement lives in exactly one stage — no duplicated ownership across files.</criterion>
        <criterion>Requirements that span stages have clear ownership in one file with explicit cross-references where needed.</criterion>
        <criterion>The boundary between consecutive planned stages is unambiguous: given a requirement, it is obvious which stage owns it.</criterion>
        <criterion>Out-of-scope sections in stage files align with what later stages actually cover.</criterion>
        <criterion>Deferred items in `architecture.md` future-features list are consistent with out-of-scope entries in stage files.</criterion>
        <criterion>Each stage is sized as the most compact scope that delivers a meaningful, testable capability — large enough to drive coherent progress, small enough for one-shot AI implementation in a single pass.</criterion>
      </scope_distribution>

      <version_tier_progression>
        <criterion>v1 covers a minimum working product — enough to run and validate the core idea.</criterion>
        <criterion>v2 adds core differentiators that distinguish this project from alternatives.</criterion>
        <criterion>v3 covers advanced enhancements, optimizations, or extended capabilities.</criterion>
        <criterion>Each version tier builds on completed prior versions, with no forward references into later tiers.</criterion>
        <criterion>The progression tells a coherent story: each tier is a meaningful milestone, with no arbitrary splitting.</criterion>
      </version_tier_progression>

      <feature_documentation_alignment>
        <criterion>`specs/features.md` exists when the project has implemented behavior and serves as the authoritative record of current system capabilities.</criterion>
        <criterion>Every behavior documented in `features.md` is actually implemented in the codebase.</criterion>
        <criterion>`features.md` contains only verified runtime outcomes — no planned behavior, no stage history.</criterion>
        <criterion>`features.md` is organized by feature topics — it describes what the system does, not which stage delivered it.</criterion>
        <criterion>`features.md` uses behavior-first form (runtime outcomes, not internals).</criterion>
        <criterion>Planned stages reference `features.md` for established behavior they build on, rather than referencing implemented stage files.</criterion>
      </feature_documentation_alignment>

      <stage_format_compliance>
        <criterion>Every planned stage file uses exactly the required section set: Title, Status, Goal, Dependencies, optional Read first, Desired behavior, Scope boundary, Implementation steps, Tests and verification, Out of scope. Flag extra or missing sections.</criterion>
        <criterion>Each top-level item in "Tests and verification" is a verification topic — a descriptive heading grouping ~2–3 related behavioral checks. Flag flat lists where each bullet is one isolated check instead of a grouped topic.</criterion>
      </stage_format_compliance>

      <terminology_and_cross_file_consistency>
        <criterion>Key terms (component names, concepts, flag names, API surfaces) use the same wording across all spec files.</criterion>
        <criterion>Cross-references between files use valid relative markdown links; section anchors are present when they add precision.</criterion>
        <criterion>Config contracts (flags, environment variables) documented in `features.md` or defined in planned stages are referenced consistently when reused or extended in later stages.</criterion>
      </terminology_and_cross_file_consistency>
    </assessment_dimensions>
  </policy>

  <output_contract>
    <response_shape>
      <rule>Use exactly this structure:</rule>
      <template>
# Framework assessment

Write one short paragraph stating the overall maturity of the spec framework and whether it is ready for implementation work.

## Issues

If no issues exist, output exactly:
No issues found.

Otherwise, list all issues as a single ordered list. Order by severity — issues most likely to cause incorrect or divergent implementations across multiple stages rank highest.

1. **[short title]** — one paragraph: what is wrong, which files are affected, and the minimum fix needed.
2. **[short title]** — same structure.
(continue as needed)
      </template>
    </response_shape>

    <inclusion_rule>Include every identified issue regardless of size. Even minor cross-file inconsistencies belong at the bottom of the list.</inclusion_rule>
  </output_contract>
</task_block>
