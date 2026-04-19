---
name: spec_init
description: "Bootstraps the StagedSpec framework in a new project: creates the /specs folder, guardrail documents (intent.md, security.md, testing.md), architecture.md index, optional features.md for existing code, and optional initial stage specs. Use when a project has no /specs folder or is missing guardrail documents."
---

<task_block>
  <role>StagedSpec — Framework Initializer</role>

  <objective>
    Bootstrap the `/specs` folder in a project that has none, or recover a project with missing guardrail documents (`intent.md`, `security.md`, `testing.md`). Skip this skill entirely when all four core files already exist in `/specs`: `architecture.md`, `intent.md`, `security.md`, `testing.md`.
  </objective>

  <inputs>
    <input>Analyze whatever the user has provided: PRDs, design docs, existing code, README, or a verbal description.</input>
    <input>Treat existing code as signal for intent — extract the commitments and constraints it reveals as outcome-level statements for guardrail documents, keeping implementation details out.</input>
  </inputs>

  <policy>
    <branch_gating>
      <rule>**Complete this step before creating or modifying any file under `/specs`.**</rule>
      <rule>The hook system blocks all edits to `specs/intent.md`, `specs/security.md`, and `specs/testing.md` unless the current git branch name contains both `guardrail` and `spec`.</rule>
      <rule>If the user is already on a qualifying branch, confirm it matches the pattern and continue.</rule>
      <rule>Otherwise, create and switch to a new branch named `guardrail/spec-init` (or any name containing both words).</rule>
      <rule>Confirm the branch is active before proceeding to information gathering.</rule>
    </branch_gating>

    <seed_information>
      <rule>From the user's input, extract what is known.</rule>
      <rule>Ask only what is needed to begin the first document — a single focused question set covering core purpose, rough domain boundaries, and any hard architectural decisions is enough to start.</rule>
      <rule>Mark everything else as `[UNDERSPECIFIED]` and move on; gaps are filled per document.</rule>
    </seed_information>

    <create_and_refine_documents>
      <rule>Create documents in dependency order — each document informs the next:</rule>
      <rule>**`specs/intent.md` → `specs/security.md` → `specs/testing.md` → `specs/architecture.md` → if existing code is present: `specs/features.md`**</rule>

      <per_document_loop>
        <rule>For each document in order:</rule>
        <loop_step>**Draft and write** from currently known information. Fill what is clear; mark unknowns as `[UNDERSPECIFIED]`. Write the file to disk immediately.</loop_step>
        <loop_step>**Ask** only the questions needed to resolve critical gaps in this document. Use the `AskUserQuestion` tool when possible. Keep it focused — one or two questions at most per round. Defer anything that can wait.</loop_step>
        <loop_step>**Revise and update** the file on disk based on the user's answers.</loop_step>
        <loop_step>**Repeat** steps 2-3 until the document is consistent with what the user has confirmed and all remaining gaps are explicitly marked or solved.</loop_step>
        <loop_step>Move to the next document when the user is satisfied or all gaps are closed.</loop_step>
      </per_document_loop>

      <loop_rules>
        <rule>Mark unclear items as `[UNDERSPECIFIED]` when the user has not answered; use guessing only as a last resort.</rule>
        <rule>Proceed past gaps that can be deferred. The document can be useful and consistent without being complete.</rule>
        <rule>When the user answers a question that affects an already-written document, go back and update it before continuing.</rule>
        <rule>When multiple questions are needed at once, use the `AskUserQuestion` tool — it presents them as a structured form.</rule>
        <rule>Ask as few questions as possible. Focus on consistency; defer edge cases and wording nitpicks.</rule>
      </loop_rules>

      <document_guidance>
        <intent_document>Use the spec_development skill and follow its spec_intent reference for the full structure and creation rules. Six sections: Core Purpose, Architectural Commitments, Domain Boundaries, Key Invariants, Integration Contract Surface, Intentional Constraints. Every item must be falsifiable. Keep implementation details out. 15-25 items total; fewer if the project is genuinely simple.</intent_document>
        <security_document>Security constraints aligned to the stack and threat model. Cover authentication model, data classification, trust boundaries, secrets management. Outcome-focused: what must hold.</security_document>
        <testing_document>Testing strategy aligned to the stack. Cover test levels and purpose, framework choices, coverage policy, CI requirements, and what constitutes a passing build.</testing_document>
        <architecture_document>Index file. One-paragraph project summary linking to `specs/intent.md`, global constraints section linking to the other guardrail documents, explicit out-of-scope section, staged specs section, future features list. Use the spec_development skill and follow its single_stage_structure reference for stage formatting.</architecture_document>
        <features_document>Only create this file when the project has existing code. Read the code to discover observable behavior and document it in behavior-first form (runtime outcomes). Keep implementation details out. For greenfield projects, omit this file — it will be created when the first stage is implemented.</features_document>
        <initial_stage_specs>Only if scope is clear enough. Use the spec_development skill and follow its single_stage_structure reference for stage formatting. If scope is still uncertain, stop at architecture.md and let the user drive stage planning through normal refinement.</initial_stage_specs>
      </document_guidance>
    </create_and_refine_documents>

    <validation_pass>
      <rule>After all documents are written, check cross-document consistency:</rule>
      <check>Every item in `intent.md` is falsifiable and contains no implementation details.</check>
      <check>`security.md` and `testing.md` align with all intent items without contradictions.</check>
      <check>`architecture.md` links to all guardrail documents and its out-of-scope section aligns with `intent.md` domain boundaries.</check>
      <check>`features.md` documents only actually implemented behavior — nothing planned.</check>
      <check>If initial stage specs were created, they reference only prior stages (no forward dependencies) and align with all guardrail documents.</check>
    </validation_pass>
  </policy>

  <output_contract>
    <response_shape>
      <rule>Report inconsistencies to the user and propose fixes.</rule>
      <rule>When everything is consistent, suggest the user commits the created files.</rule>
    </response_shape>
  </output_contract>
</task_block>
