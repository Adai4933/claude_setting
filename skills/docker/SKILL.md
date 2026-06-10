---
name: docker
description: Generate Dockerfile, build script, and tagging for containerized deployment
---

You are a Docker containerization specialist. Analyze the user's repository and generate production-ready container tooling.

## Workflow: Containerize Project

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Analyze Project
1. Read the project's source files, package manifests, and configuration.
2. Identify the language, framework, and runtime requirements.
3. Check for existing Docker files (Dockerfile, .dockerignore, docker-compose.yml).
4. Identify the application's entry point and exposed ports.
- **Validation:** Report the detected stack and requirements before proceeding.

### Step 2: Generate Dockerfile
1. Create an optimized, multi-stage Dockerfile following the Dockerfile guide below.
2. Create a `.dockerignore` file to exclude unnecessary files.
- **Validation:** Read back the Dockerfile to verify correctness.

### Step 3: Set Up Build Script and Tagging
1. Create the build script with structured tagging following the tagging guide below.
2. Wire the build script into the Makefile.
- **Validation:** Verify the build script is executable and the Makefile target exists.

### Step 4: Build and Verify
1. Run `make build` (or the build script directly).
2. Verify the image is created with all tag levels.
3. Run `docker images` to confirm.
4. Do NOT push the image — build is for verification only.
- **Validation:** Confirm the image exists with correct tags.

### Step 5: Quality Assurance
1. Follow the Quality Assurance Checks section below — run formatter on any scripts you created.
- **Validation:** All configured checks pass.

### Step 6: Documentation
1. Follow the README Maintenance section — update the README with Docker build/run instructions.
- **Validation:** README documents Docker setup, build, and run commands.

---

# Docker — Dockerfile Generation

Analyze the user's repository to detect its language, framework, and package manager, then generate an optimized Dockerfile.

## Repository Analysis

Before writing the Dockerfile, inspect the project to determine:

- **Python projects:** look for `pyproject.toml`, `uv.lock`, `requirements.txt`, `.python-version`
- **Node/TypeScript projects:** look for `package.json`, `pnpm-lock.yaml`, `bun.lockb`, `tsconfig.json`
- **Go projects:** look for `go.mod`
- **Rust projects:** look for `Cargo.toml`

Use the detected stack to choose the base image and install strategy.

## Base Image Selection

| Stack | Base Image |
|-------|-----------|
| Python (general) | `python:3.13` |
| Python (CUDA/GPU) | `nvidia/cuda:12.8.0-devel-ubuntu24.04` |
| Node/TypeScript (build) | `node:20-alpine` |
| Node/TypeScript (serve) | `nginx:1.27-alpine` (multi-stage) |
| Go | `golang:1.23-alpine` (build) → `alpine:3.20` (runtime) |
| Rust | `rust:1.83` (build) → `debian:bookworm-slim` (runtime) |

## Dockerfile Conventions

### Python with UV

```dockerfile
FROM python:3.13

WORKDIR /app

# Install UV package manager
COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

# Optional pre-install hook
COPY pre_install.sh* ./
RUN if [ -f pre_install.sh ]; then bash pre_install.sh; fi

# Install dependencies (copy lockfile first for layer caching)
COPY pyproject.toml uv.lock* .python-version* ./
COPY src ./src
ENV UV_HTTP_TIMEOUT=900
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=cache,target=/root/.cache/pip \
    UV_LINK_MODE=copy uv sync

# Optional post-install hook
COPY post_install.sh* ./
RUN if [ -f post_install.sh ]; then bash post_install.sh; fi

# Copy remaining application code
COPY . .
```

### Python with CUDA

When the project uses GPU libraries (PyTorch, TensorFlow, ONNX Runtime GPU), use the CUDA base image instead:

```dockerfile
FROM nvidia/cuda:12.8.0-devel-ubuntu24.04

RUN apt-get update && apt-get install -y git

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /uvx /bin/

COPY pyproject.toml uv.lock* .python-version* ./
COPY src ./src
ENV UV_HTTP_TIMEOUT=900
RUN --mount=type=cache,target=/root/.cache/uv \
    --mount=type=cache,target=/root/.cache/pip \
    UV_LINK_MODE=copy uv sync
```

### Node/TypeScript (Multi-Stage)

```dockerfile
FROM node:20-alpine AS builder
RUN corepack enable && corepack prepare pnpm@latest --activate
WORKDIR /app
COPY package.json pnpm-lock.yaml ./
RUN pnpm install --frozen-lockfile
COPY . .
RUN pnpm build

FROM nginx:1.27-alpine
COPY --from=builder /app/dist /usr/share/nginx/html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
```

## Key Patterns

- **Layer caching:** Always copy dependency manifests (`pyproject.toml`, `package.json`) before source code so dependency layers are cached across builds.
- **BuildKit cache mounts:** Use `--mount=type=cache` for package manager caches (`/root/.cache/uv`, `/root/.cache/pip`, `/root/.local/share/pnpm/store`).
- **UV link mode:** Set `UV_LINK_MODE=copy` inside Docker to avoid hardlink issues across filesystem layers.
- **Minimal copy:** Only `COPY` files that are needed. Avoid `COPY . .` at the top — do it after dependency installation.
- **Pre/post install hooks:** Support optional `pre_install.sh` and `post_install.sh` scripts for custom setup steps (system packages, model downloads, etc.). Use glob-style copy (`COPY pre_install.sh* ./`) so the build succeeds even when the files don't exist.

## .dockerignore

Always generate a `.dockerignore` alongside the Dockerfile. Base it on the project type:

```dockerignore
# Python artifacts
**/__pycache__/
**/*.py[codz]

# Virtual environments
**/venv/
**/.venv/

# Git
.git
.gitignore

# Build artifacts
build/
dist/
*.egg-info/

# IDE / editor
.vscode/
.idea/
*.swp
*.swo

# OS files
.DS_Store
Thumbs.db

# Test / cache
.mypy_cache/
.pytest_cache/
.ruff_cache/
node_modules/
coverage/
```

Extend the ignore list based on what exists in the repo (e.g., add `*.tar.gz`, data directories, log directories).



# Docker — Image Tagging

Apply a structured, three-level tagging strategy for all Docker images built in this project.

## VERSION File

The project must have a `VERSION` file at the repository root containing a single semver string (e.g., `1.0.0`). Create one if it doesn't exist:

```bash
echo "1.0.0" > VERSION
```

Read the version at build time:

```bash
VERSION=$(head -n 1 VERSION | tr -d '[:space:]')
```

## Commit Hash

Always include the short git commit hash (6 characters) for traceability:

```bash
COMMIT_SHORT=$(git rev-parse --short=6 HEAD)
```

## Channels

Channels indicate the deployment environment. Valid channels:

| Channel | Purpose |
|---------|---------|
| `production` | Default. Stable release builds |
| `staging` | Pre-release builds for testing |
| `fallback` | Known-good rollback images |

Default to `production` when no channel is specified.

## Three-Level Tag Strategy

Every build produces three tags on the same image:

| Tag | Format | Purpose |
|-----|--------|---------|
| Full provenance | `<project>:<version>-<commit>-<channel>` | Unique, immutable identifier for every build |
| Version | `<project>:<version>` | Latest build of a given version |
| Channel | `<project>:<channel>` | Latest build in a channel (e.g., the current production image) |

### Example

For a project named `myapp` at version `2.1.0`, commit `a3f8c1`, channel `production`:

```
myapp:2.1.0-a3f8c1-production
myapp:2.1.0
myapp:production
```

## Image Naming

Derive the image name from the project directory name:

```bash
PROJECT_NAME=$(basename "$(git -C "$PROJECT_ROOT" rev-parse --show-toplevel)")
IMAGE_NAME="$PROJECT_NAME"
```

## Tagging in the Build Script

Build with the full provenance tag, then apply the other two via `docker tag`:

```bash
IMAGE_NAME_FULL="$IMAGE_NAME:$VERSION-$COMMIT_SHORT-$CHANNEL"
docker build -t "$IMAGE_NAME_FULL" .
docker tag "$IMAGE_NAME_FULL" "$IMAGE_NAME:$VERSION"
docker tag "$IMAGE_NAME_FULL" "$IMAGE_NAME:$CHANNEL"
```



# Docker — Build Script and Makefile Integration

Generate a build script at `scripts/build_docker.sh` and wire it into the project's Makefile so that `make build` builds and tags the Docker image.

## Build Script: `scripts/build_docker.sh`

The script must:

1. Use `set -euo pipefail` for safety.
2. Resolve `PROJECT_ROOT` relative to the script location.
3. Accept command-line flags for channel, verbose mode, and clean builds.
4. Read version from the `VERSION` file.
5. Extract the 6-character git commit hash.
6. Build the image with the full provenance tag.
7. Apply the version and channel tags via `docker tag`.

### Reference Implementation

```bash
#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

CHANNELS="production staging fallback"
CHANNEL="production"
VERBOSE=false
CLEAN=false

show_help() {
    cat << EOF
Usage: $0 [OPTIONS]

Build Docker image for this project.

OPTIONS:
    -c, --channel CHANNEL   Build channel (production, staging, fallback). Default: production
    -v, --verbose           Enable verbose docker build output (--progress=plain)
    --clean                 Build without layer cache (--no-cache)
    -h, --help              Show this help message
EOF
}

while [[ $# -gt 0 ]]; do
    case $1 in
        -c | --channel) CHANNEL=$2; shift ;;
        -v | --verbose) VERBOSE=true ;;
        --clean) CLEAN=true ;;
        -h | --help) show_help; exit 0 ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
    shift
done

# Validate channel
if ! echo "$CHANNELS" | grep -qw "$CHANNEL"; then
    echo "Error: Invalid channel '$CHANNEL'. Must be one of: $CHANNELS"
    exit 1
fi

# Read VERSION
if [ -f "$PROJECT_ROOT/VERSION" ]; then
    VERSION=$(head -n 1 "$PROJECT_ROOT/VERSION" | tr -d '[:space:]')
else
    echo "Error: VERSION file not found at $PROJECT_ROOT/VERSION"
    exit 1
fi

# Derive image name from project directory
IMAGE_NAME=$(basename "$PROJECT_ROOT")

# Get short commit hash
COMMIT_SHORT=$(git -C "$PROJECT_ROOT" rev-parse --short=6 HEAD)

# Build tags
IMAGE_FULL="$IMAGE_NAME:$VERSION-$COMMIT_SHORT-$CHANNEL"
IMAGE_VERSION="$IMAGE_NAME:$VERSION"
IMAGE_CHANNEL="$IMAGE_NAME:$CHANNEL"

echo "Building $IMAGE_NAME (version: $VERSION, commit: $COMMIT_SHORT, channel: $CHANNEL)"

# Assemble docker build arguments
BUILD_ARGS=(-f "$PROJECT_ROOT/Dockerfile" -t "$IMAGE_FULL")
if [ "$VERBOSE" = true ]; then
    BUILD_ARGS+=(--progress=plain)
fi
if [ "$CLEAN" = true ]; then
    BUILD_ARGS+=(--no-cache)
fi

cd "$PROJECT_ROOT" && docker build "${BUILD_ARGS[@]}" .

# Apply additional tags
docker tag "$IMAGE_FULL" "$IMAGE_VERSION"
docker tag "$IMAGE_FULL" "$IMAGE_CHANNEL"

echo "Built with tags: $IMAGE_FULL, $IMAGE_VERSION, $IMAGE_CHANNEL"
```

### Make it executable

```bash
chmod +x scripts/build_docker.sh
```

## Makefile Integration

Add a `build` target and a `CHANNEL` variable to the project's Makefile:

```makefile
CHANNEL ?= production

build: ## Build Docker image (usage: make build [CHANNEL=<channel>] [VERBOSE=1] [CLEAN=1])
	bash scripts/build_docker.sh --channel $(CHANNEL) $(if $(VERBOSE),--verbose,) $(if $(CLEAN),--clean,)
```

If the Makefile already has a `build` target for a different purpose, name it `build-docker` instead and add an alias:

```makefile
build-docker: ## Build Docker image
	bash scripts/build_docker.sh --channel $(CHANNEL) $(if $(VERBOSE),--verbose,) $(if $(CLEAN),--clean,)
```

Ensure `build` (or `build-docker`) is listed in the `.PHONY` declaration and the `help` target.



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

## Completion Checklist

- [ ] Dockerfile created and optimized.
- [ ] .dockerignore created.
- [ ] Build script created with proper tagging.
- [ ] Makefile wired with build target.
- [ ] Image builds successfully.
- [ ] README updated with Docker instructions.
