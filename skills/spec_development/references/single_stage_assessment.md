<task_block>
  <role>Single Stage Assessment</role>

  <objective>
    <summary>Assess one or more stage spec files for implementation readiness. This guide defines the review procedure and output format — not requirements for the specs themselves. Assess spec content and format against the quality criteria in [single_stage_structure.md](single_stage_structure.md). For assessing the spec framework as a whole, use [framework_assessment.md](framework_assessment.md).</summary>
    <writing_style>Apply concise, positive, action-oriented writing throughout the review.</writing_style>
    <goal>Surface issues that affect correct, complete implementation by a one-shot AI coding agent that receives the spec as its sole input and produces a full implementation in a single pass. Every issue must be evaluated against that bar.</goal>
  </objective>

  <policy>
    <structural_compliance>
      <rule>Run this structural check first, before any content assessment. Structural violations are high-severity issues — a one-shot implementer follows the spec literally, so wrong structure causes wrong output.</rule>
      <checks>
        <check>**Required sections only.** The required set is: Title, Status, Goal, Dependencies, Desired behavior, Scope boundary, Implementation steps, Tests and verification, Out of scope. Flag any section that falls outside this list — the spec structure is exhaustive and additional sections are not permitted. Flag any missing required section.</check>
        <check>**Verification topic format.** Each top-level item in "Tests and verification" must be a verification topic — a descriptive heading grouping ~2–3 related behavioral checks (e.g., "**Token refresh** — refresh triggers before expiry, returns a valid token, updates stored credentials"). Flag flat lists where each bullet is one isolated behavioral check instead of a grouped topic.</check>
      </checks>
    </structural_compliance>

    <intent>
      <rule>Read the spec thoroughly and surface any issue that could affect a correct, complete implementation — not limited to format or structure.</rule>
      <rule>This includes but is not limited to:</rule>
    </intent>

    <decision_rules>
      <rule>internal contradictions, including behavioral contradictions where one part of the spec makes another part non-functional</rule>
      <rule>missing or ambiguous requirements that can lead to divergent implementations</rule>
      <rule>missing ownership or contract details required for correct implementation</rule>
      <rule>stage or dependency inconsistencies across linked specs</rule>
      <rule>feature-file consistency: verify that the stage aligns with `specs/features.md` as the authoritative record of established behavior; flag any requirement that overrides, reverses, contradicts, or conflicts with what `features.md` documents. Source all behavioral context from `features.md` — treat implemented stage files as historical records for audit only</rule>
      <rule>implemented-stage leakage: flag every reference to an implemented (`✓ Implemented`) or in-progress (`In Progress`) stage file that appears in **Dependencies**, **Desired behavior**, **Scope boundary**, **Implementation steps**, or **Tests and verification**. Once a stage reaches those statuses, its behavior is owned by `specs/features.md`; the stage file it originated from is not the correct pointer — it is simply implemented behavior, and which past stage delivered it is irrelevant. Recommend redirecting each such reference to the matching `features.md` topic (with a section anchor where available). This check is independent of whether the referenced behavior is actually established — do not assume an implemented-stage link is acceptable just because the behavior exists. The fix is always the same: replace the stage-file pointer with the `features.md` pointer. **Out of scope** may still mention later planned stages; it must never point at implemented or in-progress stage files either, because already-built behavior belongs in **Dependencies** via `features.md`, not in Out of scope</rule>
      <rule>scope fit against the broader spec set: aspects that duplicate or conflict with what an existing future spec already owns, or that sit outside the current stage's stated boundary</rule>
      <rule>later-stage leakage: implementation sections describe only what this stage will build, grounded in established behavior from `specs/features.md` and direct prerequisites from earlier planned stages. Place all references to later stages exclusively in **Out of scope**. The spec is implementation-ready when it can be fully implemented using only current system capabilities and its stated prerequisites. Relocate each later-stage aspect to a verified destination:</rule>
      <relocation_classification>
        <classification>**Later stage in the current version** (e.g., a later v1 stage): remove from implementation sections, verify the target stage file exists and is the correct destination, and add any detail it lacks. If no suitable target exists, flag that a new stage file must be created.</classification>
        <classification>**Beyond the current version** (e.g., v2/v3 territory): remove from implementation sections, verify or create the target future-version spec. Treat this as a signal against overengineering — the current version should build only what it needs.</classification>
        <classification>**Guardrail violation** (contradicts `specs/intent.md`, `specs/security.md`, or `specs/testing.md`): remove from implementation sections, place in no future stage file, and flag it for the global **Out of scope** section in `specs/architecture.md` with a note citing the guardrail constraint it violates. Mention the removal in the assessment summary.</classification>
        <classification>All relocated aspects go into the current spec's **Out of scope** section. Use one bullet per destination: lead with a single link to the destination file (future stage spec or `specs/architecture.md`), followed by a comma-separated list of the deferred items sharing that destination. Write the removed content into the target stage file so it remains implementable — the Out of scope entry is only the pointer.</classification>
      </relocation_classification>
      <rule>Out of scope target verification (bidirectional audit): treat every deferral as requiring **two coexisting records** — (1) the pointer in the current spec's Out of scope section, which guides auto-shaping, boundary reasoning, and the forward path to the target; and (2) the implementable content in the target file, which is what actually gets built when the future stage runs. Both records are required; a fix that strengthens one side never removes the other. Open every entry in the current spec's Out of scope section and read the referenced target file — future stage spec or `specs/architecture.md`. For each deferred item listed in the entry, confirm the target file exists and already owns that item with implementable specification detail (either as an explicit Desired behavior item, an Implementation step, or a clearly scoped section). Flag entries in these shapes:</rule>
      <out_of_scope_audit_shapes>
        <shape>**Missing target file** — the referenced file does not exist yet. Recommend creating it (`v<version>-stage-<number>-<short-name>.md` with Planned status) and registering it in `specs/architecture.md`.</shape>
        <shape>**Missing topic coverage** — the target file exists but contains no matching requirement for a deferred item. Recommend writing the relocated content into the target so it fully owns the deferred topic.</shape>
        <shape>**Stub or underdeveloped coverage** — the target file mentions the topic only as a heading, a single line, or a vague placeholder without enough detail to be implementable. Recommend expanding the target entry to the detail level the current spec implies.</shape>
        <shape>**Inconsistent ownership** — the deferred item duplicates, contradicts, or overlaps with ownership in a different target than the one the Out of scope entry names. Recommend consolidating ownership in one file and correcting the pointer.</shape>
        <shape>**Invalid destination (already-built behavior)** — the Out of scope entry points at `specs/features.md` or an implemented/in-progress stage file. Redirect the pointer to the planned future stage file that will own the deferred work, or create one with Planned status when none exists. When the topic is already covered by `features.md`, remove the Out of scope entry and move the reference to **Dependencies** if the stage builds on that behavior.</shape>
        <shape>**Architecture.md misuse** — the Out of scope entry points at `specs/architecture.md` for a deferred item that is actually planned to be built later (typical shape: scope creep pushed out of the current stage). Redirect the pointer to the correct planned future stage file, creating one with Planned status when none exists. Reserve `specs/architecture.md` as an Out of scope destination for items globally out of scope — scope that should never be built because it violates `specs/intent.md`, `specs/security.md`, or `specs/testing.md`, or sits outside the declared project domain.</shape>
      </out_of_scope_audit_shapes>
      <rule>Surface every shape above as an explicit issue in the assessment output so a fix pass can reconcile the bidirectional contract. Also flag the reverse case: a target stage that already owns implementable detail for a topic while the earlier spec — whose scope would otherwise include it — lacks an Out of scope pointer to that target. In that case the fix adds the Out of scope entry to the earlier spec; the target content stays. Every deferral must be matched by real, implementable ownership in the named target **and** by an explicit Out of scope pointer in the source spec — both sides remain present after every fix.</rule>
      <rule>test design quality: flag verification topics that duplicate guarantees already enforced by the language, type system, or framework instead of targeting behavioral correctness, and flag when cross-stage handoff points lack integration topics</rule>
      <rule>phrasing and framing: flag behavior descriptions in **Goal**, **Desired behavior**, **Implementation steps**, or **Tests and verification** that define what the system does through negation or contrast ("not X", "unlike Y", "this is not Z") rather than direct positive statements. A one-shot implementer infers the actual behavior from the implied contrast and diverges. Recommend rewriting as a direct statement that preserves all technical detail (error codes, thresholds, constraints). Exception: **Scope boundary** and **Out of scope** may state exclusions directly.</rule>
      <rule>false underspecification: requirements that appear missing in the current spec but are already established in `specs/features.md` — flag these only when the dependency link to `features.md` is missing, not when the behavior itself is covered</rule>
      <rule>logical gaps where specified behavior, commands, scripts, or workflows would fail under the spec's own stated constraints or preconditions</rule>
      <rule>unstated assumptions that an implementer would need to guess at</rule>
      <rule>over-specification: constraints that narrow intentional implementation flexibility without adding correctness value, causing an AI agent to implement a specific design when the spec deliberately left room for implementation choice</rule>
      <rule>scope sizing: flag stages where the scope is too large for a one-shot implementation pass (would require multiple passes to get right, high risk of partial or incorrect implementation) or too small to deliver meaningful, independently testable behavior (adds coordination overhead without delivering a coherent capability on its own). The target is the most compact scope that still drives meaningful progress</rule>
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
