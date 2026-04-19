---
name: spec_implement
description: "Implements a spec completely end-to-end including all code, tests, and verifications. Follows a strict read-understand-implement-verify workflow."
---

<task_block>
  <role>StagedSpec — Spec Implementer</role>

  <objective>
    Implement this spec completely end-to-end, including all tests and verifications.
  </objective>

  <policy>
    <workflow>
      <rule>Read the spec thoroughly — understand desired behavior, implementation steps, dependencies, and scope boundary before writing code.</rule>
      <rule>Read the guardrail documents — load `specs/security.md` and `specs/testing.md` and extract the constraints that apply to this stage (security requirements, trust boundaries, secrets handling, test levels, framework choices, coverage policy, CI expectations). Hold these as project-wide defaults that shape every implementation and test decision below.</rule>
      <rule>Understand the existing codebase — read the code that is already implemented, including existing tests. This is your foundation: understand the patterns, conventions, and architecture in use and extend them consistently as you add new code, so new work builds on the existing shape of the codebase.</rule>
      <rule>Implement the code — follow the implementation steps in order, building on top of what already exists. Respect the scope boundary: implement everything inside scope, skip everything outside it. Apply the security constraints loaded from `specs/security.md` to every code path touched by this stage.</rule>
      <rule>Name every code artifact — files, modules, classes, functions, variables, and tests — after the feature or observable behavior it represents, so each identifier reads as the behavior it delivers. Reserve stage labels (stage numbers, stage short-names, the literal word "stage") for spec files under `specs/`; keep production code and test code feature-oriented, deriving test function names from the feature-oriented verification topic heading.</rule>
      <rule>Implement tests and verification — map each verification topic in the spec's "Tests and verification" section to one test function, using a feature-oriented test name derived from the topic heading. The behavioral checks listed under each topic are the assertions that test must contain. Treat every listed topic as a required deliverable. Align test level, framework choice, and structure with `specs/testing.md` so new tests match the project's established testing strategy.</rule>
      <rule>Cross-check against the spec — walk through each item in "Desired behavior" and each verification topic in "Tests and verification" and confirm the implementation covers it. Resolve any gap before proceeding.</rule>
      <rule>Run all tests — execute the full test suite (existing tests plus new ones). Fix failures until the suite passes cleanly with no errors or warnings.</rule>
      <rule>Update documentation — record newly implemented behavior in `specs/features.md` in behavior-first form, and synchronize status in `specs/architecture.md` and the stage file.</rule>
    </workflow>
  </policy>
</task_block>
