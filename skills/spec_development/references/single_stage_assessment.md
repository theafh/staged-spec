# Single Stage Assessment

Assess one or more stage spec files for implementation readiness. This guide defines the review procedure and output format — not requirements for the specs themselves. Assess spec content and format against the quality criteria in [single_stage_structure.md](single_stage_structure.md). For assessing the spec framework as a whole, use [framework_assessment.md](framework_assessment.md).

Apply concise, positive, action-oriented writing throughout the review.

Goal:
Surface issues that affect correct, complete implementation by a one-shot AI coding agent that receives the spec as its sole input and produces a full implementation in a single pass. Every issue must be evaluated against that bar.

Evaluation focus:

Read the spec thoroughly and surface any issue that could affect a correct, complete implementation — not limited to format or structure. This includes but is not limited to:

- internal contradictions, including behavioral contradictions where one part of the spec makes another part non-functional
- missing or ambiguous requirements that can lead to divergent implementations
- missing ownership or contract details required for correct implementation
- stage or dependency inconsistencies across linked specs
- scope fit against the broader spec set: aspects that duplicate or conflict with what an existing future spec already owns, or that sit outside the current stage's stated boundary
- later-stage leakage: any behavior, requirement, or dependency that belongs to a stage after the current one must not appear in the spec's implementation sections — it belongs in the **Out of scope** section with a note pointing to the later stage file. References or links to later stages inside implementation sections are a direct signal that the spec is not implementation-ready: the spec must be fully implementable without anything from later stages
- false underspecification: requirements that appear missing in the current spec but are already established by an earlier stage — flag these only when the dependency link is missing, not when the behavior itself is covered
- logical gaps where specified behavior, commands, scripts, or workflows would fail under the spec's own stated constraints or preconditions
- unstated assumptions that an implementer would need to guess at
- over-specification: constraints that narrow intentional implementation flexibility without adding correctness value, causing an AI agent to implement a specific design when the spec deliberately left room for implementation choice

Output format (use exactly this structure):

```markdown
# General assessment
Write one short paragraph stating whether the spec is implementation-ready and why.

## Issues
If no issues exist, output exactly:
No issues found.

Otherwise, list all issues as a single ordered list. Order by how likely each issue is to cause a wrong or divergent result in a one-shot, fully AI-driven implementation of the spec — most problematic first. Use the evaluation criteria (ambiguity, contradiction, under-specification, over-specification, scope fit, missing ownership, dependency gaps, logical gaps, unstated assumptions) as the lens for ranking.

1. **[short title]** — one paragraph: what is wrong, implementation impact, and the minimum clarification or fix needed.
2. **[short title]** — same structure.
(continue as needed)
```

Inclusion rule:
Include every identified issue regardless of size. Even minor clarity improvements belong at the bottom of the list.
