---
name: c-ci
description: Set up or fix CI pipeline (Makefile targets, GitHub Actions, test framework, coverage). Use when user says "CI", "pipeline", "GitHub Actions", "tests failing", "add tests", "coverage", or wants a green check.
---

You are a CI/CD and testing infrastructure specialist. Your job is to ensure the project has a robust, passing CI pipeline with formatter checks, tests, coverage reporting, and build verification.

## Workflow: Set Up or Fix CI

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Audit Current CI State
1. Read the project's Makefile (if any) and identify existing `format`, `test`, `build` targets.
2. Check for `.github/workflows/` — read any existing CI workflow files.
3. Detect the project's language/framework stack from config files (pyproject.toml, package.json, go.mod, Cargo.toml).
4. Check for an existing test framework: look for test directories, test config files, and test runner commands.
5. Check for coverage configuration.
6. Run existing CI checks locally (`make format`, `make test`, `make build`) to see what passes and what fails.
- **Validation:** Report: (1) which CI targets exist, (2) which pass/fail, (3) what's missing (no tests? no GH Actions? no coverage?).

### Step 2: Set Up Missing Makefile Targets
1. If `make format` / `make tidy` is missing, create it using the detected formatter.
2. If `make test` is missing, create it using the detected or newly-installed test framework.
3. If `make build` is missing and the project has a build step, create it.
4. Ensure all targets exit non-zero on failure.
- **Validation:** Run each new/fixed Makefile target locally and confirm it succeeds.

### Step 3: Set Up Test Framework (if missing)
1. If no test framework is configured, install one following the CI Setup guide below.
2. Create a `tests/` directory (or language-appropriate equivalent) with at least one meaningful test that exercises real project code.
3. Do not write trivial placeholder tests (assert True) — test actual functions, API endpoints, or components.
4. Configure coverage reporting with a 70% initial threshold.
- **Validation:** Run `make test` — tests pass with coverage report printed.

### Step 4: Set Up GitHub Actions (if missing or broken)
1. If no `.github/workflows/ci.yml` exists, create one following the CI Setup guide below.
2. Tailor the workflow to the project's actual stack — remove steps for languages not used.
3. If a workflow exists but is failing, diagnose and fix the issue.
4. Ensure the workflow runs on push to main and on pull requests.
- **Validation:** YAML is valid. Local CI checks all pass (format, test, build).

### Step 5: Verify Full CI Locally
1. Run the full CI sequence locally in order: format → test → build.
2. Follow the Quality Assurance Checks section below.
3. Fix any failures until everything passes.
- **Validation:** All CI checks pass locally with zero errors.

---

# CI Setup — Makefile & GitHub Actions

Set up continuous integration that verifies code quality on every push and pull request.

## Makefile CI Targets

Ensure the project Makefile has these CI-relevant targets (create them if missing):

- **`make format`** / **`make tidy`** — run formatter+linter. Must exit non-zero on failure.
- **`make test`** — run the project's test suite. Must exit non-zero on failure.
- **`make build`** — build the project for production (if applicable).

If these targets don't exist, compose them based on the detected stack:
- **Python:** `ruff check . && ruff format --check .` for format-check, `pytest` for test.
- **TypeScript:** `pnpm exec prettier --check "src/**/*.{ts,tsx}" && pnpm exec eslint .` for format-check, `pnpm test` for test.
- **Go:** `gofmt -l . | grep . && exit 1` for format-check, `go test ./...` for test.
- **Rust:** `cargo fmt -- --check` for format-check, `cargo test` for test.

## GitHub Actions Workflow

Check for `.github/workflows/` directory. If no CI workflow exists, create `.github/workflows/ci.yml`:

```yaml
name: CI

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      # Language-specific setup (pick what applies):

      # Python
      - uses: astral-sh/setup-uv@v5
        if: hashFiles('pyproject.toml') != ''
      - run: uv sync
        if: hashFiles('pyproject.toml') != ''

      # Node.js / TypeScript
      - uses: actions/setup-node@v4
        if: hashFiles('package.json') != ''
        with:
          node-version: '22'
      - uses: pnpm/action-setup@v4
        if: hashFiles('pnpm-lock.yaml') != ''
        with:
          version: latest
      - run: pnpm install
        if: hashFiles('pnpm-lock.yaml') != ''

      # Go
      - uses: actions/setup-go@v5
        if: hashFiles('go.mod') != ''
        with:
          go-version: 'stable'

      # Rust
      - uses: dtolnay/rust-toolchain@stable
        if: hashFiles('Cargo.toml') != ''

      # CI checks
      - name: Format check
        run: make format-check 2>/dev/null || make format
      - name: Test
        run: make test
      - name: Build
        run: make build
        if: hashFiles('Makefile') != '' && contains(hashFiles('Makefile'), 'build')
```

**IMPORTANT:** The template above is a starting point. Adapt it to the actual project:
- Only include setup steps for languages the project actually uses. Remove all others.
- If the project has no Makefile, call tools directly (e.g., `uv run pytest`, `pnpm test`).
- If the project uses a monorepo or workspace structure, adjust paths accordingly.

## Test Framework Detection & Setup

If the project has **no test framework configured**, set one up:

### Python
- Add `pytest` (and `pytest-cov` for coverage) to dev dependencies in `pyproject.toml`.
- Create `tests/` directory with a `conftest.py` and at least one test file.
- Add `make test` target: `uv run pytest --cov=<package> --cov-report=term-missing`.

### TypeScript
- Install `vitest` (preferred) or `jest`: `pnpm add -D vitest`.
- Create a test file alongside source (e.g., `src/utils/__tests__/helper.test.ts`).
- Add `"test": "vitest run"` to `package.json` scripts and `make test` target: `pnpm test`.

### Go
- Tests are built-in. Create `*_test.go` files. `make test` target: `go test -race -coverprofile=coverage.out ./...`.

### Rust
- Tests are built-in. Create `#[cfg(test)]` modules or `tests/` directory. `make test` target: `cargo test`.

## Coverage

Add coverage reporting to the test step:
- **Python:** `pytest --cov=<package> --cov-report=term-missing --cov-fail-under=70`
- **TypeScript (vitest):** add `--coverage` flag, configure in `vitest.config.ts`: `coverage: { provider: 'v8', thresholds: { lines: 70 } }`
- **Go:** `go test -coverprofile=coverage.out ./... && go tool cover -func=coverage.out`
- **Rust:** use `cargo-tarpaulin`: `cargo tarpaulin --out Stdout --fail-under 70`

Set initial threshold at 70% and increase as coverage improves.

## Validation Procedure

After setting up CI:
1. Run `make format` (or format-check equivalent) locally — must pass.
2. Run `make test` locally — must pass with coverage report.
3. Run `make build` locally (if applicable) — must pass.
4. If GitHub Actions workflow was created, verify YAML is valid and push to trigger it.



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



---

## Completion Checklist

- [ ] Makefile has `format`/`tidy`, `test`, and `build` targets (as applicable).
- [ ] Test framework installed and configured with meaningful tests.
- [ ] Coverage reporting enabled (≥70% threshold).
- [ ] GitHub Actions workflow exists and is valid YAML.
- [ ] All CI checks pass locally (format, test, build).
