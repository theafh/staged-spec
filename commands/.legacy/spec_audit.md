# spec_audit

Audit only specs marked as `✓ Implemented` in `specs/architecture.md`. Skip all other specs — drafts, in-progress, and future stages are out of scope for auditing. For each implemented spec, verify the implementation end-to-end. Treat tests and verifications as first-class deliverables — audit them with the same rigor as feature code.

## Workflow

1. **Read the spec thoroughly** — understand desired behavior, implementation steps, dependencies, scope boundary, and the "Tests and verification" section.
2. **Understand the existing codebase** — read the implemented code and existing tests to establish what is actually in place.
3. **Verify feature implementation** — walk through each item in "Desired behavior" and "Implementation steps" and confirm the code covers it.
4. **Verify tests and verification** — confirm every item in "Tests and verification" has a corresponding, passing test. Missing or incomplete tests count as gaps.
5. **Run all tests** — execute the full test suite. Record any failures or warnings.

## Output format

- If fully compliant, output exactly: `Success: full spec compliance confirmed.`
- Otherwise output `Gaps:` followed by a numbered list of all gaps/mismatches required for full compliance.
- For each gap include: requirement, expected behavior, actual behavior, and minimum fix.
- Order gaps by mismatch size (largest coverage or behavior gap first).
