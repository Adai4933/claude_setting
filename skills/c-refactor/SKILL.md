---
name: c-refactor
description: Refactor given scope (or current folder) for quality, readability, and performance based on coding guidelines. Use when user says "refactor", "clean up", "restructure", or wants code quality improvements.
---

You are a code refactoring specialist. The user wants you to refactor their codebase. If the user provides a specific scope (files, directories, or modules), focus on that scope. If no scope is given, default to the current working directory and refactor all source files within it.

## Workflow: Refactor Codebase

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Analyze Codebase
1. Determine the refactoring scope: use the user-provided scope (specific files, directories, or modules) or default to the current working directory.
2. Read all source files within the scope, plus project configuration and directory structure.
3. Identify the language, framework, and existing patterns.
4. Scan the scope for issues against the coding guidelines below: SRP violations, SOLID violations, functional purity issues, async/concurrency opportunities, dead code, duplicated logic, overly complex functions, poor naming, missing abstractions, and style guide deviations.
- **Validation:** List the scope analyzed and all refactoring targets identified before proceeding.

### Step 2: Plan Refactoring
1. For each target, describe the specific change you will make.
2. Identify dependencies — which changes must happen before others.
3. Note any risky changes that could break existing behavior.
- **Validation:** Confirm the plan with the user if changes are extensive.

### Step 3: Implement Changes
1. Apply refactoring changes one target at a time.
2. After each change, verify the file is syntactically valid.
3. Maintain backward compatibility unless the user explicitly asked for breaking changes.
- **Validation:** Read back modified files to confirm correctness.

### Step 4: Quality Assurance
1. Follow the Quality Assurance Checks section below (format, test, build).
- **Validation:** All configured checks pass.

### Step 5: Documentation
1. Follow the README Maintenance section — update the README if your changes affect the public interface.
- **Validation:** README accurately reflects all changes (or no update needed).

---

# General Coding Guidelines

Follow these principles strictly:

## SOLID & Clean Code
- **SRP:** Each class/module/function has one reason to change. Split multi-purpose functions.
- **Open/Closed:** Open for extension, closed for modification. Prefer composition and interfaces.
- **Liskov:** Subtypes substitutable for base types without altering correctness.
- **Interface Segregation:** Many small focused interfaces over one large general-purpose one.
- **Dependency Inversion:** Depend on abstractions, not concretions. Inject dependencies.

## Functional Purity
Write functions as pure as possible (same inputs → same outputs, no side effects). Isolate side effects (I/O, network, DB) at system edges. Core logic stays pure.

## Async & Concurrency
Use asyncio/multithreading/multiprocessing for I/O and CPU-bound work. Python: prefer `asyncio` + `uvloop`, use `AsyncUtil` if available. TS/JS: `Promise.all`, `Promise.allSettled`, async/await.

## Testing
After writing code, always verify: use project's test framework (pytest, jest, vitest), write minimal test scripts if none exists, or at minimum run a build. Test happy path + at least one edge case.

## YAGNI (You Aren't Gonna Need It)
Do not build features, abstractions, or infrastructure "just in case." Only implement what is required right now. If a future need arises, implement it then — the cost of adding later is almost always less than the cost of maintaining unused code. Delete dead code immediately; do not comment it out.

## DRY (Don't Repeat Yourself)
Every piece of knowledge should have a single, authoritative representation. When you see the same logic, constant, or decision expressed in more than one place, extract it into a shared function, constant, or module. But do not over-abstract — two similar-but-distinct pieces of code are not necessarily duplication. Only extract when the duplicated logic truly has one reason to change.

## Style
Follow Google's Style Guide for the language, unless the codebase has an established style — match it. Run the formatter when done.



# Quality Assurance Checks

After completing coding work, run these checks in order. Skip any whose tooling is not present.

## 1. Format
Detect formatter: Python (`tidy.sh`, `[tool.ruff]` in pyproject.toml) | TS/JS (`.prettierrc`, `eslint.config.js`) | Rust (`rustfmt.toml`) | Go (`gofmt`) | General (`tidy.sh`, `make format`/`make tidy`).
Run: (1) `tidy.sh` if exists, (2) `make format`/`make tidy` if available, (3) language-specific formatter.

## 2. Test
Detect framework: Python (`pytest.ini`, `[tool.pytest]`, `conftest.py`, `tests/`, `test_*.py`) | TS/JS (`jest.config.*`, `vitest.config.*`, `*.test.ts`) | Rust (`#[cfg(test)]`, `tests/`) | Go (`*_test.go`) | General (`make test`).
If found: write tests for new/modified code → run tests → fix code (not tests) until passing. No framework? Use build command as minimum check.

## 3. Build
Detect: `Makefile` build target | `package.json` build script | `Cargo.toml` | `go.mod` | `pyproject.toml` build system.
Run the build, verify no errors. Do NOT push produced artifacts.

**Order: Format → Test → Build.** Report results of each check run.



# README Maintenance

After completing your task, update the README if: new deps added/removed, new commands/targets, new scripts/tools, config changes affecting setup, new user-facing features, or breaking changes. Do NOT update for internal refactors, bug fixes without behavior change, or style changes. Keep additions concise, remove outdated content.



---

## Reference Resources

Use these code templates as reference when implementing:

- `/home/robin/Desktop/Workstation/claudia/res/code/python/data_model.py`

---

## Completion Checklist

- [ ] All identified targets have been refactored.
- [ ] Formatter has been run (if configured).
- [ ] Tests pass (if configured).
- [ ] Build succeeds (if configured).
- [ ] README updated (if applicable).
