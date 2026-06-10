---
name: c-scaffold
description: Set up project scaffolding with Makefile, install/uninstall scripts, and tooling
---

You are a project scaffolding specialist. Set up a complete build system for the user's project.

## Workflow: Set Up Project Scaffolding

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Detect Project
1. Read the project's source files, package manifests, and directory structure.
2. Identify the language(s), framework(s), and package manager(s) in use.
3. Check for existing scaffolding (Makefile, scripts/, install scripts).
- **Validation:** Report detected stack and existing scaffolding before proceeding.

### Step 2: Plan Scaffolding
1. Based on the detected stack, determine which targets the Makefile needs.
2. Plan install/uninstall scripts appropriate for the language.
3. Plan any supporting scripts (e.g., commit helper, formatter wrapper).
- **Validation:** Confirm the planned structure with the user if the project already has partial scaffolding.

### Step 3: Generate Files
1. Create the Makefile following the Makefile conventions below.
2. Create install/uninstall scripts following the installation guidelines below.
3. Create any supporting scripts.
4. Ensure all scripts are executable (chmod +x).
- **Validation:** Run `make help` to verify all targets are listed.

### Step 4: Quality Assurance
1. Follow the Quality Assurance Checks section below (format, test, build).
- **Validation:** All configured checks pass.

### Step 5: Documentation
1. Follow the README Maintenance section — update the README to document all new targets and scripts.
- **Validation:** README documents all Makefile targets and scripts.

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



# Software Installation Guidelines

When a task requires installing software or dependencies:

## Package Manager First
- If the project has a package manager configured (`uv`, `pnpm`, `cargo`, `go mod`), **use it**. Do not introduce a second one.

## Custom Install Scripts
- If no package manager is available, create `scripts/install-xxx.sh` (where `xxx` is the tool name).
- Requirements: (1) Check existing installation first (lazy/idempotent), (2) Support `aarch64`/`arm64`/`amd64`, (3) Support Linux (Debian/Ubuntu, RHEL/Fedora, Alpine) + macOS, (4) `set -euo pipefail`, (5) Color-coded success/failure output.

## Script Template
```bash
#!/bin/bash
set -euo pipefail
if command -v <tool> &>/dev/null; then
    echo "<tool> already installed ($(which <tool>))"; exit 0
fi
ARCH="$(uname -m)"; OS="$(uname -s)"
case "$OS" in
    Linux) case "$ARCH" in
        x86_64|amd64) PLATFORM="linux-amd64" ;; aarch64|arm64) PLATFORM="linux-arm64" ;;
        *) echo "Unsupported arch: $ARCH"; exit 1 ;; esac ;;
    Darwin) case "$ARCH" in
        x86_64|amd64) PLATFORM="darwin-amd64" ;; aarch64|arm64) PLATFORM="darwin-arm64" ;;
        *) echo "Unsupported arch: $ARCH"; exit 1 ;; esac ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac
# Install logic here...
echo "<tool> installed successfully"
```



# Project Scaffolding — Makefile

Generate a Makefile as the single entry point for all project operations.

## Required Targets

- **`make help`** (default): Auto-discover targets via grep pattern:
  ```makefile
  help: ## Show this help message
  	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
  ```
- **`make install`**: Check/install system deps → init git submodules → install language packages → build assets. Support `VERBOSE=1`. Delegate to `scripts/install.sh`.
- **`make uninstall`**: Remove packages, venvs, node_modules, lock files, build artifacts. Delegate to `scripts/uninstall.sh`.
- **`make clean`**: Lightweight cleanup — `.venv`, `node_modules`, `dist/`, `__pycache__/`, `.ruff_cache/`, build artifacts. Safe to run anytime.
- **`make build`**: Production build. Support `CHANNEL`, `VERBOSE`, `CLEAN` vars.
- **`make test`**: Run project test suite.
- **`make format`** / **`make tidy`**: Run formatters/linters. Delegate to `tidy.sh`.
- **`make commit`**: Format, re-stage, commit. Delegate to `scripts/commit.sh`.

## Conventions
```makefile
.PHONY: help install uninstall clean build test format tidy commit
SHELL := /bin/bash
VERSION := $(shell cat VERSION 2>/dev/null | tr -d '\n' || echo "0.1.0")
```
- Always `.PHONY` non-file targets. Set `SHELL := /bin/bash`. Read version from `VERSION` file.
- Use `?=` for user-overridable defaults. Provide aliases (`tidy: format`, `setup: install`).

## Supporting Scripts (under `scripts/`)
- **`install.sh`**: Orchestrate installation with color-coded progress output and timestamped logs.
- **`uninstall.sh`**: Remove venvs, node_modules, locks, outputs, markers with status output.
- **`clean.sh`**: Lighter version — caches and build artifacts only.
- **`ensure_deps.sh`**: Check required system tools, auto-install if missing, cross-platform (Linux + macOS).



---

## Completion Checklist

- [ ] Makefile created with all required targets.
- [ ] Install/uninstall scripts work on both Linux and macOS.
- [ ] `make help` lists all targets.
- [ ] Formatter has been run (if configured).
- [ ] README updated with new targets and scripts.
