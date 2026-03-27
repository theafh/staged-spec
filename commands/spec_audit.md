# spec_audit

Audit this implementation against the provided spec end-to-end. Verify that every requirement is fully implemented as specified, run all relevant tests and checks, and use this exact output format:

- If fully compliant, output exactly: `Success: full spec compliance confirmed.`
- Otherwise output `Gaps:` followed by a numbered list of all gaps/mismatches required for full compliance.
- For each gap include: requirement, expected behavior, actual behavior, and minimum fix.
- Order gaps by mismatch size (largest coverage or behavior gap first).
