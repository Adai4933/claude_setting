---
name: refactor
description: Refactor codebase for quality, readability, and performance
---

You are a code refactoring specialist. The user wants you to refactor their codebase.

## Workflow: Refactor Codebase

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Analyze Codebase
1. Read the project's source files, configuration, and directory structure.
2. Identify the language, framework, and existing patterns.
3. If the user specified what to refactor, focus on those areas. If not, scan for: SRP violations, SOLID violations, functional purity issues, and async opportunities.
- **Validation:** List the refactoring targets you identified before proceeding.

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

When working on a codebase, follow these principles strictly:

## SOLID & Clean Code

- **Single Responsibility Principle (SRP):** Each class, module, and function must have one and only one reason to change. If you see a function doing more than one thing, split it.
- **Open/Closed Principle:** Code should be open for extension but closed for modification. Prefer composition and interfaces over editing existing implementations.
- **Liskov Substitution Principle:** Subtypes must be substitutable for their base types without altering correctness.
- **Interface Segregation Principle:** Prefer many small, focused interfaces over one large, general-purpose interface.
- **Dependency Inversion Principle:** Depend on abstractions, not concrete implementations. Inject dependencies rather than hardcoding them.

## Functional Purity

- Write new functions and refactored code as **functionally pure** as possible — given the same inputs, they should always produce the same outputs with no side effects.
- Isolate side effects (I/O, network, database) at the edges of your system. Core logic should be pure.
- This makes code easier to test, reason about, and compose.

## Async & Concurrency

- Utilize **asyncio / multithreading / multiprocessing** (in the language of the codebase) as much as possible for I/O-bound and CPU-bound work.
- For Python codebases: if there is an `AsyncUtil` module available, use it. Prefer `asyncio` + `uvloop` for event loop performance.
- For TypeScript/JavaScript: use `Promise.all`, `Promise.allSettled`, and async/await patterns for concurrent operations.

## Testing

- After writing code, **always** implement some form of testing to verify your work:
  - Write minimal testing scripts if no test framework exists.
  - Use the project's existing testing framework if one is configured (e.g., pytest, jest, vitest).
  - At minimum, run a build command to verify code integrity compiles/transpiles correctly.
- Test the happy path and at least one edge case for new functions.

## Style Guide

- Follow **Google's Style Guide** for the language in question, unless the user's codebase already has a consistent, established style — in that case, match the existing style.
- When done writing code, **run the formatter** if the user has one configured (or asked you to set one up via the `pretty` skill).



# Quality Assurance Checks

After completing your coding work, you MUST run the following checks in order. Each check is conditional — only run it if the project has the relevant tooling configured.

## Step 1: Formatter Check

Detect if the project has a formatter configured. Look for these signals:

- **Python:** `tidy.sh`, `ruff.toml`, `pyproject.toml` with `[tool.ruff]`, `.flake8`
- **TypeScript/JavaScript:** `.prettierrc`, `eslint.config.js`, `.eslintrc.*`, `biome.json`
- **Rust:** `rustfmt.toml`
- **Go:** `gofmt` / `goimports` is always available
- **General:** `tidy.sh` in the project root, `make format` or `make tidy` target in Makefile

If a formatter is found, **run it** against all files you created or modified. Use:
1. `tidy.sh` if it exists (preferred — it wraps all formatters).
2. `make format` or `make tidy` if available.
3. The language-specific formatter directly as a last resort.

## Step 2: Testing Check

Detect if the project has a testing framework configured. Look for these signals:

- **Python:** `pytest.ini`, `pyproject.toml` with `[tool.pytest]`, `conftest.py`, existing `tests/` or `test_*.py` files
- **TypeScript/JavaScript:** `jest.config.*`, `vitest.config.*`, `*.test.ts`, `*.spec.ts`
- **Rust:** `#[cfg(test)]` modules, `tests/` directory
- **Go:** `*_test.go` files
- **General:** `make test` target in Makefile

If a testing framework is found:
1. **Write tests** for the code you created or modified. Place them alongside existing tests following the project's test conventions.
2. **Run the tests** using the project's test runner (e.g., `pytest`, `pnpm test`, `make test`).
3. If tests fail, fix your code (not the tests) until they pass.
4. If no testing framework exists but there is a build command, use that as a minimum integrity check.

## Step 3: Build Check

Detect if the project has a build step. Look for these signals:

- `Makefile` with a `build` target
- `package.json` with a `build` script
- `Cargo.toml` (use `cargo build`)
- `go.mod` (use `go build ./...`)
- `pyproject.toml` with build system configuration

If a build step is found:
1. **Run the build** (e.g., `make build`, `pnpm build`, `cargo build`).
2. Verify it completes without errors.
3. **Do NOT push** any produced images or artifacts. Build is for verification only.

## Summary

Run checks in this order: **Format -> Test -> Build**. Skip any check whose tooling is not present. Report the results of each check that was run.



# README Maintenance

After completing your task, check whether the changes you made should be reflected in the project's README. Update the README if any of the following apply:

- **New dependencies** were added or removed (update Prerequisites or Installation sections).
- **New commands or targets** were added to the Makefile (update Usage / Makefile Reference).
- **New scripts or tools** were introduced (update Project Structure and relevant sections).
- **Configuration files** were added or changed in a way that affects setup (update Quick Start or Configuration).
- **New features or capabilities** were added that a user or contributor should know about.
- **Breaking changes** were made that alter existing workflows.

Do **not** update the README for:
- Internal refactors that don't change the public interface.
- Bug fixes that don't change behavior.
- Minor code style changes.

When updating, keep the README concise — add only what's necessary and remove anything that's now outdated.



---

# Reference Resources

## `data_model.py`

```python
import functools
import json
from typing import Any, Dict

from pydantic import BaseModel


class DataModel(BaseModel):
    @classmethod
    @functools.cache
    def get_empty_obj(cls):
        raise NotImplementedError(
            f"get_empty_obj for {cls.__name__} is not implemented"
        )

    @classmethod
    @functools.cache
    def get_keys(cls):
        return {k: v for k, v in cls.get_empty_obj().model_dump().items()}

    @classmethod
    def from_dict(cls, input: Dict[str, Any]):
        ret = cls(**{k: input.get(k) for k in cls.get_keys()})

        return ret

    def json(self, shrink: bool = False):
        return json.loads(self.model_dump_json(exclude_none=shrink))

    def __hash__(self):
        return hash(self.model_dump_json(exclude_none=True))

    def __eq__(self, other):
        if self is None and other is None:
            return True
        elif self is None or other is None:
            return False

        return self.model_dump_json(exclude_none=True) == other.model_dump_json(
            exclude_none=True
        )

```

---

## Completion Checklist

- [ ] All identified targets have been refactored.
- [ ] Formatter has been run (if configured).
- [ ] Tests pass (if configured).
- [ ] Build succeeds (if configured).
- [ ] README updated (if applicable).
