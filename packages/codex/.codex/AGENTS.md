# Personal engineering workflow

Read project AGENTS.md and its knowledge entrypoint before planning or editing.
For substantial behavior, contract or architecture changes, use the discoverable
`engineering-workflow` skill and applicable Superpowers skills. Announce the
skills actually loaded. Never infer that an installed plugin was loaded.
Small, obvious fixes use investigation, a focused change and relevant validation.

Use the user's active strong model for planning, integration and final review.
In Plan Mode use its highest supported reasoning effort; never force a stale
model identifier. Use engineering_worker (gpt-6-luna) only for precisely bounded,
mechanical work; engineering_integrator inherits the main model for judgment.
Use engineering_reviewer independently for spec and quality review. If a role
or model is unavailable, report that and use the active model without pretending
that a different model ran.

After plan approval, execute through verification without routine confirmation.
Do not edit project files in Plan Mode. Materialize approved plans in the
project's canonical location before source changes or executor delegation.
Only the main agent allocates task IDs and maintains task lifecycle, unless
explicitly delegated. Check all existing names for conflicts before creation.

Work in the current checkout. No automatic commits, worktrees, branch changes,
push, PR or publication. Preserve unrelated changes. These preferences override
Superpowers defaults, including frequent commits, automatic worktrees, default
plan paths and redundant execution-choice questions. Plans specify interfaces,
behavior, ownership and exact checks; full implementation listings are needed
only when they resolve a concrete ambiguity. Split by independently verifiable
outcome, not an arbitrary file count. Do not delete implementation merely
because it was written before a test.

Allow delegation for substantial approved plans and independent investigations.
At most three child agents; one source-code writer in this checkout at a time.
Give each a bounded outcome, owned paths, interfaces, relevant context and checks;
forbid reverting others' changes and further delegation. Keep coordination and
final integration in the main session. Reviewer instructions are read-only
behavioral constraints, not a separate permission sandbox.

Keep existing Flutter/FVM command authorizations. Use fvm flutter/fvm dart directly
in FVM projects with workdir set appropriately. Use the required tool escalation
for sandbox failures; never wrap commands to bypass permissions. Preserve each
project's external-effect, credential, budget and deployment gates.
