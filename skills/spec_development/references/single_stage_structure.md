<task_block>
  <role>Single Stage Structure</role>

  <objective>
    Stage spec creation and refinement.
  </objective>

  <inputs>
    <rule>Use one stage per staged spec file and keep each stage focused on one cohesive, implementable unit.</rule>
    <stage_scoping_principle>
      <rule>Size each stage as the most compact scope that still delivers a meaningful, testable capability — large enough to be a coherent driver of progress, small enough that a one-shot AI coding agent can implement it correctly in a single pass from the spec alone.</rule>
      <rule>When a stage is too large to implement in one pass, split it into smaller stages that each deliver independently testable behavior.</rule>
      <rule>When a stage is too small to be meaningful on its own, merge it with an adjacent stage that shares the same cohesive concern.</rule>
    </stage_scoping_principle>
    <rule>Use consistent staged file naming (use hyphens or underscores as separators, but stay consistent within a project):</rule>
    <naming_options>
      <option>`v&lt;version&gt;-stage-&lt;number&gt;-&lt;short-name&gt;.md` when order is committed.</option>
      <option>`v&lt;version&gt;-&lt;short-name&gt;.md` for future features that are not yet ordered.</option>
    </naming_options>
    <rule>Keep stage layering strict: each stage depends only on prior stages and must be implementable, runnable, and testable without later stages.</rule>
    <rule>Use version tiers when useful:</rule>
    <version_tiers>
      <tier>v1: minimum working product.</tier>
      <tier>v2: core differentiators.</tier>
      <tier>v3: advanced enhancements.</tier>
    </version_tiers>
    <rule>Enforce version dependency order: each version builds on all prior completed versions, and each numbered stage builds on earlier stages within its version.</rule>
    <rule>Name future spec files without stage numbers until order is committed; when order is committed, rename them to staged filenames that reflect dependency order.</rule>
    <rule>Use exactly this required stage structure. These sections are the complete and exhaustive set — every piece of stage content belongs in one of these sections. Integrate all information into the matching section; create no additional sections.</rule>
    <required_stage_structure>
      <item>Title line with the stage name</item>
      <item>`**Status**:` Planned | In Progress | ✓ Implemented</item>
      <item>`**Goal**:` one-sentence outcome</item>
      <item>**Dependencies**: link to `specs/features.md` for established behavior this stage builds on, and to earlier planned stage files for capabilities this stage requires that are not yet implemented. Use valid relative markdown links (e.g., `[Features — Auth](../features.md#authentication)`, `[Stage 3 — Auth](v1-stage-3-auth.md)`).</item>
      <item>Optional **Read first** for prerequisite docs when relevant (for example `specs/security.md`, `specs/testing.md`)</item>
      <item>**Desired behavior (specification)**</item>
      <item>**Scope boundary**</item>
      <item>**Implementation steps**</item>
      <item>**Tests and verification** — each top-level item is a verification topic grouping related behavioral checks</item>
      <item>**Out of scope** — the only section that may contain forward-looking references to later stages or future versions</item>
    </required_stage_structure>
    <rule>Apply paragraph discipline:</rule>
    <paragraph_discipline>
      <item>one requirement per paragraph,</item>
      <item>consistent terminology across stage/index/features,</item>
      <item>outcomes and constraints before implementation detail,</item>
      <item>ordering that builds from foundation to dependent behavior.</item>
    </paragraph_discipline>
    <rule>For any new/changed flags or environment variables, include a config contract in the stage spec:</rule>
    <config_contract>
      <item>accepted values and normalization/parsing rules,</item>
      <item>defaults for missing/empty values,</item>
      <item>invalid-value behavior (error/warning/coercion) and where visible,</item>
      <item>deterministic fallback behavior.</item>
    </config_contract>
  </inputs>

  <policy>
    <tests_and_verification_design>
      <rule>Write each top-level item in "Tests and verification" as a verification topic with a descriptive heading, grouping ~2–3 related behavioral checks under it. The implementer maps each topic to one test function, so topic grouping directly shapes the test structure.</rule>
      <format_example>
- **Token refresh** — refresh triggers before expiry, returns a valid token, updates stored credentials
- **Auth failure handling** — invalid credentials return 401, expired tokens trigger refresh, malformed tokens are rejected
      </format_example>
      <rule>Prioritize topics that catch silent correctness bugs — behavioral errors where a wrong implementation appears to work until edge conditions surface. Examples: error classification logic, retry/backoff math, boundary enforcement, validation rules.</rule>
      <rule>Omit topics that duplicate guarantees already enforced by the language, type system, or framework (e.g., type checks in compiled languages, schema enforcement by an ORM, validation built into a framework). When a behavior is fully covered by such guarantees, note that in the spec instead of listing a verification topic for it.</rule>
      <rule>Include integration topics for cross-stage handoff points — boundaries where the current stage's output feeds into a prior or subsequent stage's input.</rule>
    </tests_and_verification_design>

    <reference_and_scope_discipline>
      <rule>Keep the main stage content implementation-focused: clearly state what the current stage will implement.</rule>
      <rule>In `Desired behavior (specification)`, describe the implementation target clearly and concretely before detailing execution steps.</rule>

      <reference_discipline>
        <rule>Link referenced spec files with valid relative markdown links; include a section anchor when it adds precision or clarity.</rule>
        <context_hierarchy>
          <rule>Use `specs/features.md` as the authoritative source for all implemented behavior. Reference feature topics and section anchors — describe what the system does today, sourced from features.md.</rule>
          <rule>Link to planned stage files only when this stage depends on capabilities those planned stages will introduce. These are real prerequisites for future work, not historical records.</rule>
          <rule>Treat implemented stage files as historical records for audit and link validation only — source behavioral context from `specs/features.md`.</rule>
        </context_hierarchy>
        <rule>Place one canonical dependency reference per prerequisite within the content. Consolidate repeated references to the same spec into one clear paragraph with one link per target.</rule>
        <rule>When consolidating repeated references, preserve required constraints and context; improve clarity without skipping requirements, introducing scope creep, or over-compressing intent.</rule>
      </reference_discipline>

      <scope_boundary_discipline>
        <rule>Keep stage spec content implementation-focused: describe what this stage will implement and how, grounded in the system's current behavior as documented in `specs/features.md`.</rule>
        <rule>Place all forward-looking references exclusively in the **Out of scope** section. Verify that implementation sections reference only established behavior (`features.md`) and direct planned prerequisites — move any later-stage references to Out of scope.</rule>
        <rule>Reference `specs/features.md` for established behavior. Reference planned stage files only when they are direct prerequisites for the current stage's implementation.</rule>
        <rule>Link every mentioned stage or spec with a valid relative markdown link (e.g., `[Features — Auth](../features.md#authentication)`, `[Stage 3 — Auth](v1-stage-3-auth.md)`). Convert bare names to proper links.</rule>
      </scope_boundary_discipline>

      <relocating_to_out_of_scope>
        <rule>When moving content from implementation sections to Out of scope, write the relocated detail into the target future-stage file so it remains implementable later. Verify the target file exists and add any detail it lacks.</rule>
        <rule>Organize the Out of scope section as one bullet point per destination. Each bullet leads with a single link to the destination — a future stage file or `specs/architecture.md` for items globally out of scope — followed by a comma-separated list of the deferred items. Group all items sharing the same destination into one bullet; use one link per bullet, not repeated links.</rule>
        <rule>Keep Out of scope entries concise: list what was deferred, not why or how it was originally written. Write the removed content into the target stage file so it remains implementable — the Out of scope entry is only the pointer.</rule>
        <rule>Items that are globally out of scope for the entire project (not deferred to a future stage) go to `specs/architecture.md` and are listed under a single bullet linking there.</rule>
      </relocating_to_out_of_scope>
    </reference_and_scope_discipline>

    <spec_refinement>
      <rule>Guardrail documents (`specs/intent.md`, `specs/security.md`, `specs/testing.md`) are out of scope for refinement passes. When a refinement conflicts with a guardrail, fix the stage spec to align with the guardrail. Escalate to the user when alignment requires a trade-off or touches a core constraint.</rule>
      <rule>Refine with restraint: preserve intentional implementation flexibility unless additional specificity is required.</rule>
      <rule>Preserve established, non-contradictory requirements; remove or rewrite only for explicit reasons (contradiction resolution, scope change, or relocation due to split/restructure).</rule>
      <rule>When moving content between specs, relocate it to the correct file and keep the full spec set complete; always preserve required behavior.</rule>
      <rule>Reassess dependency quality during refinement:</rule>
      <dependency_quality_checks>
        <item>validate prerequisites against `specs/features.md` (implemented behavior) and earlier planned stages (unbuilt prerequisites),</item>
        <item>evaluate intent as well as wording,</item>
        <item>reorder or split when forward dependencies or cycles appear.</item>
      </dependency_quality_checks>
      <rule>Use the iterative refinement workflow:</rule>
      <iterative_refinement_workflow>
        <step>Confirm scope, dependencies, and expected outcome with the user.</step>
        <step>Draft with the standard stage structure.</step>
        <step>Review for internal consistency and scope fit.</step>
        <step>Propose stage splits when topics are independent.</step>
        <step>Refine until implementation-ready.</step>
        <step>Re-verify dependency chain before finalizing.</step>
        <step>Treat refinement as an open-ended iterative loop until the stage is implementation-ready.</step>
      </iterative_refinement_workflow>
      <rule>Keep future stages adjustable until implementation; treat planned text as directional, not fixed design.</rule>
      <rule>Allow changes to already implemented stages when required, and use forward-facing stage design to reduce churn.</rule>
    </spec_refinement>
  </policy>

  <output_contract>
    <after_spec_execution>
      <rule>Keep guardrail documents (`specs/intent.md`, `specs/security.md`, `specs/testing.md`) unchanged during post-execution updates. If implemented code violates a guardrail, always escalate to the user — marking the stage as implemented or adjusting documentation to paper over the conflict is not acceptable.</rule>
      <rule>Mark a stage `✓ Implemented` only when definition of done is met:</rule>
      <definition_of_done>
        <item>claimed behavior is verified in the actual codebase (and tests/verifications where applicable), not inferred from plans/drafts,</item>
        <item>tests/verifications are listed and reflect observable behavior,</item>
        <item>implemented behavior is documented in `specs/features.md` in behavior-first form — `features.md` becomes the authoritative record of this behavior from this point forward,</item>
        <item>status is synchronized across `specs/architecture.md` and the corresponding `v*-stage-*.md` file.</item>
      </definition_of_done>
      <rule>Run a mandatory cross-file consistency check before finishing any spec/status update:</rule>
      <cross_file_consistency_check>
        <item>verify status markers match across `specs/architecture.md` and referenced `v*-stage-*.md` files,</item>
        <item>verify all behavior documented as implemented is actually present in the codebase.</item>
      </cross_file_consistency_check>
      <rule>Update `specs/features.md` immediately after implementation and verification; defer only when explicitly needed.</rule>
      <rule>Keep `specs/features.md` behavior-first: document observable runtime outcomes and constraints, not internal implementation details.</rule>
      <rule>Organize `specs/features.md` by stable topic headings; each topic should group related observable behaviors and constraints.</rule>
      <rule>Update `specs/architecture.md` links/status to reflect the implemented state and maintain the future-features list for deferred items.</rule>
      <rule>Add or maintain a verification checklist in completed stages and include implementation tasks when a traceable audit trail is needed.</rule>
    </after_spec_execution>
  </output_contract>
</task_block>
