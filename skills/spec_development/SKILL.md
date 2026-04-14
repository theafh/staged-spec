---
name: spec_development
description: "StagedSpec: Guides iterative development and assessment of project specs in /specs with an architecture index, staged specs, implemented status tracking, and feature documentation. Use when creating, refining, or checking specs, architecture.md, stage files, features.md, security.md, or testing.md."
---

<task_block>
  <role>StagedSpec — Spec Development</role>

  <objective>
    The skill drives iterative, human-in-the-loop refinement; the target quality bar is a spec that a one-shot AI coding agent can implement correctly from the spec alone.
  </objective>

  <inputs>
    <input>Use a `/specs` folder at the project root for all specification documents.</input>
    <input>Use `specs/architecture.md` as the single index and entry point with stage links, status markers, global constraints, and future features.</input>
    <input>Keep global constraints visible in `specs/architecture.md`, including links to `specs/intent.md`, `specs/security.md`, and `specs/testing.md`.</input>
    <input>When `specs/security.md` or `specs/testing.md` are missing, point the user to the spec_init skill for full framework bootstrap.</input>
    <input>The following files are project-level guardrails, not regular stage deliverables:</input>
    <input>`specs/intent.md` — project identity and non-negotiable boundaries.</input>
    <input>`specs/security.md` — security constraints and threat model.</input>
    <input>`specs/testing.md` — testing strategy and quality requirements.</input>
  </inputs>

  <policy>
    <intent>
      <rule>Treat the full `/specs` set as one system: improve clarity and consistency without eroding already-established valid behavior.</rule>
      <rule>Keep specs contradiction-free and outcome-focused; include implementation detail only when required for correctness, safety, or integration.</rule>
      <rule>Add an explicit out-of-scope section in `specs/architecture.md` to prevent scope creep.</rule>
      <rule>Plan staged work to reduce avoidable refactors by keeping scope cohesive, dependencies explicit, and build order free of forward dependencies.</rule>
      <rule>Size of each stage must be the most compact scope that delivers a meaningful, testable capability —> the fundamental unit a one-shot AI coding agent can implement correctly in a single pass.</rule>
      <rule>Use the staged plan to guide steady progress while balancing over-engineering with under-specification.</rule>
    </intent>

    <decision_rules>
      <rule>Rules for guardrail documents:</rule>
      <rule>Never create, modify, or delete a guardrail document as a side-effect of stage creation, refinement, implementation, or status updates.</rule>
      <rule>Changes to guardrail documents require an explicit, direct request from the human user in the current conversation.</rule>
      <rule>When a stage update conflicts with a guardrail document, fix the stage spec to align with the guardrail. Escalate to the user when alignment requires a trade-off or when the conflict touches a core constraint.</rule>
      <rule>Stage specs may reference guardrail documents (e.g., in a **Read first** section) but must not alter their content.</rule>
      <rule>Automated or batch workflows that touch multiple specs must skip guardrail documents entirely.</rule>
      <rule>Preserve history when restructuring tracked spec files: use `git mv` for renames/moves and `git rm` for permanent retirement.</rule>
    </decision_rules>
  </policy>

  <output_contract>
    <response_shape>
      <rule>When initializing a new project or bootstrapping the `/specs` folder, point the user to the spec_init skill.</rule>
      <rule>When creating, refining, or implementing specs, read [references/single_stage_structure.md](references/single_stage_structure.md).</rule>
      <rule>When reviewing or checking a single stage spec for implementation readiness, read [references/single_stage_assessment.md](references/single_stage_assessment.md).</rule>
      <rule>When assessing the spec framework as a whole for completeness and coherence, read [references/framework_assessment.md](references/framework_assessment.md).</rule>
      <rule>When creating, validating, or checking alignment against the project intent, read [references/spec_intent.md](references/spec_intent.md).</rule>
    </response_shape>
  </output_contract>
</task_block>
