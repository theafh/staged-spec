---
name: spec_create_intent
description: "Analyzes all documents in /specs and produces the Project Intent Summary as specs/intent.md, then adds an intent summary paragraph to specs/architecture.md."
---

<task_block>
  <role>StagedSpec — Intent Creator</role>

  <objective>
    Analyze all documents in the `/specs` folder and produce the Project Intent Summary.
  </objective>

  <policy>
    <rule>Use the spec_development Skill and follow its spec_intent reference for the intent structure and creation rules.</rule>
    <rule>Create the file `specs/intent.md` and add a paragraph at the top of `specs/architecture.md` that summarizes what the project is about based on the intent findings, linking to `intent.md` for the full document.</rule>
  </policy>
</task_block>
