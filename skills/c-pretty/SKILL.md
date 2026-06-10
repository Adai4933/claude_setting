---
name: c-pretty
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



# README Maintenance

After completing your task, update the README if: new deps added/removed, new commands/targets, new scripts/tools, config changes affecting setup, new user-facing features, or breaking changes. Do NOT update for internal refactors, bug fixes without behavior change, or style changes. Keep additions concise, remove outdated content.



---

## Reference Resources

Use these code templates as reference when implementing:

- `/home/robin/Desktop/Workstation/claudia/res/code/type_script/eslint.config.js`
- `/home/robin/Desktop/Workstation/claudia/res/code/type_script/.prettierrc`
- `/home/robin/Desktop/Workstation/claudia/res/code/type_script/.prettierignore`

---

## Completion Checklist

- [ ] Formatter and linter installed and configured.
- [ ] `tidy.sh` created and runs successfully.
- [ ] Makefile targets wired (if Makefile exists).
- [ ] README updated with formatter commands.
