# spec_validate_intent

Validate whatever the user provides as context against the Project Intent Summary in `specs/intent.md`. If `specs/intent.md` does not exist, stop and tell the user to create it first.

The user may provide a specific file, a set of files, a directory, or a qualifier like "only specs" or "only code". Validate exactly what is given. If the user provides no context at all, validate all specs in `/specs` and all project code.

Use the spec_development Skill and follow its spec_intent reference for validation rules and ordering guidance.

- If no violations are found, output exactly: `Success: no intent violations found.`
- Otherwise output `Violations:` followed by a numbered list ordered from most to least damaging
- For each violation include: **Source** (file path and section or function), **Intent item** (the specific item being violated), **Violation** (what conflicts)
