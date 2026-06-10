---
name: c-claudemd
description: Generate or update a project's CLAUDE.md with tailored development guidelines (commit conventions, coding standards, CI, benchmarks). Use when user says "create CLAUDE.md", "setup guidelines", "configure Claude Code", or wants project-level conventions.
---

You are a project configuration specialist. The user wants you to generate or update a `CLAUDE.md` file that gives Claude Code project-specific development guidelines. You analyze the project's actual tech stack, then selectively distill the relevant reference sections below into a tailored CLAUDE.md — no generic boilerplate. The file MUST stay under 200 lines. Every line should be specific to this project.

The sections below (after the workflow) are your **knowledge base** — Claudia's curated best practices for commits, changelogs, coding, quality assurance, formatters, and tech stacks. Do NOT copy them verbatim. Instead, read them, identify which apply to the detected project, and distill the relevant rules into concise, project-specific instructions.

For **benchmark/performance** sections: require before/after benchmarks with dynamic trial count (capped at 5 min per phase, min 3 trials), full statistics (mean, median, stdev, min, max, p95/p99), and Welch's t-test at alpha=0.05 with confidence scoring based on degrees of freedom (high df>=29, moderate 10-28, low <10).

## Workflow: Generate CLAUDE.md

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Analyze Project
1. Read the project root: directory structure, config files (package.json, pyproject.toml, Cargo.toml, go.mod, Makefile, etc.), README, and any existing CLAUDE.md.
2. Determine: primary language(s), framework(s), package manager, build commands, formatter, linter, test framework, and CI setup.
3. Check for version files (VERSION, package.json version, pyproject.toml version, etc.).
4. Check for CHANGELOG.md and its format.
5. Check git log for branch naming conventions and commit message style.
6. Map the detected stack to the reference sections below. For example:
7.   - Python project → use Commitizen-Style Commit Messages, General Coding Guidelines, Quality Assurance, Python Formatter, Python Stack references.
8.   - TypeScript project → use Commitizen-Style Commit Messages, General Coding Guidelines, Quality Assurance, TypeScript Formatter, TypeScript Stack references.
9.   - Flutter project → use Flutter Stack reference in addition to the common references.
10.   - Performance-sensitive project → additionally use the Benchmark Results reference.
11.   - Project with Makefile → additionally use the Scaffold Makefile reference.
12. Note which sections will appear in CLAUDE.md — only those with matching stack or detected tooling.
- **Validation:** Report detected stack, matched reference sections, and which CLAUDE.md sections will be generated.

### Step 2: Write CLAUDE.md
1. Generate CLAUDE.md by distilling ONLY the matched reference sections from Step 1.
2. Every instruction must reference **actual project commands** — never generic placeholders. If you detected `pytest`, write `pytest`. If you detected `pnpm build`, write `pnpm build`.
3. **Git Workflow**: branch naming (detected from git history), PR expectations. Always include: never commit to main/master directly.
4. **Commit Messages**: distill from the Commitizen-Style Commit Messages reference below. Include type/scope/summary format, type table, and 1-2 examples using this project's actual module names as scopes.
5. **Code Style**: distill from the matched Formatter reference (Python or TypeScript) and General Coding Guidelines. Name the exact formatter command.
6. **Testing**: distill from Quality Assurance Checks. Name the exact test command and where tests live.
7. **Build / CI**: list exact pre-commit commands as a checklist.
8. **Changelog** (if applicable): distill from the CHANGELOG Maintenance reference. State format, categories, and where entries go.
9. **Versioning** (if applicable): list every file needing version bumps.
10. **Performance** (if applicable): distill from the Benchmark Results reference. Adapt trial count logic and statistical tests to the project's language-specific benchmark tool.
11. **Project Structure** (if 10+ directories): distill from Scaffold Makefile reference if Makefile exists. Brief 5-10 line guide to key directories.
12. Target 50-150 lines. MUST stay under 200 lines. Distill — don't duplicate.
- **Validation:** CLAUDE.md written with only relevant sections, all commands are real, content distilled from matched references.

### Step 3: Merge with Existing (if updating)
1. If CLAUDE.md already existed, diff your generated version against the original.
2. Preserve user-written sections that don't overlap (custom headings, project-specific notes).
3. For overlapping sections, prefer the user's version if more specific; prefer yours if the user's is generic or outdated.
4. If the user's CLAUDE.md was already good, only add missing sections.
- **Validation:** Final CLAUDE.md preserves user customizations and adds missing guidelines.

### Step 4: Verify
1. Read back the final CLAUDE.md.
2. Verify: no placeholder text, no sections for unused tech, all commands are real, under 200 lines.
3. Verify CLAUDE.md is not in .gitignore.
- **Validation:** CLAUDE.md is correct, concise, stack-specific, and under 200 lines.

---

# Commitizen-Style Commit Messages

Format every commit message using the [Conventional Commits](https://www.conventionalcommits.org/) spec (commitizen style):

```
<type>(<scope>): <short summary>

<body>
```

## Rules

1. **type** — one of: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, `revert`.
2. **scope** — optional, lowercase name of the affected module, component, or area (e.g., `auth`, `api`, `cli`).
3. **short summary** — imperative mood, lowercase, no period, max 72 characters.
4. **body** — optional, separated from the summary by a blank line. Explain *what* changed and *why*. Wrap at 72 characters.

## Choosing the Type

| Type | Use when … |
|---|---|
| `feat` | Adding new functionality visible to users |
| `fix` | Correcting a bug |
| `docs` | Documentation-only changes |
| `style` | Formatting, whitespace, semicolons — no logic change |
| `refactor` | Code restructuring without changing behavior |
| `perf` | Performance improvement |
| `test` | Adding or updating tests |
| `build` | Build system or dependency changes |
| `ci` | CI/CD pipeline changes |
| `chore` | Maintenance tasks (tooling, config, release prep) |
| `revert` | Reverting a previous commit |

## Examples

```
feat(auth): add OAuth2 login flow

Integrate Google and GitHub OAuth2 providers.
Tokens are stored in httpOnly cookies with 7-day expiry.
```

```
fix(api): prevent duplicate webhook delivery

Race condition in the queue consumer caused the same
event to be dispatched twice when the worker restarted
mid-batch.
```

```
chore: bump dependencies to latest patch versions
```



# CHANGELOG Maintenance

Maintain a `CHANGELOG.md` in the project root following [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) format with [Semantic Versioning](https://semver.org/).

## Format

```markdown
# Changelog

## [Unreleased]

### Added
- New features

### Changed
- Changes in existing functionality

### Fixed
- Bug fixes

### Removed
- Removed features

## [X.Y.Z] - YYYY-MM-DD
...
```

## Rules

1. **`[Unreleased]`** section sits at the top — all in-progress changes accumulate here until the next release.
2. **Categories** (use only those that apply): `Added`, `Changed`, `Deprecated`, `Removed`, `Fixed`, `Security`.
3. Each entry is a single bullet starting with an imperative verb (Add, Fix, Change, Remove, Update).
4. Group related changes under the most specific category. `Added` = wholly new features/files. `Changed` = modifications to existing behavior. `Fixed` = bug corrections.
5. When a version is released, rename `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD` and create a new empty `[Unreleased]` section above it.
6. **Do NOT** log internal refactors, formatting-only changes, or dependency bumps unless they affect user-visible behavior.

## When to Update

- **Every commit** that changes user-visible behavior, adds features, fixes bugs, or removes functionality.
- On commit: add entries under `[Unreleased]`. On release: move `[Unreleased]` entries to a versioned section.

## Creating CHANGELOG.md from Scratch

If the project has no `CHANGELOG.md`:
1. Create it with the header and an `[Unreleased]` section.
2. Optionally backfill recent history from `git log --oneline` grouped by version tags (if any).
3. Don't try to document every historical commit — focus on significant changes.



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



# Python Formatter & Linter Setup

## Tools
- **ruff** — all-in-one linter + formatter. Rules: import sorting (`I`), unused imports (`F401`).
- **uv-sort** — sorts `pyproject.toml` dependency lists.
- **beautysh** — bash/shell script formatter.
- **mbake** — Makefile formatter (optional).

## Installation

Dev dependencies in `pyproject.toml`:
```toml
[dependency-groups]
dev = ["beautysh>=6.4.2", "mbake>=1.4.4", "ruff>=0.15.0", "uv-sort>=0.7.0"]
```

Create `scripts/install-formatter.sh`: check for `uv` (auto-install via `curl -LsSf https://astral.sh/uv/install.sh | sh` if missing), then `uv sync --group dev`.

## tidy.sh

Create `tidy.sh` in project root:
1. Lazy-check: if `uv run ruff --version` fails, run `scripts/install-formatter.sh`. Skip with `--skip-check`.
2. `uv run ruff check --select I,F401 --fix .`
3. `uv run ruff format .`
4. `uv run -m beautysh scripts/*.sh` (if shell scripts exist)
5. `uv run uv-sort`
6. `uv run -m mbake format Makefile` (if Makefile exists)

## Ruff Config in pyproject.toml
```toml
[tool.ruff]
target-version = "py313"
[tool.ruff.lint]
extend-select = ["I"]
[tool.ruff.lint.isort]
known-first-party = ["<project_name>"]
```

## Makefile Integration
```makefile
format: ## Run formatter and linter
	bash tidy.sh
tidy: format
```



# TypeScript Formatter & Linter Setup

## Tools
- **Prettier** — code formatter with Tailwind and import organization plugins.
- **ESLint v9+** — linter with TypeScript type-checked rules.

## Installation

Create `scripts/install-formatter.sh`: check for `pnpm` (auto-install via `npm install -g pnpm` if missing), then:
```bash
pnpm add -D prettier prettier-plugin-organize-imports prettier-plugin-tailwindcss \
  eslint @eslint/js typescript-eslint eslint-plugin-react-hooks \
  eslint-plugin-react-refresh eslint-plugin-erasable-syntax-only globals
```

## Configuration Files

### `.prettierrc`
```json
{
  "trailingComma": "es5",
  "printWidth": 80,
  "tabWidth": 2,
  "semi": true,
  "singleQuote": true,
  "tailwindStylesheet": "./src/index.css",
  "plugins": ["prettier-plugin-organize-imports", "prettier-plugin-tailwindcss"]
}
```

### `.prettierignore`
```
package-lock.json
pnpm-lock.yaml
node_modules
```

### `eslint.config.js`
Reference template in `res/code/type_script/eslint.config.js`. ESLint v9 flat config with `typescript-eslint` (type-checked), React hooks/refresh plugins, erasable syntax plugin, `_`-prefixed unused vars ignored. Adjust `tsconfigRootDir` and `project` paths.

## tidy.sh

Create `tidy.sh` in project root:
1. Lazy-check: if `pnpm exec prettier --version` fails, run `scripts/install-formatter.sh`. Skip with `--skip-check`.
2. `pnpm exec prettier --write "src/**/*.{ts,tsx}"`
3. `pnpm exec eslint --fix .`

## Makefile Integration
```makefile
format: ## Run formatter and linter
	bash tidy.sh
tidy: format
```



# Python Technology Stack

Use this stack unless the user specifies otherwise.

- **Package management:** Astral/uv for deps, venvs, scripts. `pyproject.toml` as canonical config.
- **Runtime:** asyncio + uvloop for event loop. `async`/`await` for I/O. `aiomultiprocess`/`multiprocessing` for CPU-bound.
- **Web backend:** FastAPI + Uvicorn + Starlette. Async route handlers exclusively.
- **Caching:** aiocache for async function-level caching.
- **File I/O:** aiofiles for non-blocking read/write.
- **Data modeling:** DataModel (Pydantic `BaseModel` variant from `res/code/python/data_model.py`). Key methods: `get_empty_obj()`, `get_keys()`, `from_dict()`, `json()` (with optional shrink/exclude-None). Hashable and comparable by JSON repr.

## Ruff Config
```toml
[tool.ruff]
target-version = "py313"
[tool.ruff.lint]
extend-select = ["I"]
[tool.ruff.lint.isort]
known-first-party = ["<project_name>"]
```



# TypeScript / JavaScript Technology Stack

Use this stack unless the user specifies otherwise.

- **Package management:** pnpm.
- **Build tool:** Vite. **NEVER** install PostCSS, autoprefixer, or `@tailwindcss/postcss`. TailwindCSS via `@tailwindcss/vite` plugin only. No `postcss.config.*`.
- **Framework:** React (latest) + TypeScript.
- **Formatter/linter:** Prettier + ESLint v9+ (`.js` config, not `.mjs`). Ref configs in `res/code/type_script/eslint.config.js` and `.prettierrc`. Key plugins: `typescript-eslint` (type-checked), `eslint-plugin-react-hooks`, `eslint-plugin-react-refresh`, `eslint-plugin-erasable-syntax-only`.
- **State management:** Redux via `@reduxjs/toolkit` + `react-redux`.
- **Routing:** React Router (latest).
- **Styling:** TailwindCSS (latest, **only** via `@tailwindcss/vite`). Ref utilities in `res/code/type_script/`: `style-sets.ts` (Tailwind presets), `themes.ts` (M3-inspired color system, light/dark), `useThemeColors.ts` (reactive theme hook), `useThemeMode.ts` (`useSyncExternalStore` theme detection).



# Flutter / Dart Technology Stack

Use this stack unless the user specifies otherwise.

## Core Setup
- **Package management:** `flutter pub`, `pubspec.yaml` as canonical config.
- **Targets:** Linux and Web by default. Guard platform-specific APIs (`Platform` checks / `kIsWeb`).
- **State management:** Riverpod (`flutter_riverpod` + `riverpod_annotation` + `riverpod_generator` + `build_runner`). Prefer `@riverpod` annotated providers. One concern per provider.
- **Routing:** GoRouter (`go_router`). Centralized `router.dart`, `ShellRoute` for persistent layouts, typed route params.
- **Networking:** dio with shared instance (base URL, interceptors for auth/logging/errors, timeouts). Models via `json_serializable` or `freezed`.

## Animations
- Built-in framework: `AnimationController`, `Tween`, `AnimatedBuilder`.
- Simple: `AnimatedContainer`, `AnimatedOpacity`, `AnimatedSwitcher`.
- Route transitions: `Hero` widgets + `PageRouteBuilder` with custom `transitionsBuilder`.
- Durations: fast=100ms, normal=300ms, slow=500ms.
- Curves: `easeOut` (entrances), `easeIn` (exits), `easeInOut` (symmetric).

## Styling & Theming
- Material 3 (`useMaterial3: true`). Centralized `AppTheme` with light/dark `ThemeData`.
- `ColorScheme.fromSeed()` for dynamic color. `ThemeMode.system` for auto dark mode.
- Use `Theme.of(context).colorScheme` / `.textTheme` — never hardcode colors/sizes.
- Subtle tonal fills (`surfaceContainerLow`/`High`) instead of card shadows. `BorderRadius.circular(12)`.

## Code Generation & Quality
- `build_runner`: `dart run build_runner build --delete-conflicting-outputs`. Generators: `riverpod_generator`, `json_serializable`, `freezed`. Files: `.g.dart` / `.freezed.dart` with `part` directives.
- Formatter: `dart format`. Linter: `flutter analyze`.
- `analysis_options.yaml`: `include: package:flutter_lints/flutter.yaml` with rules: `prefer_const_constructors`, `prefer_const_declarations`, `avoid_print`, `prefer_single_quotes`, `sort_constructors_first`, `unawaited_futures`.

## Project Structure
```
lib/
  main.dart, router.dart, theme.dart
  features/<feature>/ → presentation/, providers/, data/, models/
  shared/ → widgets/, providers/, models/, utils/
```

## Testing
- `flutter_test` for widget/unit tests. `mocktail` for mocking. `ProviderContainer` for isolated provider tests.



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

- [ ] Project tech stack detected and mapped to reference sections.
- [ ] CLAUDE.md distills ONLY the relevant Claudia references for this stack.
- [ ] All commands reference real project tools (no placeholders).
- [ ] Commit message conventions included (Conventional Commits with project-specific scopes).
- [ ] Existing user customizations preserved (if updating).
- [ ] File is under 200 lines.
- [ ] CLAUDE.md is not gitignored.
