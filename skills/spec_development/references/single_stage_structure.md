<task_block>
  <role>Single Stage Structure</role>

  <objective>
    Defines what a single stage spec must look like — required sections, naming, paragraph discipline, dependency discipline, scope boundary, and Out of scope formatting. For the refinement workflow and the menu of moves that bring a stage toward implementation-readiness, see [single_stage_refinement.md](single_stage_refinement.md). For the assessment pass that flags issues, see [single_stage_assessment.md](single_stage_assessment.md).
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
    <stage_placement_on_creation>
      <rule>Place every new planned stage at the position its dependencies dictate — insert it immediately after its latest prerequisite so later stages build on a stable foundation.</rule>
      <rule>When a split produces new stages inside a tier whose stages are already ordered, number the new stages sequentially at their correct slot and renumber every later stage in the same tier to keep the chain contiguous. Use `git mv` for renames and update references in `specs/architecture.md` and every cross-reference that names a renumbered file.</rule>
      <rule>Choose the destination tier by matching the new stage's scope against the tier purposes declared in `specs/architecture.md` (typically v1 = minimum working product, v2 = core differentiators, v3 = advanced enhancements). A new stage may move to a later tier than the source when its scope fits that tier's purpose; within the chosen tier, place it where it is the base for the stages that follow.</rule>
    </stage_placement_on_creation>
    <rule>Use exactly this required stage structure. These sections are the complete and exhaustive set — every piece of stage content belongs in one of these sections. Integrate all information into the matching section; create no additional sections.</rule>
    <required_stage_structure>
      <item>Title line with the stage name</item>
      <item>`**Status**:` Planned | In Progress | ✓ Implemented</item>
      <item>`**Goal**:` one-sentence outcome</item>
      <item>**Dependencies**: link to `specs/features.md` for every piece of already-implemented behavior this stage builds on, and to earlier planned stage files only for capabilities those planned stages will introduce that this stage requires. **Never reference implemented or in-progress stage files as dependencies** — once a stage reaches `✓ Implemented` or `In Progress`, its behavior is owned by `specs/features.md` and that is the only correct pointer, regardless of which stage originally delivered it. The origin stage becomes irrelevant the moment the behavior is recorded in `features.md`. Use valid relative markdown links (e.g., `[Features — Auth](../features.md#authentication)`, `[Stage 4 — Session refresh (Planned)](v1-stage-4-session-refresh.md)`).</item>
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
      <rule>Omit topics that duplicate guarantees already enforced by the language, type system, or framework (e.g., type checks in compiled languages, schema enforcement by an ORM, validation built into a framework). When a behavior is fully covered by such guarantees, cite the framework guarantee in the spec as the coverage source and reserve verification topics for behavior that requires explicit testing.</rule>
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
          <rule>Treat implemented and in-progress stage files as historical records for audit and link validation only — source all behavioral context from `specs/features.md`.</rule>
          <rule>**Do not reference implemented or in-progress stage files anywhere outside audit contexts.** Dependencies, Desired behavior, Scope boundary, Implementation steps, and Tests and verification must reference `specs/features.md` for established behavior — never the stage file that originally delivered that behavior. The fact that a capability was built in stage 2 versus stage 5 is irrelevant once it is captured in `features.md`; it is simply an implemented feature. Replace every implemented-stage pointer with the matching `features.md` link.</rule>
        </context_hierarchy>
        <rule>Place one canonical dependency reference per prerequisite within the content. Consolidate repeated references to the same spec into one clear paragraph with one link per target.</rule>
        <rule>When consolidating repeated references, preserve required constraints and context; improve clarity without skipping requirements, introducing scope creep, or over-compressing intent.</rule>
      </reference_discipline>

      <scope_boundary_discipline>
        <rule>Keep stage spec content implementation-focused: describe what this stage will implement and how, grounded in the system's current behavior as documented in `specs/features.md`.</rule>
        <rule>Place all forward-looking references exclusively in the **Out of scope** section. Verify that implementation sections reference only established behavior (`features.md`) and direct planned prerequisites — move any later-stage references to Out of scope.</rule>
        <rule>Reference `specs/features.md` for established behavior. Reference planned stage files only when they are direct prerequisites for the current stage's implementation. Implemented and in-progress stage files are never valid references in implementation sections — their behavior is `features.md` content.</rule>
        <rule>Link every mentioned stage or spec with a valid relative markdown link. Use `[Features — Auth](../features.md#authentication)` for established behavior and `[Stage 4 — Session refresh (Planned)](v1-stage-4-session-refresh.md)` for planned prerequisites. Convert bare names to proper links. Never link to an implemented or in-progress stage file from an implementation section — redirect to the matching `features.md` topic instead.</rule>
      </scope_boundary_discipline>

      <relocating_to_out_of_scope>
        <purpose>Out of scope drives staged progression: push scope creep from the current stage into the planned stage that will own the work, so the current stage stays one-shot-implementation-ready and later stages have clear owners for relocated content.</purpose>
        <rule>Make a planned future stage file (`v<version>-stage-<number>-<short-name>.md` or future `v<version>-<short-name>.md`) the destination for every deferred-but-buildable item. Write the relocated detail into that target file so it remains implementable. When no suitable target exists, create a new planned stage file with Planned status and register it in `specs/architecture.md`.</rule>
        <rule>Use `specs/architecture.md` as an Out of scope destination **only** for items globally out of scope for the entire project — scope that should never be built because it violates `specs/intent.md`, `specs/security.md`, or `specs/testing.md`, or sits outside the declared project domain. Architecture.md is not a generic destination for misplaced content.</rule>
        <rule>Link Out of scope entries only at files describing work not yet built. `specs/features.md` and implemented/in-progress stage files record already-built behavior; when the stage builds on them, link from **Dependencies** instead.</rule>
        <rule>Organize Out of scope as one bullet per destination: lead with a single link to the destination, followed by a comma-separated list of the deferred items sharing that destination. Keep entries concise — list what was deferred, not why or how. The implementable detail lives in the target file; the Out of scope entry is only the pointer.</rule>
      </relocating_to_out_of_scope>
    </reference_and_scope_discipline>

    <code_artifact_naming>
      <rule>Name every code artifact — files, modules, classes, functions, variables, and tests — after the feature or observable behavior it represents, so each identifier reads as the behavior it delivers. Reserve stage labels (stage numbers, stage short-names, the literal word "stage") for spec files under `specs/` and for `specs/architecture.md`, where they serve as spec-organization markers. Write verification topic headings, and the test function names derived from them, as feature-oriented names describing observable behavior (e.g., `token_refresh`, `auth_failure_handling`).</rule>
    </code_artifact_naming>

    <phrasing_discipline>
      <rule>Write **Goal**, **Desired behavior**, **Implementation steps**, and **Tests and verification** as direct, positive statements of what the system does, accepts, returns, or enforces. A one-shot implementer builds from the wording literally — contrastive or negated framings ("not X", "unlike Y", "this is not Z") force the implementer to infer the real behavior from an implied contrast and cause divergence during refinement and implementation.</rule>
      <rule>Rewrite contrastive statements as direct ones while preserving every technical detail — error codes, edge cases, thresholds, and constraints stay intact in the rewrite.</rule>
      <transformation_examples>
        <example>"The parser does not accept trailing commas" → "The parser rejects trailing commas and raises `SYNTAX_ERROR` at the offending position."</example>
        <example>"Unlike the legacy handler, this one returns JSON" → "The handler returns JSON with `Content-Type: application/json`."</example>
        <example>"This is not a streaming API" → "The API returns the full response body in a single synchronous call."</example>
      </transformation_examples>
      <rule>**Scope boundary** and **Out of scope** may state exclusions directly — exclusion is their purpose. Write them as concrete boundaries (what is deferred, which file owns what), not as definitions of in-scope behavior through negation.</rule>
    </phrasing_discipline>

    <refinement_pointer>
      <rule>When refining or iterating a stage spec toward implementation-readiness, follow [single_stage_refinement.md](single_stage_refinement.md). It defines the refinement workflow and the full menu of moves (add detail, remove over-specification, relocate to Out of scope, split, merge, reorder dependencies).</rule>
    </refinement_pointer>
  </policy>

  <output_contract>
    <after_spec_execution>
      <rule>Keep guardrail documents (`specs/intent.md`, `specs/security.md`, `specs/testing.md`) unchanged during post-execution updates. If implemented code violates a guardrail, always escalate to the user. The only acceptable path forward is user-driven resolution; any alternative — including marking the stage implemented or adjusting documentation to fit the conflict — requires explicit user approval through the escalation.</rule>
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
