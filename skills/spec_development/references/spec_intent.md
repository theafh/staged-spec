<task_block>
  <role>Spec Intent</role>

  <objective>
    The Project Intent Summary (`specs/intent.md`) captures the non-negotiable identity of the project. It acts as a guardrail for the entire project -- every spec and every line of code must stay within the bounds it defines.
  </objective>

  <inputs>
    <intent_structure>
      <summary>The intent document uses six sections:</summary>

      <core_purpose>What problem does this system solve, and for whom? (1-2 sentences)</core_purpose>
      <architectural_commitments>Non-negotiable structural decisions -- the choices that, if violated, would mean the project has drifted from its intent. Only include commitments that are load-bearing for the project's identity.</architectural_commitments>
      <domain_boundaries>What this system is explicitly responsible for and what is explicitly out of scope. Frame as "This system DOES X. This system DOES NOT do Y." Be concrete -- vague boundaries catch nothing.</domain_boundaries>
      <key_invariants>Properties that must hold true across all future development. If broken, they indicate either a bug or unintended scope creep.</key_invariants>
      <integration_contract_surface>External systems this project touches, and the nature of each contract: inbound vs. outbound, sync vs. async, owned vs. consumed. This defines where the system ends and the world begins.</integration_contract_surface>
      <intentional_constraints>Decisions that look like limitations but are deliberate. These are the things a well-meaning contributor -- or agent -- might "fix" without realizing they're violating intent.</intentional_constraints>
    </intent_structure>
  </inputs>

  <policy>
    <modification_rules>
      <summary>The intent document is a guardrail — it governs all other specs, and only the human user has authority to change it.</summary>
      <rule>Changes to `specs/intent.md` require an explicit, direct request from the human user in the current conversation; treat side-effect modifications during stage creation, refinement, implementation, or status updates as out of bounds.</rule>
      <rule>When a spec change appears to conflict with the intent document, fix the spec to align with the intent. Escalate to the user when alignment requires a trade-off or when the conflict touches a core architectural commitment.</rule>
    </modification_rules>

    <creation_rules>
      <rule>Each item must be falsifiable -- someone should be able to hold it against a diff, a new spec stage, or an agent's output and get a binary yes/no on consistency.</rule>
      <rule>If the specs are ambiguous or silent on something that should be stated, flag it as `[UNDERSPECIFIED]` and stop; wait for the user to supply the missing intent. During an interactive session, actively surface each underspecified area to the user and ask targeted questions to fill the gap before finalizing the document.</rule>
      <rule>Prefer 15-25 items total across all sections. Fewer if the system is genuinely simple. More means you're drifting into implementation detail.</rule>
      <rule>Keep implementation details out (no file paths, function names, library versions) -- this is a summary of what and why, not how.</rule>
    </creation_rules>
  </policy>

  <output_contract>
    <validation_rules>
      <summary>When validating specs or code against the intent document, check each item against every intent section:</summary>
      <rule>**Core Purpose** -- does it solve a different problem or serve a different audience than the one the intent defines?</rule>
      <rule>**Architectural Commitments** -- does it introduce a pattern the intent rules out?</rule>
      <rule>**Domain Boundaries** -- does it take responsibility for something the intent marks as out of scope, or ignore something the intent marks as in scope?</rule>
      <rule>**Key Invariants** -- does it introduce a path that violates a property the intent declares must always hold?</rule>
      <rule>**Integration Contract Surface** -- does it change the nature of an external contract the intent defines?</rule>
      <rule>**Intentional Constraints** -- does it remove or work around a limitation the intent marks as deliberate?</rule>
      <prioritization>Order violations by how much damage they would cause if shipped. Place the violation most likely to produce a fundamentally wrong outcome first. For each violation, ask: "If this shipped, would the system behave in a way the intent explicitly forbids, or would it merely drift from its intended shape?" The closer the answer is to "explicitly forbidden behavior," the higher it belongs in the list.</prioritization>
    </validation_rules>
  </output_contract>
</task_block>
