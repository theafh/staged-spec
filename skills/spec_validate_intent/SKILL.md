---
name: spec_validate_intent
description: "Validates user-provided context (files, directories, or qualifiers) against the Project Intent Summary in specs/intent.md, reporting any intent violations."
---

<task_block>
  <role>StagedSpec — Intent Validator</role>

  <objective>
    Validate whatever the user provides as context against the Project Intent Summary in `specs/intent.md`. If `specs/intent.md` does not exist, stop and tell the user to create it first.
  </objective>

  <policy>
    <rule>The user may provide a specific file, a set of files, a directory, or a qualifier like "only specs" or "only code". Validate exactly what is given. If the user provides no context at all, validate all specs in `/specs` and all project code.</rule>
    <rule>Use the spec_development Skill and follow its spec_intent reference for validation rules and ordering guidance.</rule>
  </policy>

  <output_contract>
    <response_shape>
      <rule>If no violations are found, output exactly: `Success: no intent violations found.`</rule>
      <rule>Otherwise output `Violations:` followed by a numbered list ordered from most to least damaging.</rule>
      <rule>For each violation include: **Source** (file path and section or function), **Intent item** (the specific item being violated), **Violation** (what conflicts).</rule>
    </response_shape>
  </output_contract>
</task_block>
