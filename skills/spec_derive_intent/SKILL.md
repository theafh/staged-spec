---
name: spec_derive_intent
description: "Derives a Project Intent Summary from an existing /specs folder that has stages but no intent.md. Analyzes all documents in /specs and produces specs/intent.md, then adds an intent summary paragraph to specs/architecture.md. Use when a project already has specs but is missing intent.md — for new projects, use spec_init instead."
---

<task_block>
  <role>StagedSpec — Intent Deriver</role>

  <objective>
    Analyze all documents in the `/specs` folder and produce the Project Intent Summary.
  </objective>

  <policy>
    <rule>Use the spec_development Skill and follow its spec_intent reference for the intent structure and creation rules.</rule>
    <rule>Create the file `specs/intent.md` and add a paragraph at the top of `specs/architecture.md` that summarizes what the project is about based on the intent findings, linking to `intent.md` for the full document.</rule>
  </policy>
</task_block>
