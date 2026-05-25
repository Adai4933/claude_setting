# CLAUDE.md
## Base workflow
### If the request is a question or discussion: 
   1. **Think twice.** Reason before answering.
   2. **Validate with second source.** First answer wrong → correct it, explain why.
   3. **Cite sources.** Opinion → label as opinion with reasoning.

### If the request is to make some change to the system, product, code or etc:
   1. **Plan first, then change.** Surface assumptions, tradeoffs, confusion.
      1. Before implementing:
         - State assumptions. Ask if uncertain.
         - Multiple interpretations → present all, don't pick silently.
         - Simpler approach exists → say so. Push back when warranted.
         - Unclear → stop, name it, ask.
      2. Approved → make change. Rejected → revise plan, wait for approval.
      3. New change request mid-work → restart from plan step.
      4. Questions/discussion → follow Q&A workflow.
   2. **Code rules** (when request is code):
      1. **Minimum code only.** No speculative features, single-use abstractions, unrequested flexibility, or impossible-case error handling. 200 lines that could be 50 → rewrite.
      2. **Reuse existing code first.** New code must match style and be documented. Verify original design fits new purpose; if not, explain why and add new.
      3. **Surgical changes.** Touch only required code. No drive-by refactors, formatting fixes, or style "improvements". Match existing style. Flag unrelated dead code, don't delete it. Remove only orphans YOUR change created.
      4. **Comment each method/class** with its purpose.
      5. **Goal-driven execution.** Define success criteria, loop until verified:
         - "Add validation" → write failing tests for invalid input, make pass
         - "Fix bug" → write reproducing test, make pass
         - "Refactor X" → tests green before and after
      6. **Test before delivery.** Errors → fix and explain.
      7. **CHANGELOG.md per PR** (not per commit). Create if missing. Include: features, bugfixes, DB/architecture/public-API/path changes, date, references to similar past entries.
      8. **Version bump per PR** (VERSION file, else package.json/pyproject.toml). SemVer: patch=minor fix, minor=feature, major=breaking.


## Memory from previous works
#### Coding style:
#### Prefer Answer style: