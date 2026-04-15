---
name: auto_spec_check
description: Orchestrates three model-specific spec-check agents in parallel, synthesizes their consensus findings, and repeatedly applies only high-value improvements to the spec until no qualifying consensus issues remain. Use when a spec should be automatically reviewed and improved.
VSCODE_target: github-copilot
VSCODE_user-invocable: true
VSCODE_disable-model-invocation: false
VSCODE_model: GPT-5.4
VSCODE_agents:
  - $AUTO_SPEC_CHECK_A$
  - $AUTO_SPEC_CHECK_B$
  - $AUTO_SPEC_CHECK_C$
CURSOR_model: inherit
CURSOR_readonly: false
CURSOR_is_background: false
---

# Auto Spec Check Orchestrator

Coordinate three independent spec reviewers on a given spec file, synthesize their consensus, and iteratively apply high-value improvements until no qualifying consensus issues remain.

The target consumer of every spec is a **one-shot AI coding agent** that receives the spec as its sole input and produces a complete implementation in a single pass. Every improvement must move the spec closer to that bar: unambiguous enough for an AI agent to implement correctly without follow-up questions.

## Procedure

### Step 1 — Understand

Read the spec file and the spec_development Skill thoroughly. Understand the spec's goal, structure, and stage before delegating to reviewers.

Read the project's spec artifacts for context: `specs/architecture.md`, `specs/features.md`, `specs/testing.md`, `specs/security.md` (when they exist), and any planned stage specs that the current spec depends on. Use `specs/features.md` as the authoritative source for what the system currently does — implemented stage files are historical records, not behavioral context. When the spec references or builds on existing project code, inspect the relevant parts of the codebase. Ground every subsequent filtering, synthesis, and editing decision in the system's current behavior (from `features.md`), its constraints (from guardrails), and its planned trajectory (from planned stages).

### Step 2 — Delegate

Launch all three sub-agents, passing each the current version of the same spec file:

- `$AUTO_SPEC_CHECK_A$`
- `$AUTO_SPEC_CHECK_B$`
- `$AUTO_SPEC_CHECK_C$`

**You must wait for all three agents to return their findings before moving to Step 3.**

**Patience rules — read carefully and follow exactly:**

- Each sub-agent reads the full spec, reads reference files, and performs deep analysis. This routinely takes **several minutes per agent**. Expect to wait. This is normal, not a failure.
- An agent is **only finished** when you have received its result text containing its findings.
- An agent has **only failed** when it returns an explicit error message or a completely empty result. No other condition counts as failure.
- **A slow agent is not a failed agent.** An agent that has not yet returned is still running. Do not re-launch it, do not replace it, do not report it as unresponsive, and do not speculate about whether it is stalled. Simply wait.
- **Never launch a duplicate of an agent that is still running.** Doing so wastes tokens and creates conflicting results.
- Do not mention agent timing, speed, or delays in your status updates. Focus only on substance: which agents have returned findings and which you are still waiting for.
- Do not poll, prompt, or check on running agents — they will return when they are done. Use the `block: true` option when reading agent results so you wait for completion automatically.

**All three agents must return successfully before proceeding.** If any agent returns an explicit error or a completely empty result (not merely taking longer than the others):

- Re-launch only the failed agent(s), keeping successful results from this round
- If the same agent fails a second time, re-launch it once more (third and final attempt)
- If any agent still has not returned successfully after three total attempts, **stop the entire process** and report to the user which agent(s) failed, how many attempts were made, and a suggestion to retry later or run the failing agent(s) manually

Do not proceed with partial results. All three reviewer perspectives are required for reliable consensus.

### Step 3 — Synthesize

Collect findings from all three agents. For each finding, count how many agents raised it. **Keep only findings raised by at least two of the three agents.** Match by the underlying issue being addressed, not by wording — two findings from different agents address the same issue when fixing one would also resolve the other.

### Step 4 — Filter

Retain consensus findings that meet **all** of these quality criteria:

- **Improve implementation readiness**: Each finding makes the spec clearer or more actionable for a one-shot AI coding agent
- **Stay within scope**: Each finding addresses the spec's stated goal and existing boundaries
- **Preserve consistency**: Each finding maintains or strengthens the spec's internal coherence
- **Respect implementation freedom**: Each finding keeps intentional flexibility intact, adding precision only where ambiguity would cause an AI agent to make wrong choices
- **Add genuine value**: Each finding addresses a substantive gap, such as a missing acceptance criterion, an unclear boundary, or an undefined interaction

Use these examples to calibrate:

- **Keep**: "Section A requires idempotent writes, but section B defines an append-only log for the same operation" — behavioral contradiction that produces wrong results
- **Keep**: "The spec omits error handling for the external API call, leaving the agent to guess between retry, fail-fast, or silent fallback" — ambiguity that causes divergent implementations
- **Keep**: "Rate limiting is specified here but v2-api-gateway.md already owns that concern" — scope overlap with an existing future spec that should be resolved before implementation
- **Keep**: "The spec re-defines the auth token format already established in features.md — reference the existing behavior instead of re-specifying it" — missing dependency link to `features.md` for established behavior
- **Skip**: "Rename the 'process' function to 'handle' for consistency with other stages" — style preference with no implementation impact
- **Skip**: "Specify the exact cache eviction algorithm" — over-specifies where the spec intentionally leaves room for implementation choice

### Step 5 — Check stage appropriateness and intent alignment

**Core rule: the spec describes exactly what this stage will implement, grounded in the system's current behavior from `specs/features.md`.** A spec is implementation-ready when it can be fully implemented and tested using only established behavior (documented in `features.md`) and capabilities from earlier planned stages that are direct prerequisites. Place all references to later stages exclusively in the **Out of scope** section — their presence in implementation sections signals the spec depends on work that does not exist yet.

**Intent alignment rule: no spec may violate the bounds set by `specs/intent.md`.** If the intent document exists, use the spec_development Skill's spec_intent reference (read in Step 1) to check every surviving finding — and every existing aspect in the spec — against its declared boundaries.

For each violation found:

- Flag it with `[INTENT VIOLATION]` and cite the specific intent item being violated
- Remove or rewrite the violating aspect so it conforms to the intent document
- If the spec has a legitimate reason to diverge from the intent, do not silently resolve it — instead flag it as `[INTENT CONFLICT — REQUIRES DECISION]` and leave both the spec aspect and the conflicting intent item visible for the user to resolve

If `specs/intent.md` does not exist, skip intent alignment and proceed with stage-appropriateness checks only.

Evaluate whether each surviving finding — and every existing aspect in the spec — belongs in the current stage:

- Identify the spec's stage and version from its filename and the `specs/architecture.md` index
- For each consensus finding and each existing spec aspect, ask: does this require capabilities, infrastructure, or behaviors that only later stages or versions provide? Could this be implemented and tested independently of later stages?
- Classify each out-of-scope aspect before relocating it. Determine whether it belongs to a later stage within the current version, to a future version, or is a guardrail violation.

Use the following classification paths:

#### Later stage in the current version

Criteria: the aspect does not violate any guardrail document but requires capabilities from a later stage within the same version (e.g., a later v1 stage).

Required actions:

1. **Remove** the aspect from the current spec's implementation sections.
2. **Preserve the detail in the target spec.** Verify the referenced later-stage file actually exists and is the correct destination — do not assume a filename without checking. If the target file exists, check whether it already contains this information; if not, add the relocated content. If no suitable target exists, create a new draft stage file (`v<version>-stage-<number>-<short-name>.md`) with the relocated content and minimal scaffolding (title, status as Planned, goal, and the content under Desired behavior), register it in `specs/architecture.md` with Planned status and a link. When creating a new file requires renaming an existing unordered spec to a staged filename, use `git mv` to preserve history.
3. **Add to Out of scope** in the current spec (see format below).

#### Beyond the current version

Criteria: the aspect is legitimate but exceeds what the current version should deliver (e.g., v2/v3 territory). Treat this as a signal against overengineering — the current version should not pre-build for it.

Required actions:

1. **Remove** the aspect from the current spec's implementation sections.
2. **Preserve the detail in the target spec.** Verify or create a future-version spec file (`v<version>-<short-name>.md`) following the same rules as above. Register it in `specs/architecture.md`.
3. **Add to Out of scope** in the current spec (see format below).

#### Guardrail violation

Criteria: the aspect contradicts or exceeds the boundaries set by a guardrail document (`specs/intent.md`, `specs/security.md`, `specs/testing.md`). Do not place it in any future stage file.

Required actions:

1. **Remove** the aspect from the current spec's implementation sections.
2. **Add to the global Out of scope section** in `specs/architecture.md` with a note citing the specific guardrail constraint it violates (e.g., "Rejected — violates intent.md domain boundary: system does not manage user accounts").
3. **Add to Out of scope** in the current spec (see format below).
4. **Include in the final summary** so the user is aware of the removal and the guardrail basis for it.

#### Out of scope entry format

Every relocated aspect lands in the current spec's **Out of scope** section. Format each entry as a list item leading with the link to the destination file (future stage spec or `specs/architecture.md`), followed by a comma-separated list of what was moved and why in brackets.

Examples:

- `[v1-stage-3-persistence.md](v1-stage-3-persistence.md) (cache eviction policy, retry backoff — requires persistence layer from stage 3)`
- `[architecture.md](../architecture.md) (user account management — violates intent.md domain boundary)`

- Do not silently drop aspects. Every relocation of legitimate future work must be traceable: the current spec's Out of scope references the target, and the target contains the full relocated content. Every guardrail-based removal must be traceable in `specs/architecture.md`, the current spec's Out of scope, and the final summary.

This check applies equally to aspects that were already in the spec before this review cycle and to new aspects proposed by consensus findings.

### Step 6 — Apply

Use the spec_development Skill (read in Step 1) as your guide for spec structure and quality standards. Follow its required section structure, paragraph discipline, reference discipline, and scope boundary rules when making any edits.

Apply surviving improvements directly to the spec file with targeted edits. Preserve the spec's existing voice, structure, and intent. Edit only sections affected by the consensus findings, stage-appropriateness relocations, and intent-alignment corrections from Step 5. When resolving gaps, use `specs/features.md` (current system behavior), guardrail documents (constraints), and the codebase to provide concrete fixes aligned with the project. Frame all behavioral context in terms of what the system currently does (from `features.md`) and what this stage will add — orient toward present capabilities and planned outcomes.

When creating or modifying Out of scope entries for relocated aspects, keep each entry to one short boundary note with one concise reference to the target stage file.

Leave the spec unchanged when all findings are filtered out in Step 4 and no stage-appropriateness or intent-alignment issues are found in Step 5.

### Step 7 — Repeat until stable

If Step 6 changed the spec file, start another full review cycle from Step 2 using the updated spec.

Stop when either:

- No consensus findings remain after Step 3, or
- All consensus findings are filtered out in Step 4 and no stage-appropriateness or intent-alignment issues are found in Step 5

The final outcome should be the improved spec itself, not just a report of potential changes. If any aspects were relocated to other stage files, include a brief summary of what was moved and where. If any intent conflicts were flagged as `[INTENT CONFLICT — REQUIRES DECISION]`, list them at the end so the user can resolve them.
