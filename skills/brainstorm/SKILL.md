---
name: brainstorm
description: Design and build a new project from user requirements
---

You are a full-stack project architect. The user wants to create a new project from scratch.

**IMPORTANT:** Enter plan mode first.

## Workflow: Design and Build New Project

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Gather Requirements
1. Ask the user clarifying questions about: target language/framework, core features, UI/UX preferences (if applicable), deployment targets, and any specific libraries or tools.
2. Wait for user responses before proceeding.
- **Validation:** Summarize the requirements back to the user for confirmation.

### Step 2: Design Architecture
1. Design the project structure (directories, modules, key files).
2. Choose the tech stack components based on user preferences and the stack guides below.
3. Plan data models, API routes, and component hierarchy as applicable.
- **Validation:** Present the architecture plan to the user for approval before implementing.

### Step 3: Scaffold the Project
1. Create the directory structure.
2. Set up the package manager and dependencies.
3. Create the Makefile following the scaffolding conventions below.
4. Create install/uninstall scripts.
- **Validation:** Run `make install` or equivalent to verify dependencies install.

### Step 4: Implement Core Features
1. Build each feature one at a time, starting with the most foundational.
2. Follow the coding guidelines below.
3. After each feature, verify it works in isolation.
- **Validation:** Run the project to confirm each feature works.

### Step 5: Quality Assurance
1. Follow the Quality Assurance Checks section below (format, test, build).
- **Validation:** All configured checks pass.

### Step 6: Documentation
1. Generate a README using the README maintenance guidelines below.
2. The README should enable a new contributor to set up and use the project independently.
- **Validation:** README is complete and all documented commands work.

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



# Software Installation Guidelines

When a task requires installing software or dependencies:

## Package Manager First

- If the project already has a package manager configured (e.g., `uv`, `pnpm`, `cargo`, `go mod`), **use it** for installation. Do not introduce a second package manager.

## Custom Install Scripts

- If no package manager is available, write a bash script called `install-xxx.sh` (where `xxx` is the software name) and place it under `scripts/` in the user's project root.
- The script must:
  1. **Check for existing installation** before performing any work (lazy/idempotent).
  2. **Support multiple architectures:** `aarch64` / `arm64` / `amd64`.
  3. **Support all Unix platforms:** Linux (Debian/Ubuntu, RHEL/Fedora, Alpine) and macOS.
  4. Use `set -euo pipefail` for safety.
  5. Provide clear, color-coded output indicating success or failure.

## Script Template

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Check if already installed
if command -v <tool> &>/dev/null; then
    echo "<tool> is already installed ($(which <tool>))"
    exit 0
fi

ARCH="$(uname -m)"
OS="$(uname -s)"

case "$OS" in
    Linux)
        case "$ARCH" in
            x86_64|amd64) PLATFORM="linux-amd64" ;;
            aarch64|arm64) PLATFORM="linux-arm64" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        ;;
    Darwin)
        case "$ARCH" in
            x86_64|amd64) PLATFORM="darwin-amd64" ;;
            aarch64|arm64) PLATFORM="darwin-arm64" ;;
            *) echo "Unsupported architecture: $ARCH"; exit 1 ;;
        esac
        ;;
    *) echo "Unsupported OS: $OS"; exit 1 ;;
esac

# Install logic here...
echo "<tool> installed successfully"
```



# Python Technology Stack

When working on a Python project, use the following stack unless the user specifies otherwise:

## Package Management

- **Astral/uv** — use `uv` for dependency management, virtual environments, and running scripts.
- `pyproject.toml` is the canonical project configuration file.

## Execution & Runtime

- **asyncio + uvloop** for the event loop (unless the user explicitly asks not to use uvloop).
- Use `async`/`await` throughout for I/O-bound work.
- For CPU-bound work, use `aiomultiprocess` or `multiprocessing`.

## Web Backend

- **FastAPI** + **Uvicorn** + **Starlette** for HTTP APIs.
- Use async route handlers exclusively.

## Caching

- **aiocache** for function-level caching with async support.

## File I/O

- **aiofiles** for all file read/write operations to avoid blocking the event loop.

## Data Modeling

- **DataModel** — a variant of Pydantic's `BaseModel` with convenience methods. Reference implementation is provided in `res/code/python/data_model.py`.
- Key features of DataModel:
  - `get_empty_obj()` class method (override to provide default instance)
  - `get_keys()` for retrieving model field names
  - `from_dict()` for constructing from a dictionary
  - `json()` for serialization with optional shrinking (exclude None)
  - Hashable and comparable by JSON representation

## Project Configuration

```toml
[tool.ruff]
target-version = "py313"

[tool.ruff.lint]
extend-select = ["I"]  # Import sorting

[tool.ruff.lint.isort]
known-first-party = ["<project_name>"]
```



# TypeScript / JavaScript Technology Stack

When working on a TypeScript/JavaScript project, use the following stack unless the user specifies otherwise:

## Package Management

- **pnpm** — use `pnpm` for dependency management.

## Build Tool

- **Vite** — use Vite as the bundler. **DO NOT USE POSTCSS.**

## Frontend Framework

- **React** (latest version) with TypeScript.

## Formatter & Linter

- **Prettier** for code formatting.
- **ESLint v9+** for linting. Config must be `.js` format (not `.mjs`).
- Reference ESLint config is provided in `res/code/type_script/eslint.config.js`.
- Reference Prettier config is provided in `res/code/type_script/.prettierrc`.
- Key ESLint plugins:
  - `typescript-eslint` with type-checked configs
  - `eslint-plugin-react-hooks`
  - `eslint-plugin-react-refresh`
  - `eslint-plugin-erasable-syntax-only`

## State Management

- **Redux** via `@reduxjs/toolkit` and `react-redux`.

## Routing

- **React Router** (latest version).

## Styling

- **TailwindCSS** (latest version, integrated via `@tailwindcss/vite` plugin).
- Reference style utilities are provided in:
  - `res/code/type_script/style-sets.ts` — reusable Tailwind class presets
  - `res/code/type_script/themes.ts` — Material 3-inspired color system with light/dark mode
  - `res/code/type_script/useThemeColors.ts` — React hook for reactive theme colors
  - `res/code/type_script/useThemeMode.ts` — React hook using `useSyncExternalStore` for system theme detection



# UI Styling Guidelines

When building user interfaces, follow these guidelines:

## Color System & Theming

- Use the provided theming system from `res/code/type_script/`:
  - **themes.ts** — full color system with light/dark palettes, color manipulation utilities (HSL, complementary colors, darken, etc.)
  - **style-sets.ts** — reusable Tailwind CSS class presets for buttons, surfaces, transitions, and borders
  - **useThemeColors.ts** — React hook returning `{ theme, isDark, mode }` based on system preference
  - **useThemeMode.ts** — lightweight React hook using `useSyncExternalStore` for zero-Redux theme detection
- Copy these files into the project's `src/utils/` (themes, style-sets) and `src/hooks/` (useThemeColors, useThemeMode) directories.
- Support both **light and dark modes** based on system preference (`prefers-color-scheme`).

## Accessibility (WCAG)

- Adhere to **WCAG 2.1 AA** standards at minimum:
  - Normal text: contrast ratio of at least **4.5:1**
  - Large text (18px+ or 14px+ bold): contrast ratio of at least **3:1**
  - Interactive elements: clearly distinguishable focus states
- Test contrast ratios when choosing colors. The themes.ts utility provides HSL manipulation for adjusting luminance.

## Visual Design

- **No shadows behind divs** — avoid `box-shadow` and Tailwind shadow utilities.
- **Slightly rounded corners** — use `rounded-lg` or `rounded-xl` (8-12px), similar to Apple Human Interface Design guidelines.
- Primary design language: **Material Design 3 (Material You)**
  - Surface containers with subtle tonal fills
  - State layers for interactive feedback
  - Dynamic color based on primary color extraction

## Transitions

- Use smooth, consistent transitions:
  - Normal: `all 0.3s ease-out`
  - Fast (hover feedback): `all 0.1s ease-out`
  - Slow (page transitions): `all 0.5s ease-in-out`
- Reference: `StyleSets.TRANSITION_STYLE` provides a standard Tailwind class string.

## Component Patterns

- Buttons: subtle background (`bg-current/5`), thin outline on hover, rounded corners. Reference: `StyleSets.BUTTON_STYLE`.
- Borders: use `border-black/10 dark:border-white/10` for subtle separation. Reference: `StyleSets.OUTLINE_BORDER_STYLE`.
- Interactive surfaces: add hover state with `hover:bg-current/5 dark:hover:bg-white/15`.



# Project Scaffolding — Makefile

Generate a Makefile that follows the conventions of well-structured projects. The Makefile should serve as the single entry point for all project operations.

## Required Targets

### `make help` (default target)
- Display all available targets with descriptions.
- Use a grep-based auto-discovery pattern:
```makefile
help: ## Show this help message
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'
```

### `make install`
- Orchestrate full project installation:
  1. Check and install system-level dependencies (package managers, build tools).
  2. Initialize git submodules if applicable.
  3. Install language-specific packages (e.g., `uv sync` for Python, `pnpm install` for TypeScript).
  4. Build any frontend or compiled assets.
- Support a `VERBOSE=1` flag for detailed output.
- Delegate to `scripts/install.sh`.

### `make uninstall`
- Remove installed packages, virtual environments, node_modules, lock files, build artifacts, and any generated markers.
- Delegate to `scripts/uninstall.sh` or `scripts/clean.sh`.

### `make clean`
- Lightweight cleanup: remove `.venv`, `node_modules`, `dist/`, `__pycache__/`, `.ruff_cache/`, build artifacts.
- Should be safe to run at any time.

### `make build`
- Build the project for production.
- Support optional variables: `CHANNEL`, `VERBOSE`, `CLEAN`.

### `make test`
- Run the project's test suite.

### `make format` / `make tidy`
- Run code formatting and linting. Both targets should do the same thing.
- Delegate to `tidy.sh` in the project root.

### `make commit`
- Run formatter, re-stage modified files, then create a commit.
- Delegate to `scripts/commit.sh`.

## Makefile Conventions

```makefile
.PHONY: help install uninstall clean build test format tidy commit

SHELL := /bin/bash

# Version from VERSION file
VERSION := $(shell cat VERSION 2>/dev/null | tr -d '\n' || echo "0.1.0")
```

- Always declare `.PHONY` for non-file targets.
- Set `SHELL := /bin/bash` explicitly.
- Read version from a `VERSION` file.
- Use conditional variables with `?=` for user-overridable defaults (e.g., `CHANNEL ?= production`).
- Provide aliases for common targets (e.g., `tidy: format`, `setup: install`).

## Supporting Scripts

Create the following scripts under `scripts/`:

### `scripts/install.sh`
- Orchestrate installation with progress output.
- Use color-coded status indicators (green checkmark for success, red X for failure).
- Create timestamped log directories for audit.

### `scripts/uninstall.sh`
- Remove virtual environments, node_modules, lock files, build outputs, and marker files.
- Provide clear status output for each removal step.

### `scripts/clean.sh`
- Lighter version of uninstall — remove caches and build artifacts only.

### `scripts/ensure_deps.sh`
- Check for required system tools (e.g., `uv`, `pnpm`, `cmake`).
- Auto-install if missing.
- Support cross-platform (Linux + macOS).



# Python Formatter & Linter Setup

Set up code formatting and linting for a Python project.

## Tools

- **ruff** — all-in-one Python linter and formatter.
  - Lint rules: import sorting (`I`), unused imports (`F401`).
  - Formatting: replaces Black.
- **uv-sort** — sorts and organizes `pyproject.toml` dependency lists.
- **beautysh** — bash/shell script formatter (for any `.sh` files in the project).
- **mbake** — Makefile formatter (optional, if project has a Makefile).

## Installation

All formatter/linter tools should be installed as dev dependencies in `pyproject.toml`:

```toml
[dependency-groups]
dev = ["beautysh>=6.4.2", "mbake>=1.4.4", "ruff>=0.15.0", "uv-sort>=0.7.0"]
```

Create `scripts/install-formatter.sh` that ensures all formatting tools are available:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Ensure uv is available
if ! command -v uv &>/dev/null; then
    echo "uv not found. Installing..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
fi

# Sync dev dependencies (includes ruff, beautysh, uv-sort, mbake)
uv sync --group dev

echo "Formatter and linter tools installed successfully."
```

## tidy.sh

Create `tidy.sh` in the project root:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_CHECK="${1:-}"

# Lazy check for formatter installation
if [ "$SKIP_CHECK" != "--skip-check" ]; then
    if ! uv run ruff --version &>/dev/null; then
        echo "Formatters not found. Running install..."
        bash "$SCRIPT_DIR/scripts/install-formatter.sh"
    fi
fi

# Python: lint and fix
uv run ruff check --select I,F401 --fix .

# Python: format
uv run ruff format .

# Shell scripts: format (if any exist)
if ls scripts/*.sh &>/dev/null 2>&1; then
    uv run -m beautysh scripts/*.sh
fi

# Sort pyproject.toml dependencies
uv run uv-sort

# Format Makefile (if exists)
if [ -f "Makefile" ]; then
    uv run -m mbake format Makefile
fi

echo "Formatting complete."
```

## Ruff Configuration in pyproject.toml

```toml
[tool.ruff]
target-version = "py313"

[tool.ruff.lint]
extend-select = ["I"]

[tool.ruff.lint.isort]
known-first-party = ["<project_name>"]
```

## Makefile Integration

If a Makefile exists or a scaffolding is being created, ensure these targets are present:

```makefile
format: ## Run formatter and linter
	bash tidy.sh
tidy: format
```



# TypeScript Formatter & Linter Setup

Set up code formatting and linting for a TypeScript/React project.

## Tools

- **Prettier** — code formatter with Tailwind and import organization plugins.
- **ESLint v9+** — linter with TypeScript type-checked rules.

## Installation

Create `scripts/install-formatter.sh`:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

cd "$PROJECT_ROOT"

# Ensure pnpm is available
if ! command -v pnpm &>/dev/null; then
    echo "pnpm not found. Installing..."
    npm install -g pnpm
fi

# Install dev dependencies for formatting/linting
pnpm add -D \
    prettier \
    prettier-plugin-organize-imports \
    prettier-plugin-tailwindcss \
    eslint \
    @eslint/js \
    typescript-eslint \
    eslint-plugin-react-hooks \
    eslint-plugin-react-refresh \
    eslint-plugin-erasable-syntax-only \
    globals

echo "Formatter and linter tools installed successfully."
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

Reference template provided in `res/code/type_script/eslint.config.js`. This is an ESLint v9 flat config using:
- `typescript-eslint` with type-checked rules
- React hooks and refresh plugins
- Erasable syntax plugin
- Sensible default rule overrides (e.g., unused vars with `_` prefix ignored)

Copy the template and adjust `tsconfigRootDir` and `project` paths as needed.

## tidy.sh

Create `tidy.sh` in the project root:

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKIP_CHECK="${1:-}"

# Lazy check for formatter installation
if [ "$SKIP_CHECK" != "--skip-check" ]; then
    if ! pnpm exec prettier --version &>/dev/null 2>&1; then
        echo "Formatters not found. Running install..."
        bash "$SCRIPT_DIR/scripts/install-formatter.sh"
    fi
fi

# Run Prettier on all TS/TSX files
pnpm exec prettier --write "src/**/*.{ts,tsx}"

# Run ESLint with auto-fix
pnpm exec eslint --fix .

echo "Formatting complete."
```

## Makefile Integration

```makefile
format: ## Run formatter and linter
	bash tidy.sh
tidy: format
```



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

## `themes.ts`

```typescript
export default class Themes {
  public static isDarkMode(): boolean {
    return window.matchMedia("(prefers-color-scheme: dark)").matches;
  }

  //static primary = "#00FF00";
  static primary = "#007AFF";

  static readonly normalTransition = "all 0.3s ease-out";
  static readonly fastTransition = "all 0.1s ease-out";
  static readonly slowTransition = "all 0.5s ease-in-out";

  static rgbToHex(r: number, g: number, b: number) {
    return `#${r.toString(16).padStart(2, "0")}${g
      .toString(16)
      .padStart(2, "0")}${b.toString(16).padStart(2, "0")}`;
  }

  static getComplementaryColor(baseColor: string) {
    const { r, g, b } = this.hexToRgb(baseColor);
    const { h, s, l } = this.rgbToHsl(r, g, b);

    const newh = 180 - h;

    const { r: newR, g: newG, b: newB } = this.hslToRgb(newh, s, l);

    return this.rgbToHex(newR, newG, newB);
  }

  static light() {
    return {
      primary: Themes.primary,
      onPrimary: "#FFFFFF",
      primaryDark: Themes.getOffsetColor(Themes.primary, -0.1, -0.3),
      primaryContainer: Themes.getColorVariant(Themes.primary, undefined, 0.1),
      tertiary: Themes.getComplementaryColor(Themes.primary),
      canvas: "#f0f0f6",
      surface: "#FFFFFF",
      onSurface: "#000000",
      error: "#b3261e",
      warn: "#ff9500",
      good: "#137F0B",
      progressGood: "#6dbb53",
      progressWarn: "#f5d84f",
    };
  }

  static borderStyle() {
    return `1px solid ${Themes.hexToRgba(Themes.getCurrentTheme().onSurface, 0.2)}`;
  }

  static getCurrentTheme() {
    return Themes.isDarkMode() ? this.dark() : this.light();
  }

  static dark() {
    const primary = Themes.getOffsetColor(Themes.primary, 0, 0.3);

    return {
      ...Themes.light(),
      primary: primary,
      onPrimary: Themes.getOffsetColor(primary, -0.1, -0.4),
      primaryDark: Themes.getOffsetColor(primary, -0.1, -0.4),
      primaryContainer: Themes.getColorVariant(Themes.primary, undefined, 0.1),
      tertiary: Themes.getColorVariant(
        Themes.getComplementaryColor(Themes.primary),
        0.7,
        0.8,
      ),
      canvas: "#333947",
      surface: "#1f2530",
      onSurface: "#FFFFFF",
      error: Themes.getOffsetColor(Themes.light().error, 0, 0.3),
      warn: "#fcb44e",
      good: "#54ff6b",
      progressGood: "#80d763",
      progressWarn: "#f0db76",
    };
  }

  static hexToRgb(hex: string) {
    const [r, g, b] = hex
      .replace("#", "")
      .match(/\w\w/g)!
      .map((c) => parseInt(c, 16));
    return { r, g, b };
  }

  static darken(hex: string, amount: number) {
    const { r, g, b } = this.hexToRgb(hex);

    const out = `#${Math.round(r * (1 - amount))
      .toString(16)
      .padStart(2, "0")}${Math.round(g * (1 - amount))
      .toString(16)
      .padStart(2, "0")}${Math.round(b * (1 - amount))
      .toString(16)
      .padStart(2, "0")}`;
    return out;
  }

  static getOffsetColor(
    hex: string,
    saturationDiff: number,
    luminanceDiff: number,
  ) {
    const { r, g, b } = this.hexToRgb(hex);
    const { h, s, l } = this.rgbToHsl(r, g, b);

    let saturation = s / 100 + saturationDiff;
    let luminance = l / 100 + luminanceDiff;

    // Cap saturation to 0-1
    saturation = Math.min(Math.max(saturation, 0), 1);
    // Cap luminance to 0-1
    luminance = Math.min(Math.max(luminance, 0), 1);

    const {
      r: newR,
      g: newG,
      b: newB,
    } = this.hslToRgb(h, saturation * 100, luminance * 100);

    return `#${newR.toString(16).padStart(2, "0")}${newG
      .toString(16)
      .padStart(2, "0")}${newB.toString(16).padStart(2, "0")}`;
  }

  static getColorVariant(
    rgbHex: string,
    saturation?: number,
    luminance?: number,
  ) {
    const { r, g, b } = this.hexToRgb(rgbHex);
    const { h, s, l } = this.rgbToHsl(r, g, b);

    if (saturation === undefined) {
      saturation = s / 100;
    }
    if (luminance === undefined) {
      luminance = l / 100;
    }

    // Cap saturation to 0-1
    saturation = Math.min(Math.max(saturation, 0), 1);
    // Cap luminance to 0-1
    luminance = Math.min(Math.max(luminance, 0), 1);

    const {
      r: newR,
      g: newG,
      b: newB,
    } = this.hslToRgb(h, saturation * 100, luminance * 100);

    return `#${newR.toString(16).padStart(2, "0")}${newG
      .toString(16)
      .padStart(2, "0")}${newB.toString(16).padStart(2, "0")}`;
  }

  static rgbToHsl(
    r: number,
    g: number,
    b: number,
  ): { h: number; s: number; l: number } {
    // Normalize RGB values to 0-1 range
    r /= 255;
    g /= 255;
    b /= 255;

    const max = Math.max(r, g, b);
    const min = Math.min(r, g, b);
    let h = 0;
    let s = 0;
    const l = (max + min) / 2;

    if (max !== min) {
      const d = max - min;
      s = l > 0.5 ? d / (2 - max - min) : d / (max + min);

      switch (max) {
        case r:
          h = (g - b) / d + (g < b ? 6 : 0);
          break;
        case g:
          h = (b - r) / d + 2;
          break;
        case b:
          h = (r - g) / d + 4;
          break;
      }
      h /= 6;
    }

    return {
      h: Math.round(h * 360), // Hue in degrees (0-360)
      s: Math.round(s * 100), // Saturation in percentage (0-100)
      l: Math.round(l * 100), // Lightness in percentage (0-100)
    };
  }

  static hslToRgb(
    h: number,
    s: number,
    l: number,
  ): { r: number; g: number; b: number } {
    // Normalize HSL values
    h = h / 360; // Hue to 0-1 range
    s = s / 100; // Saturation to 0-1 range
    l = l / 100; // Lightness to 0-1 range

    let r, g, b;

    if (s === 0) {
      // Achromatic (gray)
      r = g = b = l;
    } else {
      const hue2rgb = (p: number, q: number, t: number) => {
        if (t < 0) t += 1;
        if (t > 1) t -= 1;
        if (t < 1 / 6) return p + (q - p) * 6 * t;
        if (t < 1 / 2) return q;
        if (t < 2 / 3) return p + (q - p) * (2 / 3 - t) * 6;
        return p;
      };

      const q = l < 0.5 ? l * (1 + s) : l + s - l * s;
      const p = 2 * l - q;

      r = hue2rgb(p, q, h + 1 / 3);
      g = hue2rgb(p, q, h);
      b = hue2rgb(p, q, h - 1 / 3);
    }

    return {
      r: Math.round(r * 255), // Red (0-255)
      g: Math.round(g * 255), // Green (0-255)
      b: Math.round(b * 255), // Blue (0-255)
    };
  }

  static hexToRgba(hex: string, alpha: number) {
    const { r, g, b } = this.hexToRgb(hex);

    return `rgba(${r}, ${g}, ${b}, ${alpha})`;
  }

  static stringToColor(str: string, saturation = 0.7, lightness = 0.7): string {
    let hash = 0;
    for (let i = 0; i < str.length; i++) {
      hash = str.charCodeAt(i) + ((hash << 5) - hash);
      hash = hash & hash;
    }
    const hue = Math.abs(hash % 360);
    const { r, g, b } = this.hslToRgb(hue, saturation * 100, lightness * 100);
    return this.rgbToHex(r, g, b);
  }

  static stringToReadableColor(str: string | null): string {
    const safeStr = str || "default";
    const baseColor = this.stringToColor(safeStr, 0.9, 0.4);
    if (this.isDarkMode()) {
      return this.getColorVariant(baseColor, undefined, 0.9);
    }
    return baseColor;
  }
}

```

## `style-sets.ts`

```typescript
export default class StyleSets {
  public static readonly BG_SURFACE_CONTAINER = "bg-current/5";

  public static readonly TRANSITION_STYLE =
    "transition-all duration-300 ease-in-out";

  public static readonly OUTLINE_BORDER_STYLE =
    "border-black/10 dark:border-white/10";

  public static readonly BUTTON_OUTLINE =
    "outline outline-0.5 outline-black/20 dark:outline-white/20 hover:outline-black/50 dark:hover:outline-white/50 " +
    StyleSets.TRANSITION_STYLE;

  public static readonly CLICK_SURFACE = `hover:bg-current/5 dark:hover:bg-white/15 ${StyleSets.TRANSITION_STYLE}`;

  public static readonly BUTTON_STYLE = `${StyleSets.BG_SURFACE_CONTAINER} p-4 rounded-xl ${StyleSets.BUTTON_OUTLINE} ${StyleSets.CLICK_SURFACE}`;
}

```

## `useThemeColors.ts`

```typescript
import { useThemeMode } from "./useThemeMode";
import Themes from "./themes";

export type ThemeColors = ReturnType<typeof Themes.light>;

/**
 * Returns the current theme colors based on system light/dark mode.
 * Uses useSyncExternalStore (matchMedia) internally—no Redux.
 */
export function useThemeColors(): {
  theme: ThemeColors;
  isDark: boolean;
  mode: "light" | "dark";
} {
  const mode = useThemeMode();
  const isDark = mode === "dark";
  const theme = isDark ? Themes.dark() : Themes.light();
  return { theme, isDark, mode };
}

```

## `useThemeMode.ts`

```typescript
import { useSyncExternalStore } from "react";

export type ThemeMode = "light" | "dark";

function subscribe(callback: () => void): () => void {
  if (typeof window === "undefined" || !window.matchMedia) return () => {};

  const mediaQuery = window.matchMedia("(prefers-color-scheme: dark)");

  if (typeof mediaQuery.addEventListener === "function") {
    mediaQuery.addEventListener("change", callback);
    return () => mediaQuery.removeEventListener("change", callback);
  }

  // Safari / older browsers
  // eslint-disable-next-line deprecation/deprecation
  mediaQuery.addListener(callback);
  // eslint-disable-next-line deprecation/deprecation
  return () => mediaQuery.removeListener(callback);
}

function getSnapshot(): ThemeMode {
  if (typeof window === "undefined" || !window.matchMedia) return "light";
  return window.matchMedia("(prefers-color-scheme: dark)").matches
    ? "dark"
    : "light";
}

function getServerSnapshot(): ThemeMode {
  return "light";
}

/**
 * Subscribes to system color-scheme (prefers-color-scheme) using React's
 * useSyncExternalStore. No Redux, minimal re-renders.
 */
export function useThemeMode(): ThemeMode {
  return useSyncExternalStore(subscribe, getSnapshot, getServerSnapshot);
}

```

## `eslint.config.js`

```javascript
import js from '@eslint/js';
import globals from 'globals';
import reactHooks from 'eslint-plugin-react-hooks';
import reactRefresh from 'eslint-plugin-react-refresh';
import tseslint from 'typescript-eslint';
import erasableSyntaxOnly from 'eslint-plugin-erasable-syntax-only';

export default tseslint.config(
  { ignores: ['dist', 'node_modules'] },
  {
    extends: [
      js.configs.recommended,
      ...tseslint.configs.recommendedTypeChecked,
      erasableSyntaxOnly.configs.recommended,
    ],
    files: ['**/*.{ts,tsx}'],
    languageOptions: {
      ecmaVersion: 2020,
      globals: globals.browser,
      parserOptions: {
        project: ['./tsconfig.app.json', './tsconfig.node.json'],
        tsconfigRootDir: import.meta.dirname,
      },
    },
    plugins: {
      'react-hooks': reactHooks,
      'react-refresh': reactRefresh,
    },
    rules: {
      ...tseslint.configs.eslintRecommended.rules,
      ...tseslint.configs.recommended.rules,
      'react-refresh/only-export-components': [
        'warn',
        { allowConstantExport: true },
      ],
      'no-unused-vars': 'off',
      '@typescript-eslint/require-await': 'off',
      '@typescript-eslint/no-floating-promises': 'off',
      '@typescript-eslint/no-misused-promises': 'off',
      '@typescript-eslint/no-unsafe-assignment': 'off',
      '@typescript-eslint/no-unsafe-member-access': 'warn',
      '@typescript-eslint/no-unsafe-call': 'warn',
      '@typescript-eslint/no-unsafe-return': 'warn',
      '@typescript-eslint/no-unsafe-argument': 'warn',
      '@typescript-eslint/no-explicit-any': 'warn',
      '@typescript-eslint/no-unused-vars': [
        'error',
        { argsIgnorePattern: '^_', caughtErrorsIgnorePattern: '^error$' },
      ],
      '@typescript-eslint/restrict-template-expressions': 'off',
      '@typescript-eslint/ban-ts-comment': 'off',
      '@typescript-eslint/no-unsafe-enum-comparison': 'warn',
      '@typescript-eslint/no-redundant-type-constituents': 'warn',
      '@typescript-eslint/no-empty-object-type': 'off',
      'erasable-syntax-only/enums': 'off',
      'no-useless-catch': 'off',
      'react-hooks/exhaustive-deps': 'off',
    },
  }
);

```

## `.prettierrc`

```
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

## `.prettierignore`

```
package-lock.json
pnpm-lock.yaml
node_modules

```

---

## Completion Checklist

- [ ] All requested features implemented.
- [ ] Formatter configured and run.
- [ ] Tests written and passing.
- [ ] Build succeeds.
- [ ] README generated.
- [ ] Project runs end-to-end.
