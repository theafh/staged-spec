<task_block>
  <role>Single Stage Refinement</role>

  <objective>
    <summary>Drive a single stage spec toward implementation-readiness — the point where a one-shot AI coding agent can implement it correctly from the spec alone. This reference defines the refinement workflow and the full menu of moves available to bring a spec to that bar. Use [single_stage_structure.md](single_stage_structure.md) for what a stage spec must look like, and [single_stage_assessment.md](single_stage_assessment.md) for what an assessment pass flags as an issue.</summary>
    <goal>Reconcile each flagged issue with the smallest change that preserves established requirements and moves the spec closer to implementation-ready.</goal>
  </objective>

  <policy>
    <refinement_principles>
      <rule>Guardrail documents (`specs/intent.md`, `specs/security.md`, `specs/testing.md`) stay out of scope for refinement passes. When a refinement conflicts with a guardrail, fix the stage spec to align with the guardrail. Escalate to the user when alignment requires a trade-off or touches a core constraint.</rule>
      <rule>Refine with restraint: preserve intentional implementation flexibility unless additional specificity is required for correctness.</rule>
      <rule>Preserve established, non-contradictory requirements; remove or rewrite only for explicit reasons — contradiction resolution, scope change, or relocation due to split/restructure.</rule>
      <rule>When moving content between specs, relocate it to the correct file and keep the full spec set complete; always preserve required behavior.</rule>
      <rule>Keep future stages adjustable until implementation begins — treat planned text as directional, not fixed design. Allow changes to already implemented stages when required, and use forward-facing stage design to reduce churn.</rule>
    </refinement_principles>

    <refinement_moves>
      <rule>Every refinement pass has a full menu of moves to reach implementation-readiness. Treat every move below as a first-class option — adding detail is one move among several, equal in weight to removing, relocating, splitting, merging, or reordering. Choose the move that best fits the issue at hand:</rule>
      <move>
        <name>Add clarifying detail</name>
        <when>A requirement, acceptance criterion, boundary, or contract is ambiguous, silent on a decision point, or leaves an implementer to guess. Missing dependency links to `specs/features.md` for established behavior also fall here.</when>
        <how>Write the minimum specification the implementer needs to choose correctly — concrete inputs/outputs, contracts for flags and environment variables, error behavior at known boundaries. Ground the added detail in current behavior from `specs/features.md` and existing code, not in newly invented design.</how>
      </move>
      <move>
        <name>Remove over-specification</name>
        <when>A constraint narrows intentional implementation flexibility without adding correctness value, or the spec prescribes a specific design where it deliberately meant to leave room for implementation choice.</when>
        <how>Strip the constraint and restate the requirement as an outcome. Keep the surrounding context intact so the remaining specification still reads cleanly.</how>
      </move>
      <move>
        <name>Relocate to Out of scope</name>
        <when>An aspect belongs to a later stage in the current version, a future version, or is globally out of scope. Details are in [single_stage_assessment.md](single_stage_assessment.md) relocation_classification.</when>
        <how>Remove the aspect from implementation sections, add an Out of scope pointer to the target destination in the source spec, and write the full implementable detail into the target file (or `specs/architecture.md` for globally out-of-scope items). The bidirectional contract holds: both the source pointer and the target content must exist after the move.</how>
      </move>
      <move>
        <name>Split into a new stage file</name>
        <when>The current stage carries two or more clearly separable concerns and no existing future stage owns one of them, or scope sizing shows the stage is too large for a single one-shot implementation pass.</when>
        <how>Create each new stage file (`v&lt;version&gt;-stage-&lt;number&gt;-&lt;short-name&gt;.md`) with Planned status, title, goal, dependencies, and the separable concern written into Desired behavior with implementable detail. Place each new stage at the position its dependencies dictate per the stage_placement_on_creation rules in [single_stage_structure.md](single_stage_structure.md) — inside an already-ordered tier, insert at the correct slot and renumber every later stage in that tier via `git mv` to keep the chain contiguous; a new stage may move to a later tier when its scope fits that tier's declared purpose in `specs/architecture.md`. Register each new file in `specs/architecture.md` with its status and link. Add an Out of scope pointer from the source stage to each new file.</how>
      </move>
      <move>
        <name>Merge with an adjacent stage</name>
        <when>A stage is too small to deliver a meaningful, independently testable capability on its own, and an adjacent stage shares the same cohesive concern.</when>
        <how>Consolidate the two files into one, keeping the destination file's numbering intact when the merge direction is clear. Use `git mv` / `git rm` to preserve history. Update `specs/architecture.md` and every cross-reference that named the removed file. Verify link validity across the framework after the merge.</how>
      </move>
      <move>
        <name>Reorder or restructure dependencies</name>
        <when>Dependency reassessment surfaces a forward dependency, a cycle, or a prerequisite that belongs in a different stage than where it is currently specified.</when>
        <how>Reorder stages by renaming with `git mv` so each stage depends only on prior completed work. Move misplaced prerequisites into the correct stage with full detail. Update `specs/architecture.md` and cross-references. Re-verify the dependency chain end-to-end before finalizing.</how>
      </move>
    </refinement_moves>

    <dependency_reassessment>
      <rule>Reassess dependency quality during every refinement pass:</rule>
      <dependency_quality_checks>
        <item>validate prerequisites against `specs/features.md` (implemented behavior) and earlier planned stages (unbuilt prerequisites),</item>
        <item>evaluate intent as well as wording — a reference that names the right file but describes the wrong capability still counts as a gap,</item>
        <item>reorder or split when forward dependencies or cycles appear,</item>
        <item>redirect every link to an `✓ Implemented` or `In Progress` stage file — appearing in Dependencies, Desired behavior, Scope boundary, Implementation steps, or Tests and verification — to the matching topic in `specs/features.md`. The origin stage is irrelevant once the behavior is captured in `features.md`; the `features.md` pointer is the only correct reference for already-built behavior. Fix this whenever it appears, even when no other assessment flagged it.</item>
      </dependency_quality_checks>
    </dependency_reassessment>

    <iterative_refinement_workflow>
      <rule>Use this workflow when refining a single stage spec manually:</rule>
      <step>Confirm scope, dependencies, and expected outcome with the user.</step>
      <step>Draft using the required stage structure from [single_stage_structure.md](single_stage_structure.md).</step>
      <step>Review for internal consistency and scope fit against the broader spec set.</step>
      <step>Propose stage splits when topics are independent, or merges when scope is too small to stand alone.</step>
      <step>Choose the refinement move that best fits each issue from the menu above, and apply it.</step>
      <step>Re-verify the dependency chain end-to-end before finalizing.</step>
      <step>Treat refinement as an open-ended iterative loop until the stage is implementation-ready.</step>
    </iterative_refinement_workflow>
  </policy>
</task_block>
