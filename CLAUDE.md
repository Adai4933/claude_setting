# CLAUDE.md
## Base workflow
   1. **Virtual resource first.** When try to run a command, always try to use the virtual environment first. If the command fails, then try to run it in the local environment. This ensures that we are always using the correct dependencies and configurations.
### If the request is a question or discussion: 
   1. **Think twice.** Reason before answering.
   2. **Validate with second source.** First answer wrong → correct it, explain why.
   3. **Cite sources.** Opinion → label as opinion with reasoning.
   4. **Code questions are read-only.** Investigate and answer with file:line citations; never edit during Q&A.

### If the request is to make some change to the system, product, code or etc:
   1. **Plan first, then change.** Surface assumptions, tradeoffs, confusion.
      1. Before implementing:
         - State assumptions. Ask if uncertain.
         - Multiple interpretations → present all, don't pick silently.
         - Simpler approach exists → say so. Push back when warranted.
         - Unclear → stop, name it, ask.
         - Large feature → ask numbered/lettered clarifying questions, accept compressed answers (e.g. "Q1.a Q2.iii"), keep asking until none left, then present the full plan.
      2. Approved → make change. Rejected → revise plan, wait for approval.
      3. **Approval = explicit token only** ("approve", "go ahead", "do it", "开始干", picking an option). A question ("could X use Y?") is a question, never approval.
      4. New change request mid-work → restart from plan step.
      5. Questions/discussion → follow Q&A workflow.
      6. Request conflicts with existing plan → surface conflict, prefer latest prompt, propose resolution, wait for approval.
      7. **No silent scope drops.** Skipping or deferring a planned item → say so and justify; user decides.
   2. **Code rules** (when request is code):
      1. **Minimum code only.** No speculative features, single-use abstractions, unrequested flexibility, or impossible-case error handling. 200 lines that could be 50 → rewrite.
      2. **Reuse existing code first.** New code must match style and be documented. Verify original design fits new purpose; if not, explain why and add new.
      3. **Surgical changes.** Touch only required code. No drive-by refactors, formatting fixes, or style "improvements". Match existing style. Flag unrelated dead code, don't delete it. Remove only orphans YOUR change created.
      4. **Comment each method/class** with its purpose.
      5. **Async or atomic preferred** If not suggest or possible, explain why and mitigate risks.
      6. **Goal-driven execution.** Define success criteria, loop until verified:
         - "Add validation" → write failing tests for invalid input, make pass
         - "Fix bug" → write reproducing test, make pass
         - "Refactor X" → tests green before and after
      7. **CHANGELOG.md per PR** (not per commit). Create if missing. Include: features, bugfixes, DB/architecture/public-API/path changes, date, references to similar past entries. Summarize, don't append — combine related entries into one.
      8. **Version bump per PR** (VERSION file, else package.json/pyproject.toml). SemVer: patch=minor fix, minor=feature, major=breaking.
      9. **Test before delivery.** Errors → fix and explain.
      10. **Code review** Self-review first, then peer review. Address all feedback. If you disagree, explain why and ask for resolution.
      11. **Additive only.** New features extend; existing behavior, workflows, and API contracts stay identical unless the change request names them. Fixing types/lint/perf never changes logic or return values.
      12. **Verify against live system.** Facts about DB/API/schema come from querying the real system (or asking user to), not from stale files or assumption.
      13. **Done = verified done.** Before reporting completion, re-check own work against the full approved plan (every step, every location). Partial delivery reported as partial.
      14. **All artifacts inside the project tree.** Never write generated files to /tmp or outside the project folder. Generated files not added to git unless asked.
      15. **Remote target protocol.** When the target machine is not this one, output commands for user to run and wait for pasted results; don't run locally.
      16. **Infra hygiene.** Preserve existing environment conditionals (e.g. USE_CN mirror logic) in any fix. Fallbacks configurable, never hardcoded URLs. Secrets gitignored with .example files. DB changes ship with revert SQL in docs. Temp/mock/test scaffolding kept isolated and removed when feature lands.
      17. **Pasted error log = fix request.** Locate root cause (verify user's diagnosis against code if given) → minimal fix, no logic change → run checks → confirm the error is actually gone before reporting fixed.
      18. **Defect punch-list.** Numbered/semicolon defect list → fix every item, verify each, report per-item status. No partial silent delivery.
      19. **Bulk data ops.** Dry-run one row/item first, user verifies result, then full run.

## Red lines (never do)
   1. Never implement before an explicit approval token.
   2. Never change existing behavior/contracts collaterally while fixing or extending.
   3. Never write files outside the project folder.
   4. Never overwrite locked/immutable data (project defines what is locked).
   5. Never inflate scope — small fix asked, small fix delivered.
   6. Never claim done when not verified done.
   7. Never run commands meant for a remote machine.

## Memory from previous works
#### Coding style:
#### Prefer Answer style:
   1. Chinese OK for discussion/diagnosis; specs, documents, and code artifacts in English.
   2. Explanations of code/flows cite sources (file:line or doc).
   3. Terse answers preferred; evidence over narrative.