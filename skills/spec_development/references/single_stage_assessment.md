<task_block>
  <role>Single Stage Assessment</role>

  <objective>
    <summary>Assess one or more stage spec files for implementation readiness. This guide defines the review procedure and output format — not requirements for the specs themselves. Assess spec content and format against the quality criteria in [single_stage_structure.md](single_stage_structure.md). For assessing the spec framework as a whole, use [framework_assessment.md](framework_assessment.md).</summary>
    <writing_style>Apply concise, positive, action-oriented writing throughout the review.</writing_style>
    <goal>Surface issues that affect correct, complete implementation by a one-shot AI coding agent that receives the spec as its sole input and produces a full implementation in a single pass. Every issue must be evaluated against that bar.</goal>
  </objective>

  <policy>
    <intent>
      <rule>Read the spec thoroughly and surface any issue that could affect a correct, complete implementation — not limited to format or structure.</rule>
      <rule>This includes but is not limited to:</rule>
    </intent>

    <decision_rules>
      <rule>internal contradictions, including behavioral contradictions where one part of the spec makes another part non-functional</rule>
      <rule>missing or ambiguous requirements that can lead to divergent implementations</rule>
      <rule>missing ownership or contract details required for correct implementation</rule>
      <rule>stage or dependency inconsistencies across linked specs</rule>
      <rule>cross-stage and feature-file consistency: verify that the stage aligns with the feature file and previously implemented stages; flag any requirement that overrides, reverses, contradicts or conflicts with established behavior</rule>
      <rule>scope fit against the broader spec set: aspects that duplicate or conflict with what an existing future spec already owns, or that sit outside the current stage's stated boundary</rule>
      <rule>later-stage leakage: any behavior, requirement, or dependency that belongs to a stage after the current one must stay out of the spec's implementation sections — the spec must be fully implementable without anything from later stages. References or links to later stages inside implementation sections are a direct signal that the spec is not implementation-ready. Relocated content must always have a verified destination. Classify each relocated aspect and determine its correct destination:</rule>
      <relocation_classification>
        <classification>**Later stage in the current version** (e.g., a later v1 stage): remove from implementation sections, verify the target stage file exists and is the correct destination, and add any detail it lacks. If no suitable target exists, flag that a new stage file must be created.</classification>
        <classification>**Beyond the current version** (e.g., v2/v3 territory): remove from implementation sections, verify or create the target future-version spec. Treat this as a signal against overengineering — the current version should build only what it needs.</classification>
        <classification>**Guardrail violation** (contradicts `specs/intent.md`, `specs/security.md`, or `specs/testing.md`): remove from implementation sections, place in no future stage file, and flag it for the global **Out of scope** section in `specs/architecture.md` with a note citing the guardrail constraint it violates. Mention the removal in the assessment summary.</classification>
        <classification>All relocated aspects go into the current spec's **Out of scope** section. Use one bullet per destination: lead with a single link to the destination file (future stage spec or `specs/architecture.md`), followed by a comma-separated list of the deferred items sharing that destination. Write the removed content into the target stage file so it remains implementable — the Out of scope entry is only the pointer.</classification>
      </relocation_classification>
      <rule>test design quality: verify items should map to grouped, cohesive test functions — not 1:1. Flag when the spec treats its verify list as a test count target, when tests duplicate guarantees already enforced by the language, type system, or framework instead of targeting behavioral correctness, or when cross-stage handoff points lack integration tests</rule>
      <rule>false underspecification: requirements that appear missing in the current spec but are already established by an earlier stage — flag these only when the dependency link is missing, not when the behavior itself is covered</rule>
      <rule>logical gaps where specified behavior, commands, scripts, or workflows would fail under the spec's own stated constraints or preconditions</rule>
      <rule>unstated assumptions that an implementer would need to guess at</rule>
      <rule>over-specification: constraints that narrow intentional implementation flexibility without adding correctness value, causing an AI agent to implement a specific design when the spec deliberately left room for implementation choice</rule>
      <rule>guardrail violations: any aspect of the spec that contradicts or exceeds the boundaries set by the project's guardrail documents (`specs/intent.md`, `specs/security.md`, `specs/testing.md`). When these documents exist, read them and verify the spec stays within their declared constraints — domain boundaries, architectural commitments, key invariants, security requirements, and testing strategy. Flag any spec content that would cause an implementation to violate a guardrail constraint, citing the specific guardrail item being violated</rule>
    </decision_rules>
  </policy>

  <output_contract>
    <response_shape>
      <rule>Output format (use exactly this structure):</rule>
      <template>
# General assessment
Write one short paragraph stating whether the spec is implementation-ready and why.

## Issues
If no issues exist, output exactly:
No issues found.

Otherwise, list all issues as a single ordered list. Order by how likely each issue is to cause a wrong or divergent result in a one-shot, fully AI-driven implementation of the spec — most problematic first. Use the evaluation criteria (ambiguity, contradiction, under-specification, over-specification, scope fit, missing ownership, dependency gaps, logical gaps, unstated assumptions) as the lens for ranking.

1. **[short title]** — one paragraph: what is wrong, implementation impact, and the minimum clarification or fix needed.
2. **[short title]** — same structure.
(continue as needed)
      </template>
    </response_shape>

    <inclusion_rule>Include every identified issue regardless of size. Even minor clarity improvements belong at the bottom of the list.</inclusion_rule>
  </output_contract>
</task_block>
