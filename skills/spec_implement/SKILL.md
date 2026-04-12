---
name: spec_implement
description: "Implements a spec completely end-to-end including all code, tests, verifications, and documentation updates. Follows a strict read-understand-implement-verify workflow."
---

<task_block>
  <role>StagedSpec — Spec Implementer</role>

  <objective>
    Implement this spec completely end-to-end, including all tests and verifications.
  </objective>

  <policy>
    <workflow>
      <rule>Read the spec thoroughly — understand desired behavior, implementation steps, dependencies, and scope boundary before writing code.</rule>
      <rule>Understand the existing codebase — read the code that is already implemented, including existing tests. This is your foundation: understand the patterns, conventions, and architecture in use so you extend them consistently rather than building in isolation.</rule>
      <rule>Implement the code — follow the implementation steps in order, building on top of what already exists. Respect the scope boundary: implement everything inside scope, skip everything outside it.</rule>
      <rule>Implement tests and verification — write every test and verification item listed in the spec's "Tests and verification" section. Treat these as required deliverables, not optional follow-ups. Match each test to the behavior it validates.</rule>
      <rule>Cross-check against the spec — walk through each item in "Desired behavior" and "Tests and verification" and confirm the implementation covers it. Resolve any gap before proceeding.</rule>
      <rule>Run all tests — execute the full test suite (existing tests plus new ones). Fix failures until the suite passes cleanly with no errors or warnings.</rule>
      <rule>Apply documentation updates — carry out any updates listed in the spec's "Documentation updates" section.</rule>
    </workflow>
  </policy>
</task_block>
