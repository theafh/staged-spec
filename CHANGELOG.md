# CHANGELOG — StagedSpec

Status markers: `[active]` (present in current code), `[changed later]` (still present but evolved), `[superseded]` (replaced or removed).
Entries are grouped strictly by day and kept on their original implementation dates.

## 2026-05-02 — Make shortcuts and VS Code backup naming

- [active] **Implementation/runtime:** Added a top-level `Makefile` exposing `make deploy` (with `install` and `global` aliases) and `make uninstall` as wrappers around `./scripts/deployment.sh --global` and `--uninstall`, and documented the shortcut mappings in `scripts/README.md` and the main README.
- [active] **Implementation/runtime:** Taught `scripts/deployment.sh` to accept per-target backup-name overrides (carried through `is_managed_backup_path`, `clear_old_backups_for_app_dir`, and `backup_app_dir`), and applied the override `.vscode-prompts` for VS Code's macOS user-prompts directory so the backup is no longer named `~/prompts_<timestamp>` and stays visually tied to VS Code.

- **Files changed:** `Makefile`, `README.md`, `scripts/README.md`, `scripts/deployment.sh`

---

## 2026-04-24 — Location-independent repo root discovery

- [active] **Implementation/runtime:** Replaced the hard-coded `SCRIPT_DIR/..` repo-root assumption in `scripts/deployment.sh` with an ancestor walk that climbs from the script's directory until it finds a folder containing one of the known artifact folders (`agents`, `commands`, `skills`, `hooks`), erroring out with a clear message if no ancestor matches — so the script works regardless of how deeply nested it is in the repo.

- **Files changed:** `scripts/deployment.sh`

---

## 2026-04-22 — Explicit `--global` deployment mode

- [active] **Implementation/runtime:** Required explicit `--global` mode in `scripts/deployment.sh` for deploying to global config directories — running the script without arguments now prints usage and examples instead of silently deploying everywhere — and added a `--global`/`--project-dir` mutual-exclusion guard plus a "Global mode: enabled" indicator in the deployment summary.
- [active] **Docs/specs-only:** Aligned every deployment example across `AGENTS.md`, `CLAUDE.md`, `README.md`, and `scripts/README.md` with the new CLI behavior (added `--global` to global examples, corrected `--type hooks` to `--type hook`, fixed `--target claude-code` to `--target claude`).

- **Files changed:** `AGENTS.md`, `CLAUDE.md`, `README.md`, `scripts/README.md`, `scripts/deployment.sh`

---

## 2026-04-19 — One-shot quality bar and refinement reference

- [active] **Docs/specs-only:** Defined the one-shot implementation-readiness quality bar in the README, removed the optional "Read first" section from the required stage structure across `METHODOLOGY.md` and the single-stage assessment reference, and clarified that intent changes require explicit human authority and that underspecification must be raised rather than silently filled.
- [active] **Refactor:** Split single-stage refinement out of the structure reference into a dedicated `single_stage_refinement.md` reference covering the refinement workflow and a full content-move menu, and routed refinement traffic from the `spec_development` skill to it while strengthening dependency, out-of-scope, and cross-reference discipline in the structure reference.
- [active] **Docs/specs-only:** Added bidirectional Out-of-scope audit, implemented-stage leakage detection, and mixed-tier ordering criteria to the framework and single-stage assessment references; updated `auto_spec_check` and `auto_shape_specs` to apply them and treat implemented stages as immutable consistency anchors.
- [active] **Implementation/runtime:** Made `spec_implement` (and the archived legacy command) load guardrails before implementation, added a feature-oriented naming rule, and refined `spec_init` to extract outcome-level guardrail intent from existing code rather than restating it.
- [active] **Docs/specs-only:** Updated `agents/README.md` to explain the cost rationale for the reviewer triplet and the standalone execution model of `auto_shape_specs`.

- **Files changed:** `METHODOLOGY.md`, `README.md`, `agents/README.md`, `agents/auto_shape_specs.md`, `agents/auto_spec_check.md`, `commands/.legacy/spec_implement.md`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/framework_assessment.md`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_refinement.md`, `skills/spec_development/references/single_stage_structure.md`, `skills/spec_development/references/spec_intent.md`, `skills/spec_implement/SKILL.md`, `skills/spec_init/SKILL.md`

---

## 2026-04-16 — Verification topics and structural compliance

- [active] **Docs/specs-only:** Removed the "Documentation updates" section from the required stage structure across AGENTS.md, CLAUDE.md, METHODOLOGY.md, and the single-stage-structure reference, replacing it with behavior-first documentation that records implemented behavior in `specs/features.md` and synchronizes status in `architecture.md` and the stage file.
- [active] **Docs/specs-only:** Reframed "Tests and verification" as a list of verification topics — each top-level item is a descriptive heading grouping ~2–3 related behavioral checks that map to a single test function — and added structural-compliance checks to the single-stage and framework assessment references that flag flat per-check lists, missing required sections, and extra sections outside the exhaustive set.
- [active] **Implementation/runtime:** Aligned the `spec_audit` and `spec_implement` skills (and their archived legacy commands) with the verification-topic mapping: implementers map each topic to one test function whose assertions are the behavioral checks under the topic, and audit confirms each topic has a corresponding passing test rather than per-item tests.

- **Files changed:** `AGENTS.md`, `CLAUDE.md`, `METHODOLOGY.md`, `commands/.legacy/spec_audit.md`, `commands/.legacy/spec_implement.md`, `skills/spec_audit/SKILL.md`, `skills/spec_development/references/framework_assessment.md`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_structure.md`, `skills/spec_implement/SKILL.md`

---

## 2026-04-15 — `spec_derive_intent` rename and `features.md` authority

- [changed later] **Refactor:** Renamed the intent-creation skill from `spec_create_intent` to `spec_derive_intent` and clarified its scope (it derives intent for existing specs while `spec_init` handles new projects); updated AGENTS, CLAUDE, README, and the legacy command file to match.
- [changed later] **Implementation/runtime:** Made `scripts/deployment.sh` exclude `README` files during artifact discovery and documented the hidden-folder/README exclusion rule in the deployment script.
- [changed later] **Docs/specs-only:** Established `specs/features.md` as the authoritative implemented-behavior source across the StagedSpec context hierarchy: updated `auto_spec_check` to ground reviews in features.md-anchored behavior, made `auto_shape_specs` prioritize features.md and treat implemented stages as historical consistency records, and aligned the `spec_development` skill plus its framework-assessment, single-stage-assessment, and single-stage-structure references on the new authority.
- [changed later] **Implementation/runtime:** Excluded `agents/check_spec_gemini.md` from claude-code, codex, gemini, and antigravity targets in `scripts/deployment.conf`.

- **Files changed:** `AGENTS.md`, `CLAUDE.md`, `README.md`, `agents/auto_shape_specs.md`, `agents/auto_spec_check.md`, `commands/.legacy/spec_derive_intent.md`, `scripts/deployment.conf`, `scripts/deployment.sh`, `skills/spec_derive_intent/SKILL.md`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/framework_assessment.md`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_structure.md`

---

## 2026-04-14 — Legacy archive, project-dir mode, init split

- [active] **Implementation/runtime:** Moved every legacy command into `commands/.legacy/` (renaming `*_legacy.md` back to plain names) so the dotfolder hides them from the deployment scanner, and updated AGENTS/CLAUDE/README to document the archive's non-deployment status.
- [changed later] **Implementation/runtime:** Added `--project-dir` deployment mode in `scripts/deployment.sh` with target handling, path mapping, and backup behavior, plus matching documentation in `scripts/README.md`.
- [changed later] **Refactor:** Split spec-initialization bootstrap into a standalone `spec_init` skill (branch gating, document creation order, validation rules), redirected the missing-security/testing bootstrap flow from `spec_development` to it, and removed the old in-reference bootstrap workflow from `framework_initialization.md`.
- [changed later] **Docs/specs-only:** Added `AGENTS.md` for Codex with meta-repo guidance, added `agents/README.md` documenting the agent matrix, committee reviewer mapping, and model-format restrictions per IDE, and rewrote CLAUDE.md to emphasize meta-repo boundaries and explicit reviewer triplets per IDE.
- [changed later] **Implementation/runtime:** Reordered `scripts/deployment.conf` so the active Cursor reviewer is `AUTO_SPEC_CHECK_A` while the Opus alternative stays commented, switched VS Code model fields on `check_spec_gemini` and `check_spec_opus` to picker display-name format, and made the hook-skip log explicitly state Codex hook deployment is not implemented.

- **Files changed:** `AGENTS.md`, `CLAUDE.md`, `README.md`, `agents/README.md`, `agents/check_spec_gemini.md`, `agents/check_spec_opus.md`, `commands/.legacy/assess_all_specs.md`, `commands/.legacy/spec_audit.md`, `commands/.legacy/spec_check.md`, `commands/.legacy/spec_create_intent.md`, `commands/.legacy/spec_feature_update.md`, `commands/.legacy/spec_implement.md`, `commands/.legacy/spec_validate_intent.md`, `scripts/README.md`, `scripts/deployment.conf`, `scripts/deployment.sh`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/framework_initialization.md`, `skills/spec_init/SKILL.md`

---

## 2026-04-13 — VS Code target and `deployment.conf` rename

- [changed later] **Implementation/runtime:** Added VS Code Copilot as a deployment target — VS Code-specific frontmatter (`VSCODE_target`, `VSCODE_user-invocable`, `VSCODE_model`, etc.) on every agent file, a VS Code deployment flow in `scripts/deployment.sh` with replacement-aware install logic, and updated `scripts/README.md` to document the new target and replacement behavior.
- [changed later] **Implementation/runtime:** Introduced placeholder reviewer-agent variables (`$AUTO_SPEC_CHECK_A$`, `$AUTO_SPEC_CHECK_B$`, `$AUTO_SPEC_CHECK_C$`) in `auto_spec_check.md` so the orchestrator's reviewer triplet can vary per IDE rather than hard-coding Composer/Codex/Opus.
- [changed later] **Refactor:** Renamed `scripts/target_conf.txt` to `scripts/deployment.conf` and updated `CLAUDE.md` and `README.md` to reference the new filename and describe its rule semantics.
- [active] **Refactor:** Added `/docs` to `.gitignore` so generated documentation output stays out of version control.

- **Files changed:** `.gitignore`, `CLAUDE.md`, `README.md`, `agents/auto_shape_specs.md`, `agents/auto_spec_check.md`, `agents/check_spec_codex.md`, `agents/check_spec_gemini.md`, `agents/check_spec_opus.md`, `scripts/README.md`, `scripts/deployment.conf`, `scripts/deployment.sh`, `scripts/target_conf.txt`

---

## 2026-04-12 — Skills as primary entry points

- [changed later] **Refactor:** Promoted skills to the primary workflow surface — added standalone `spec_audit`, `spec_check`, `spec_create_intent`, `spec_feature_update`, `spec_implement`, and `spec_validate_intent` skills with pseudo-XML `task_block` definitions, each delegating detailed guidance to the `spec_development` references.
- [superseded] **Refactor:** Renamed every `commands/spec_*.md` slash-command file to `*_legacy.md` to preserve backward compatibility while signaling the new direction, and added a `disallow:*legacy*` rule across every target in `scripts/target_conf.txt` so legacy commands are skipped during deployment.
- [changed later] **Implementation/runtime:** Added the Gemini reviewer agent `check_spec_gemini.md` running `gemini-3.1-pro` for the committee, alongside the existing Codex/Composer/Opus reviewers.
- [changed later] **Docs/specs-only:** Restructured the README to lead with skills as the cross-IDE workflow surface, demoted the `commands/` table to a legacy-compatibility note, and explained why slash-command support varies across vendors.

- **Files changed:** `README.md`, `agents/check_spec_gemini.md`, `commands/spec_audit_legacy.md`, `commands/spec_check_legacy.md`, `commands/spec_create_intent_legacy.md`, `commands/spec_feature_update_legacy.md`, `commands/spec_implement_legacy.md`, `commands/spec_validate_intent_legacy.md`, `scripts/target_conf.txt`, `skills/spec_audit/SKILL.md`, `skills/spec_check/SKILL.md`, `skills/spec_create_intent/SKILL.md`, `skills/spec_feature_update/SKILL.md`, `skills/spec_implement/SKILL.md`, `skills/spec_validate_intent/SKILL.md`

---

## 2026-04-11 — Stage scope sizing as a core principle

- [changed later] **Docs/specs-only:** Defined a stage scoping principle in `spec_development` and the stage-structure reference — each stage is the most compact scope that still delivers a meaningful, testable capability that a one-shot AI agent can implement in a single pass — with explicit split/merge guidance for stages that are too large or too small.
- [changed later] **Docs/specs-only:** Added matching scope-sizing checks to the single-stage and framework assessment references so reviews flag oversized stages that would need multiple passes and undersized stages that add coordination overhead without delivering a coherent capability.
- [changed later] **Implementation/runtime:** Made `auto_shape_specs` evaluate scope sizing for every planned stage during assessment, and required the fix loop to perform explicit split/merge file maintenance with `git mv`, dependency-order renumbering, and link-validity verification across `architecture.md` and other stage files.
- [changed later] **Implementation/runtime:** Pinned the Codex frontmatter for `auto_shape_specs` to `gpt-5.4` with `model_reasoning_effort: high`, and taught `scripts/deployment.sh` to preserve `model_reasoning_effort` when generating Codex TOML agent metadata.

- **Files changed:** `agents/auto_shape_specs.md`, `scripts/deployment.sh`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/framework_assessment.md`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_structure.md`

---

## 2026-04-09 — Planned-vs-implemented scope discipline

- [changed later] **Docs/specs-only:** Restricted framework-wide fixes in `auto_shape_specs` and assessments in `assess_all_specs` to planned stages only, treating implemented or in-progress stages as historical context that is read for cross-stage consistency checks but never edited.
- [superseded] **Implementation/runtime:** Defined a dedicated implemented-only audit workflow in `commands/spec_audit.md` (rigorous verification of tests and verifications against actual code) and a separate explicit end-to-end implementation workflow in `commands/spec_implement.md` requiring cross-checking, testing, and documentation updates.
- [changed later] **Refactor:** Normalized pseudo-XML structure across the framework-assessment, framework-initialization, single-stage-assessment, single-stage-structure, and spec-intent references — tightened outcome-focused framework criteria, added test-design-quality checks and verify-to-test design guidance, and clarified relocation handling.

- **Files changed:** `agents/auto_shape_specs.md`, `commands/assess_all_specs.md`, `commands/spec_audit.md`, `commands/spec_implement.md`, `skills/spec_development/references/framework_assessment.md`, `skills/spec_development/references/framework_initialization.md`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_structure.md`, `skills/spec_development/references/spec_intent.md`

---

## 2026-04-07 — CLAUDE guidance and Out-of-scope grouping

- [changed later] **Docs/specs-only:** Added `CLAUDE.md` documenting that this repo builds the StagedSpec tooling rather than using it on itself, plus repository structure, key target-project concepts, architecture patterns, prompt-editing rules, and deployment commands.
- [changed later] **Docs/specs-only:** Tightened the stage-structure and single-stage-assessment references so the **Out of scope** section is the only place forward-looking references may live, requires one bullet per destination with a single relative link followed by the deferred items, and demands relocated content be written into the target stage file rather than left as a pointer.
- [changed later] **Implementation/runtime:** Switched the Opus reviewer agent's `CURSOR_model` from `claude-opus-4-6` to `claude-4.6-opus-high-thinking`.
- [active] **Refactor:** Added `skills/.markdownlint.yaml` disabling all rules under `skills/` so pseudo-XML prompt files are not linted as standard markdown.

- **Files changed:** `CLAUDE.md`, `agents/check_spec_opus.md`, `skills/.markdownlint.yaml`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_structure.md`

---

## 2026-04-03 — Pseudo-XML restructure

- [changed later] **Refactor:** Restructured the `spec_development` skill plus its `framework_assessment`, `framework_initialization`, `single_stage_assessment`, `single_stage_structure`, and `spec_intent` references into pseudo-XML — `task_block`, `policy`, `output_contract`, and similar tags — so AI agents parse instruction boundaries explicitly and stop skipping detailed constraints.
- [changed later] **Docs/specs-only:** Added cross-stage and feature-file consistency validation to the single-stage assessment checks so reviews catch contradictions across the broader spec set rather than only within the spec being reviewed.
- [changed later] **Refactor/runtime reliability:** Made `protect-guardrails.sh` resolve the repo root from the absolute file path, then the hook's `cwd`, then the current working directory, before computing the active branch — fixing branch detection when hooks run from a working directory different from the repo root.
- [superseded] **Implementation/runtime:** Tightened `commands/spec_check.md` to use a single direct reviewer (the current agent) producing one assessment, distinguishing it from the multi-reviewer committee path.

- **Files changed:** `commands/spec_check.md`, `hooks/protect-guardrails.sh`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/framework_assessment.md`, `skills/spec_development/references/framework_initialization.md`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_structure.md`, `skills/spec_development/references/spec_intent.md`

---

## 2026-04-01 — Out-of-scope relocation classes

- [changed later] **Docs/specs-only:** Classified out-of-scope relocations in the `auto_spec_check` orchestrator into three paths — later stage in the current version, beyond the current version, and guardrail violation — each with required removal/preservation/Out-of-scope steps and a standard list-item format that links the destination file and brackets the moved items with their reason.
- [changed later] **Docs/specs-only:** Aligned the single-stage assessment reference with the same relocation classes, added an explicit guardrail-violations check, and required that relocated content always have a verified destination so nothing is silently dropped.
- [active] **Refactor:** Renamed the `spec_development` skill's frontmatter `name` from `spec-development` to `spec_development` to match the directory and reference style.

- **Files changed:** `agents/auto_spec_check.md`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/single_stage_assessment.md`

---

## 2026-03-31 — Stage vs framework assessment split

- [active] **Implementation/runtime:** Added the `auto_shape_specs` agent — a two-phase autonomous workflow that first produces a framework-wide assessment and then fixes every issue it found, treating implemented stages as historical records and skipping guardrail-document edits.
- [changed later] **Refactor:** Split the spec-development reference set along stage-vs-framework lines: renamed `spec_assessment.md` to `single_stage_assessment.md`, `spec_structure.md` to `single_stage_structure.md`, and `spec_initialization.md` to `framework_initialization.md`, then added `framework_assessment.md` defining framework-wide assessment dimensions, severity ordering, and the output contract; updated the `spec_development` skill, reviewer agents, and commands to route to the new references.
- [superseded] **Implementation/runtime:** Added the `commands/assess_open_specs.md` framework-wide assessment command that runs the framework assessment without applying fixes, then renamed it to `commands/assess_all_specs.md` for broader naming.
- [changed later] **Implementation/runtime:** Switched all agent frontmatter from generic keys to vendor-prefixed keys (`CURSOR_model`, `CLAUDE_model`, etc.) and added a deployment-time frontmatter rewriter in `scripts/deployment.sh` that strips the matching prefix for the active target and drops fields prefixed for other tools.
- [changed later] **Refactor/runtime reliability:** Switched the Cursor guardrail hook config to fail-open (`failClosed: false`) so a hook crash no longer blocks editing in the IDE.

- **Files changed:** `agents/auto_shape_specs.md`, `agents/auto_spec_check.md`, `agents/check_spec_codex.md`, `agents/check_spec_composer.md`, `agents/check_spec_opus.md`, `commands/assess_all_specs.md`, `commands/spec_check.md`, `commands/spec_feature_update.md`, `hooks/cursor-hooks.json`, `scripts/deployment.sh`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/framework_assessment.md`, `skills/spec_development/references/framework_initialization.md`, `skills/spec_development/references/single_stage_assessment.md`, `skills/spec_development/references/single_stage_structure.md`

---

## 2026-03-30 — Methodology split and bootstrap

- [changed later] **Docs/specs-only:** Split the README into a concise project overview and moved the full lifecycle, artifact, refinement-loop, and guardrail material into a new `METHODOLOGY.md` reference linked from the README.
- [changed later] **Docs/specs-only:** Added `scripts/README.md` documenting deployment targets, `target_conf.txt` syntax, the uninstall flow, and operational workflows (dry runs, per-target deploys, backup management).
- [superseded] **Docs/specs-only:** Added a new `spec_initialization` reference describing a spec-bootstrap routine — guardrail-branch prerequisite, per-document refinement loop — and routed initialization workflows to it from the `spec_development` skill.
- [changed later] **Docs/specs-only:** Tightened `spec_intent.md` to require interactive clarification of underspecified intent gaps and removed prior guidance that allowed skipping underspecified items.
- [changed later] **Refactor/runtime reliability:** Switched `protect-guardrails.sh` to detect the active branch via `git symbolic-ref` so the hook handles detached-HEAD checkouts safely.

- **Files changed:** `METHODOLOGY.md`, `README.md`, `hooks/protect-guardrails.sh`, `scripts/README.md`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/spec_initialization.md`, `skills/spec_development/references/spec_intent.md`

---

## 2026-03-28 — Guardrail hooks and JSON merge

- [active] **Implementation/runtime:** Added the guardrail-protection hook subsystem under `hooks/`: a shared `protect-guardrails.sh` script that blocks edits to `specs/intent.md`, `specs/security.md`, and `specs/testing.md` unless the active git branch name contains both `guardrail` and `spec`, plus per-tool config files for Claude Code (PreToolUse) and Cursor (preToolUse with `failClosed`).
- [changed later] **Implementation/runtime:** Extended `scripts/deployment.sh` with a `jq` prerequisite check, JSON key merge/strip helpers, and tool-specific hook deployment paths so Claude Code hooks merge into `~/.claude/settings.json` with absolute script paths while Cursor hooks copy to `hooks.json` and `hooks/`.
- [superseded] **Implementation/runtime:** Updated `scripts/target_conf.txt` to disallow `hooks/*` for Codex, Gemini, and Antigravity targets that do not support the hook system.
- [changed later] **Docs/specs-only:** Defined the guardrail-document concept in the `spec_development` skill — `intent.md`, `security.md`, and `testing.md` are project-wide guardrails that never change as a side-effect of stage work, and stage refinements that conflict with a guardrail must fix the stage rather than the guardrail.
- [changed later] **Docs/specs-only:** Expanded the README to document autonomous refinement, the committee agent, multi-tool deployment, and guardrail enforcement, raising the shared-files count from four to five.

- **Files changed:** `README.md`, `hooks/claude-code-hooks.json`, `hooks/cursor-hooks.json`, `hooks/protect-guardrails.sh`, `scripts/deployment.sh`, `scripts/target_conf.txt`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/spec_intent.md`, `skills/spec_development/references/spec_structure.md`

---

## 2026-03-27 — Initial methodology and tooling

- [changed later] **Implementation/runtime:** Bootstrapped the repository with the StagedSpec `README.md`, `LICENSE`, and `.gitignore` covering local skill artifacts, zip files, log files, and macOS metadata.
- [superseded] **Implementation/runtime:** Added the initial `/spec_*` slash command set (audit, check, create_intent, feature_update, implement, validate_intent), each defining its workflow contract and required output format.
- [changed later] **Implementation/runtime:** Added the `spec_development` skill with reference documents for stage structure and scope discipline, implementation-readiness assessment criteria, and project intent rules.
- [changed later] **Implementation/runtime:** Added the committee-of-reviewers agent layout — an `auto_spec_check` orchestrator running Codex, Composer, and Opus reviewer agents in parallel for consensus-based spec review.
- [changed later] **Implementation/runtime:** Added `scripts/deployment.sh` and `scripts/target_conf.txt` to deploy and uninstall artifacts across multiple IDEs with per-target disallow filters and an artifact mapping log.

- **Files changed:** `.gitignore`, `LICENSE`, `README.md`, `agents/auto_spec_check.md`, `agents/check_spec_codex.md`, `agents/check_spec_composer.md`, `agents/check_spec_opus.md`, `commands/spec_audit.md`, `commands/spec_check.md`, `commands/spec_create_intent.md`, `commands/spec_feature_update.md`, `commands/spec_implement.md`, `commands/spec_validate_intent.md`, `scripts/deployment.sh`, `scripts/target_conf.txt`, `skills/spec_development/SKILL.md`, `skills/spec_development/references/spec_assessment.md`, `skills/spec_development/references/spec_intent.md`, `skills/spec_development/references/spec_structure.md`

---

