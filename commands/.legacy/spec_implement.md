# spec_implement

Implement this spec completely end-to-end, including all tests and verifications

## Workflow

1. **Read the spec thoroughly** — understand desired behavior, implementation steps, dependencies, and scope boundary before writing code.
2. **Read the guardrail documents** — load `specs/security.md` and `specs/testing.md` and extract the constraints that apply to this stage (security requirements, trust boundaries, secrets handling, test levels, framework choices, coverage policy, CI expectations). Hold these as project-wide defaults that shape every implementation and test decision below.
3. **Understand the existing codebase** — read the code that is already implemented, including existing tests. This is your foundation: understand the patterns, conventions, and architecture in use so you extend them consistently rather than building in isolation.
4. **Implement the code** — follow the implementation steps in order, building on top of what already exists. Respect the scope boundary: implement everything inside scope, skip everything outside it. Apply the security constraints loaded from `specs/security.md` to every code path touched by this stage.
5. **Implement tests and verification** — map each verification topic in the spec's "Tests and verification" section to one test function. The behavioral checks listed under each topic are the assertions that test must contain. Treat every listed topic as a required deliverable. Align test level, framework choice, and structure with `specs/testing.md` so new tests match the project's established testing strategy.
6. **Cross-check against the spec** — walk through each item in "Desired behavior" and each verification topic in "Tests and verification" and confirm the implementation covers it. Resolve any gap before proceeding.
7. **Run all tests** — execute the full test suite (existing tests plus new ones). Fix failures until the suite passes cleanly with no errors or warnings.
8. **Update documentation** — record newly implemented behavior in `specs/features.md` in behavior-first form, and synchronize status in `specs/architecture.md` and the stage file.
