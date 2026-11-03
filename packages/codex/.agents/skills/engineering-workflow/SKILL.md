---
name: engineering-workflow
description: Plan, implement and independently review substantial code changes while preserving project behavior and contracts. Use for features, multi-step refactors and recurring regressions; keep obvious small fixes lightweight.
---

# Engineering workflow

Read the project's knowledge entrypoint and relevant feature instructions. Use
applicable discoverable Superpowers skills (brainstorming, writing-plans,
systematic-debugging, subagent-driven-development, requesting-code-review,
verification-before-completion); do not claim they loaded without reading them.
Personal/project instructions override their default Git and plan-storage policy.
If unavailable, disclose that and follow this workflow rather than blocking work.

## Establish the acceptance boundary

Trace current data flow and actual consumers. Distinguish implemented behavior,
intended requirements and verified behavior. Resolve contradictory API documents,
fixtures and source with evidence and the owner when intent remains uncertain.
Capture baseline failures before editing; unrelated pre-existing failures must
not be silently repaired or represented as new regressions.

For refactors, capture representative requests/responses, visible states and
screens before changing them. Preserve behavior unless explicitly changed.
For UI, obtain frame/state, dimensions, typography and real assets through a
working MCP or supplied code/screenshots. Generated Figma code is reference data,
not the project's architecture. Do not invent missing interactions or assets.

Agree on user-visible outcome, non-goals, constraints and mechanical acceptance.
For recurring bugs reproduce the failure and cover adjacent boundary cases;
passing aggregate suites does not replace a test of the reported defect.

## Plan and execute

In Plan Mode investigate and discuss without writing project files. Present a
self-contained plan with canonical target path, design/interface decisions,
dependencies, file ownership and exact validation commands/expected behavior.
Use code snippets where they prevent ambiguity, not a full speculative rewrite.

After approval, save the latest plan before implementation/delegation, using the
project's existing format and unique ID. One dossier per coherent result, with
subtasks inside; independent results may have separate dossiers. Keep progress
and evidence there, without a second competing plan or central status registry.

Delegate only well-bounded work. The main agent keeps the integration contract;
workers receive exact requirements, owned paths, dependencies, source pointers,
checks and permission boundaries in a fresh context. Report DONE,
DONE_WITH_CONCERNS, NEEDS_CONTEXT or BLOCKED with evidence. On failure first
repair missing context, then escalate model or decomposition as appropriate.
One implementation writer at a time; independent read-only exploration can run
in parallel. Executors must not delegate, revert others or allocate task IDs.

For behavioral changes use a failing regression test when feasible, implement
and verify it, then refactor. Do not add tautological tests for wording-only or
other reversible low-impact edits. Run integration checks after merging work.

## Independent acceptance

Give an independent reviewer the approved requirements and actual diff, rather
than the implementer's assurance. Review spec coverage first, then correctness,
architecture, lifecycle/races, failure handling and changed consumers. Require
concrete repro/evidence for findings. Fix and recheck substantive findings.
Review coherent work units and the final integration, not every trivial edit.

Map each requirement to evidence. For UI compare actual renderings with baseline
or approved design; widget assertions are not real Android/iOS validation.
For integrations distinguish built/configured, loaded by the running process,
and accepted end-to-end. AI quality requires representative reviewed samples;
offline fixtures cannot establish live quality, price or throughput.

Report changed behavior, commands/results, baseline failures, skipped checks and
remaining acceptance. Do not mark unchecked required acceptance complete.
Stop for a real blocker or material scope/authority change, not routine
"continue?" prompts. Preserve project external-effect gates.
