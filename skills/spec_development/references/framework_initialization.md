<task_block>
  <role>Framework Initialization</role>

  <objective>
    Use this routine when a project has no `/specs` folder or is missing guardrail documents (`intent.md`, `security.md`, `testing.md`). Skip it entirely if the four guardrail and index files already exist in `/specs`: `architecture.md`, `intent.md`, `security.md`, `testing.md`.
  </objective>

  <inputs>
    <input>Analyze whatever the user has provided: PRDs, design docs, existing code, README, or a verbal description.</input>
    <input>Treat existing code as signal for intent — what commitments and constraints it reveals — not as content to copy into guardrail documents.</input>
  </inputs>

  <policy>
    <intent>
      <rule>**STOP. Do not create or modify any file under `/specs` until this step is complete.**</rule>
      <rule>The hook system blocks all edits to `specs/intent.md`, `specs/security.md`, and `specs/testing.md` unless the current git branch name contains both `guardrail` and `spec`.</rule>
      <rule>Before doing anything else: If the user is already on a qualifying branch, confirm it matches the pattern and continue.</rule>
      <rule>Otherwise: Create and switch to a new branch: `guardrail/spec-init` (or any name containing both words).</rule>
      <rule>Otherwise: Confirm the branch is active.</rule>
      <rule>Otherwise: Only then proceed to information gathering.</rule>
    </intent>

    <decision_rules>
      <step id="1" name="Seed information">
        <rule>From that input, extract what is known.</rule>
        <rule>Ask the user only what is needed to begin the first document — not everything upfront.</rule>
        <rule>A single focused question set covering core purpose, rough domain boundaries, and any hard architectural decisions is enough to start.</rule>
        <rule>Mark everything else as `[UNDERSPECIFIED]` and move on; gaps are filled per document, not all at once.</rule>
        <rule>Do not overwhelm the user.</rule>
        <rule>Ask the minimum needed to proceed and defer the rest.</rule>
      </step>

      <step id="2" name="Create and refine documents one at a time">
        <rule>Create documents in dependency order.</rule>
        <rule>For each document: draft it from what is known, present it to the user, refine based on feedback, then move on.</rule>
        <rule>Do not wait for complete information before drafting — start with what exists and mark gaps explicitly.</rule>
        <rule>This keeps information anchored in written documents rather than held in context, which avoids losing it as the session grows.</rule>
        <rule>The creation order matters because each document informs the next:</rule>
        <rule>**`specs/intent.md` → `specs/security.md` → `specs/testing.md` → `specs/architecture.md` → if existing code is present: `specs/features.md`**</rule>

        <per_document_loop>
          <rule>For each document in order:</rule>
          <loop_step index="1">**Draft and write** from currently known information. Fill what is clear; mark what is not as `[UNDERSPECIFIED]`. Write the file to disk immediately.</loop_step>
          <loop_step index="2">**Ask** only the questions needed to resolve critical gaps in this document. Use the `AskUserQuestion` tool to present them if possible. Keep it focused — one or two questions at most per round. Anything that can be deferred without breaking consistency, defer.</loop_step>
          <loop_step index="3">**Revise and update** the file on disk based on the user's answers.</loop_step>
          <loop_step index="4">**Repeat** steps 2-3 until the document is consistent with what the user has confirmed and all remaining gaps are explicitly marked or solved.</loop_step>
          <loop_step index="5">Move to the next document when user is satisfied or all gaps are closed.</loop_step>
        </per_document_loop>

        <loop_rules>
          <rule>Never guess. If something is unclear and the user has not answered, mark it `[UNDERSPECIFIED]`.</rule>
          <rule>Never block on a gap that can be deferred. The document can be useful and consistent without being complete.</rule>
          <rule>When the user answers a question that affects an already-written document, go back and update it before continuing.</rule>
          <rule>When multiple questions are needed at once, use the `AskUserQuestion` tool — it presents them as a structured form rather than a wall of text and is easier for the user to respond to.</rule>
          <rule>Ask as few questions as possible. Only ask what is needed to make the document consistent and non-contradictory. Do not over-engineer, nitpick wording, or surface edge cases that are not relevant to the current stage of the project.</rule>
        </loop_rules>

        <document_specific_guidance>
          <document name="`specs/intent.md`">Read [spec_intent.md](spec_intent.md) for full rules. Six sections: Core Purpose, Architectural Commitments, Domain Boundaries, Key Invariants, Integration Contract Surface, Intentional Constraints. Every item must be falsifiable. No implementation details. 15-25 items total; fewer if the project is genuinely simple.</document>
          <document name="`specs/security.md`">Security constraints aligned to the stack and threat model. Cover authentication model, data classification, trust boundaries, secrets management. Outcome-focused: what must hold, not how to implement it.</document>
          <document name="`specs/testing.md`">Testing strategy aligned to the stack. Cover test levels and purpose, framework choices, coverage policy, CI requirements, and what constitutes a passing build.</document>
          <document name="`specs/architecture.md`">Index file. One-paragraph project summary linking to `specs/intent.md`, global constraints section linking to the other guardrail documents, explicit out-of-scope section, staged specs section, future features list. Follow [single_stage_structure.md](single_stage_structure.md).</document>
          <document name="`specs/features.md`">Only create this file if the project has existing code. Read the code to discover observable behavior and document it in behavior-first form (runtime outcomes, not internals). Do not transcribe implementation details. If the project is greenfield, omit this file entirely — it will be created when the first stage is implemented.</document>
          <document name="Initial stage specs (optional)">Only if scope is clear enough. Draft following [single_stage_structure.md](single_stage_structure.md). Do not force it — if scope is still uncertain, stop at architecture.md and let the user drive stage planning through the normal refinement workflow.</document>
        </document_specific_guidance>
      </step>

      <step id="3" name="Validation pass">
        <rule>After all documents are written, check cross-document consistency:</rule>
        <check index="1">Every item in `intent.md` is falsifiable and contains no implementation details.</check>
        <check index="2">`security.md` and `testing.md` do not contradict any intent item.</check>
        <check index="3">`architecture.md` links to all guardrail documents and its out-of-scope section aligns with `intent.md` domain boundaries.</check>
        <check index="4">`features.md` documents only actually implemented behavior — nothing planned.</check>
        <check index="5">If initial stage specs were created, they reference only prior stages (no forward dependencies) and do not contradict any guardrail document.</check>
      </step>
    </decision_rules>
  </policy>

  <output_contract>
    <response_shape>
      <rule>Report inconsistencies to the user and propose fixes.</rule>
      <rule>When everything is consistent, suggest the user commits the created files.</rule>
    </response_shape>
  </output_contract>
</task_block>
