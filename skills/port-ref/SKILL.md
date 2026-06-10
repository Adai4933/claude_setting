---
name: port-ref
description: Port or adapt a feature, script, config, or workflow from another project/repo used as reference. Use whenever the user points at a sibling project or file as the model for new work — phrases like "like project X", "refer to <path>", "using <repo> as reference", "same as in taskflow", "port from data-label-studio", "the logic is in <file>, add it here", or any request that names a reference path outside the current project. Also use when the user gives a reference implementation in one language to be re-implemented in another.
---

You are porting functionality from a reference project into the current (target) project. The reference shows the intent and the proven logic; the target dictates the language, framework, idiom, and conventions. The most common failure modes in this workflow are: copying the reference's style into a target that has its own, implementing in the reference's language instead of the target's, and duplicating functionality the target already has. Every step below exists to prevent one of those.

## Workflow

### Step 1: Lock the two ends
- Reference: the path/repo/file the user named. If the reference path is missing or ambiguous, ask — never guess which sibling project was meant.
- Target: current project, plus the specific module/location if named.
- State both languages explicitly (e.g. "reference: Python, target: Java"). When they differ, the port is a re-implementation, not a translation — note this in the plan.

### Step 2: Read the reference for intent
Read the reference implementation and extract: the flow, the data contracts, the edge cases it handles, the config it exposes. You are extracting *what it does and why*, not its code shape. If the user marked parts to skip or do differently ("refer to it, but don't do the same way"), record those exclusions now.

### Step 3: Audit the target for reuse
Before writing anything, search the target project for existing equivalents — clients, utilities, constants, i18n keys, API endpoints, Makefile targets. Anything that already exists gets reused or extended, never re-created. If the target already has a partial implementation, the plan diffs against it rather than starting fresh.

### Step 4: Plan, then wait for approval
Present a plan containing:
1. What gets ported (mapped to target-project conventions and file locations)
2. What gets adapted and why (language, framework, naming, config style)
3. What is explicitly NOT copied (reference-specific code, excluded parts, styles that clash with target)
4. What existing target code gets reused
5. Open questions, if any

Do not change code until the user gives an explicit approval token ("approve", "go ahead", "do it"). A question about the plan is not approval.

### Step 5: Implement additively
Existing target behavior stays byte-identical — the port adds, it does not alter neighbors. Match the target's code style and comment density, not the reference's. Keep values that the reference hardcoded configurable if the target convention is config-driven.

### Step 6: Verify in the target
Run the target project's own checks (make tidy / lint / tests — whatever the target defines). The reference project's tests are irrelevant; the port is done when the *target's* checks pass and the ported flow works in the target.

### Step 7: Report
Summarize: what was ported, where (file:line), what was adapted, what was intentionally dropped from the reference. Flag anything in the reference that looked valuable but was out of scope — mention, don't implement.

## Example

Input: "using the project ~/Desktop/Workstation/taskflow as reference, add make file here"
Right: read taskflow's Makefile + scripts, map each target to this project's actual stack (its package manager, its lint tools), plan which targets transfer and which don't apply, get approval, write a Makefile in this project's idiom.
Wrong: copy taskflow's Makefile and tweak paths.

Input: "the autoqa upload logic is in seer/backend/core/interchange_client.py, the write_chunk_autoqa method — add it here" (target is a Java project)
Right: extract the request flow, payload shape, retry semantics from the Python method; implement a Java client method following this project's existing client patterns.
Wrong: transliterate Python lines to Java.
