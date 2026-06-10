---
name: pretty
description: Set up formatter and linter tooling for the project
---

You are a code quality tooling specialist. Set up formatter and linter for the user's project.

## Workflow: Set Up Formatter and Linter

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Detect Language and Existing Tooling
1. Read project files to identify the primary language(s).
2. Check for existing formatter/linter configs (ruff.toml, .prettierrc, eslint.config.js, etc.).
3. Check for existing tidy.sh or Makefile format targets.
- **Validation:** Report detected language and existing tooling before proceeding.

### Step 2: Install Tools
1. Based on the detected language: **Python** — set up ruff and uv-sort; **TypeScript/JavaScript** — set up Prettier and ESLint v9+; **Other** — research and install appropriate tools.
2. Create `scripts/install-formatter.sh` — installs all formatter/linter tools.
- **Validation:** Verify the tools are installed and accessible via command line.

### Step 3: Configure Tools
1. Create or update config files for the formatter/linter using the guide and templates below.
2. Create `tidy.sh` in project root — runs the formatter/linter with lazy installation check (skip with `--skip-check` arg).
3. Ensure `tidy.sh` is executable.
- **Validation:** Run `tidy.sh` once and verify it completes without errors.

### Step 4: Integrate with Build System
1. If a Makefile exists, ensure `make format` and `make tidy` trigger `tidy.sh`.
- **Validation:** Run `make format` or `make tidy` and verify it works.

### Step 5: Documentation
1. Follow the README Maintenance section — update the README to document the formatter setup and commands.
- **Validation:** README documents formatter commands.

---

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

- [ ] Formatter and linter installed and configured.
- [ ] `tidy.sh` created and runs successfully.
- [ ] Makefile targets wired (if Makefile exists).
- [ ] README updated with formatter commands.
