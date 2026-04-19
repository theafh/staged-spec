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
        <criterion>Stage specs comply with guardrail document constraints — the guardrails apply project-wide without requiring per-stage reference links.</criterion>
      </guardrail_coverage>

      <dependency_graph_integrity>
        <criterion>Every stage depends only on completed, prior stages.</criterion>
        <criterion>The graph contains no forward dependencies or cycles.</criterion>
        <criterion>Ordered stages (`v&lt;ver&gt;-stage-&lt;num&gt;-*`) form a linear chain within each version — no gaps in numbering, no orphaned stages.</criterion>
        <criterion>The current working version has its stages ordered and numbered. Future versions beyond the current one can remain unordered until their turn comes.</criterion>
        <criterion>Within any tier that already contains ordered stages (`v&lt;ver&gt;-stage-&lt;num&gt;-*`), every planned stage in that tier is ordered — the tier has committed to a sequence, so unordered files (`v&lt;ver&gt;-&lt;short-name&gt;.md`) sitting in the same tier are incomplete. Flag each unordered file in a mixed tier as an issue; recommend placing it at its correct slot in the dependency chain and renaming via `git mv` to `v&lt;ver&gt;-stage-&lt;num&gt;-&lt;short-name&gt;.md`, renumbering neighbors when the insertion requires it.</criterion>
        <criterion>Each stage is implementable, runnable, and testable using only its own content and prior completed stages.</criterion>
      </dependency_graph_integrity>

      <scope_distribution>
        <criterion>Each requirement lives in exactly one stage — no duplicated ownership across files.</criterion>
        <criterion>Requirements that span stages have clear ownership in one file with explicit cross-references where needed.</criterion>
        <criterion>The boundary between consecutive planned stages is unambiguous: given a requirement, it is obvious which stage owns it.</criterion>
        <criterion>Out-of-scope sections in stage files resolve bidirectionally — **both sides are required**: the source stage keeps an explicit Out of scope pointer (so auto-shaping, boundary reasoning, and forward navigation work), **and** the target file owns the deferred item with implementable specification detail (so the future stage is actually buildable). Flag dangling deferrals where the target file is missing, omits the deferred item, covers it only as a stub/heading/placeholder, or assigns ownership to a different file than the Out of scope entry names. Also flag the reverse case: a target stage owns detail for a topic that an earlier stage's scope would otherwise include, but the earlier stage has no Out of scope pointer to that target. Every fix restores the missing side without removing the present one.</criterion>
        <criterion>Out of scope entries use the correct destination kind: a planned future stage file for deferred-but-buildable scope (the primary case — scope creep pushed to the stage that will own it), and `specs/architecture.md` only for items globally out of scope (scope that should never be built because it violates guardrails or sits outside project intent). Flag entries pointing at `specs/features.md` or implemented/in-progress stage files as invalid destinations, and flag entries pointing at `specs/architecture.md` for items that are actually planned to be built later; recommend redirecting each to a planned stage file or creating one when none exists.</criterion>
        <criterion>Deferred items in `architecture.md` future-features list are consistent with out-of-scope entries in stage files — each future-features bullet matches a target spec that actually owns the topic, and each stage-level Out of scope pointer is reflected in the architecture index when the destination is `specs/architecture.md`.</criterion>
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
        <criterion>Planned stages reference `features.md` for established behavior they build on; implemented stage files serve as historical records for audit, so behavior references in planned stages point to `features.md`.</criterion>
        <criterion>No planned stage links to an implemented (`✓ Implemented`) or in-progress (`In Progress`) stage file from **Dependencies**, **Desired behavior**, **Scope boundary**, **Implementation steps**, or **Tests and verification**. Scan every planned stage and flag each such link as an issue — the correct pointer for already-built behavior is always `specs/features.md`, regardless of which past stage delivered it. The fix is to redirect the link to the matching `features.md` topic. Origin-stage information is not preserved at the reference site; once behavior is in `features.md` it is simply an implemented feature.</criterion>
      </feature_documentation_alignment>

      <stage_format_compliance>
        <criterion>Every planned stage file uses exactly the required section set: Title, Status, Goal, Dependencies, Desired behavior, Scope boundary, Implementation steps, Tests and verification, Out of scope. Flag extra or missing sections.</criterion>
        <criterion>Each top-level item in "Tests and verification" is a verification topic — a descriptive heading grouping ~2–3 related behavioral checks. Flag flat lists where each bullet is one isolated check instead of a grouped topic.</criterion>
        <criterion>Behavior descriptions across planned stages state what the system does directly. Flag stages where **Goal**, **Desired behavior**, **Implementation steps**, or **Tests and verification** define behavior through negation or contrast ("not X", "unlike Y") instead of positive statements; **Scope boundary** and **Out of scope** are exempt.</criterion>
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
