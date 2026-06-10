---
name: c-brainstorm
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



# UI & Design Language Guidelines

Default design language: **Material Design 3 (Material You)**. Ask the user if not specified.

---

## Material Design 3 (Material You) — DEFAULT

- **Dynamic color:** Derive full scheme from one seed color via HCT tonal palettes (primary, secondary, tertiary, neutral, error). Use provided `themes.ts`.
- **Tonal surfaces:** Use `bg-primary/N` (N=1,2,5,8,11,14) for elevation levels 0–5 instead of box-shadow.
- **Shape scale:** None=`rounded-none`, XS=`rounded`(4dp), S=`rounded-md`(8dp), M=`rounded-lg`(12dp), L=`rounded-xl`(16dp), XL=`rounded-2xl`(28dp), Full=`rounded-full`.
- **Typography:** M3 type scale — display/headline/title/body/label × lg/md/sm. Map to Tailwind `text-*` + `font-*`.
- **Surface containers:** Tonal fills (`bg-current/5`, `/8`, `/12`). Ref: `StyleSets.BG_SURFACE_CONTAINER`.
- **State layers:** hover=`bg-current/8`, focus/pressed=`/12`, dragged=`/16`.
- **Buttons:** Filled (primary bg, onPrimary text, rounded-full) | Tonal (secondaryContainer) | Outlined (1px outline) | Text (primary color). Ref: `StyleSets.BUTTON_STYLE`.
- **Cards:** Tonal fill, rounded-lg, no shadow. Outlined variant: 1px `outline-variant` border.
- **Navigation:** Rail (desktop) / bottom bar (mobile), pill-shaped active indicator with secondaryContainer fill.
- **FAB:** rounded-xl to rounded-2xl, primaryContainer fill.
- **Motion:** Emphasized=`cubic-bezier(0.2,0,0,1)`, decel=`(0.05,0.7,0.1,1)`, accel=`(0.3,0,0.8,0.15)`. Durations: short1–4=50–200ms, medium1–4=250–400ms, long1–4=450–600ms, extra-long1=700ms. Container transforms: medium4 (400ms) + emphasized.

---

## Apple Morphed Glass (Glassmorphism / visionOS)

**Before implementing:** Use WebFetch to read latest Apple HIG at `https://developer.apple.com/design/human-interface-guidelines` (Materials, Motion, Color, Typography, Layout sections).

- **Frosted glass:** `backdrop-blur-xl` + `bg-white/60 dark:bg-white/10` on every card/modal/elevated surface.
- **Vibrancy levels:** Ultra-thin=`blur-sm bg-white/30 dark:bg-white/5`, Thin=`blur-md /40 /8`, Regular=`blur-xl /60 /12`, Thick=`blur-2xl /70 /18`.
- **Specular borders:** `border border-white/30 dark:border-white/10`.
- **Shape:** Superellipse corners — `rounded-2xl`(24dp) cards, `rounded-3xl`(32dp) modals, `rounded-full` pills.
- **Color:** Muted/desaturated. Accent=`#007AFF`. Text: `text-black/85 dark:text-white/85` primary, `/50` secondary.
- **Components:** Cards=frosted glass+specular border. Nav bars=full-width `blur-xl bg-white/70 dark:bg-black/50`. Modals=`blur-2xl`, rounded-3xl, spring anim. Buttons: Primary=solid accent, rounded-xl, scale-down press; Secondary=frosted glass+border. Lists=grouped rounded-2xl, inset separators `border-black/5 dark:border-white/5`.
- **Motion:** Spring default: `all 0.5s cubic-bezier(0.2,0.8,0.2,1)`. Press=scale-95 200ms. Sheet=slide-up `cubic-bezier(0.32,0.72,0,1)` 500ms. Hero=400-600ms. Parallax=50% scroll speed. Hover=`scale-[1.02]`.

---

## Material Design 2

- **Elevation via shadows:** 0dp=none, 1dp=`shadow-sm`, 2dp=`shadow`, 4dp=`shadow-md`, 6dp=`shadow-lg`, 8dp=`shadow-lg`, 12dp=`shadow-xl`, 16dp=`shadow-xl`, 24dp=`shadow-2xl`.
- **Shape:** Small components=`rounded`(4dp), Medium=`rounded`–`rounded-md`(4-8dp), Large=`rounded-none`–`rounded`(0-4dp).
- **Color:** Fixed primary/secondary palette, no dynamic color. Surfaces: white/#121212 dark + `bg-white/5` per elevation level. Roboto font.
- **Components:** Cards=white/dark, rounded-sm, shadow. App bar=solid primary, 4dp shadow. Buttons: Contained=primary bg, 2dp shadow, 6dp hover; Outlined=1px primary border; Text=uppercase primary. FAB=rounded-full/rounded-lg, secondary, 6dp. Dialogs=rounded(4dp), 24dp shadow, `bg-black/32` scrim.
- **Motion:** Standard=`(0.4,0,0.2,1)`, decel=`(0,0,0.2,1)`, accel=`(0.4,0,1,1)`, sharp=`(0.4,0,0.6,1)`. Enter=225ms, exit=195ms, complex≤375ms.

---

## Microsoft Fluent Design 2

- **Acrylic:** `backdrop-blur-xl bg-white/70 dark:bg-neutral-800/70` + noise texture.
- **Mica:** `bg-gray-50/95 dark:bg-neutral-900/95` (samples wallpaper ambient color).
- **Reveal highlight:** Radial gradient at cursor on hover.
- **Shape:** Controls=`rounded`(4dp), Cards=`rounded-lg`(8dp), Dialogs=`rounded-xl`(12dp).
- **Color:** System accent, neutral surfaces. Text: `text-black/90 dark:text-white/90` primary, `/60` secondary. Segoe UI Variable.
- **Typography:** caption=12px, body=14px, body-strong=14px semi, subtitle=20px semi, title=28px semi, title-large=40px semi, display=68px semi.
- **Components:** Cards=mica/acrylic, rounded-lg, 1px border `border-black/5 dark:border-white/8`. NavigationView=acrylic pane, pill active indicator. Buttons: Accent=accent bg, rounded(4dp); Standard=`bg-white/70 dark:bg-white/5`, 1px border; Subtle=transparent, `hover:bg-black/5`; Hyperlink=accent text. Dialogs=mica/acrylic, rounded-lg, scale-in. InfoBar=severity colors (info/success/warning/error), rounded-md.
- **Motion:** Default=`cubic-bezier(0.1,0.9,0.2,1)`. Fast=83ms, Normal=167ms, Slow=250ms. Enter=fade+slide-up 4-8px. Exit=fade+slide-down. Connected=250-400ms. Drill-in=outgoing fades+scales, incoming slides+fades.

---

## Color System & Theming (All Languages)

Use provided theming system from `res/code/type_script/`: **themes.ts** (color system, HSL, light/dark), **style-sets.ts** (Tailwind presets), **useThemeColors.ts** (React hook: `{ theme, isDark, mode }`), **useThemeMode.ts** (`useSyncExternalStore` theme detection). Copy to `src/utils/` and `src/hooks/`. Support light+dark via `prefers-color-scheme`. Extend `themes.ts` for additional tonal tokens as needed.

---

## Accessibility (WCAG 2.1 AA + AAA Targets)

- **Contrast:** Normal text ≥4.5:1 (AA), target ≥7:1 (AAA). Large text ≥3:1 (AA), target ≥4.5:1 (AAA). UI components ≥3:1. Never rely on color alone — pair with text/icons/patterns.
- **Focus/keyboard:** Every interactive element needs visible focus indicator (`focus-visible:ring-2 ring-offset-2 ring-primary`, ≥3:1 contrast). All functionality keyboard-reachable (Tab, Shift+Tab, Enter, Space, Escape, Arrows). Logical tab order, `tabindex="0"` for custom elements, never positive tabindex. Include "Skip to main content" link.
- **ARIA:** Semantic HTML first (`<button>`, `<nav>`, `<main>`, `<dialog>`), ARIA second. All `<img>` need `alt` (or `alt=""` + `aria-hidden="true"`). Dynamic content via `aria-live` (`polite`/`assertive`). Modals trap focus, return on close. Form inputs need `<label>` or `aria-label`.
- **Motion:** Wrap ALL animations in `prefers-reduced-motion` check. Tailwind: `motion-safe:` / `motion-reduce:`. JS: check `matchMedia`. Reduced motion → instant or ≤100ms opacity fades. No >3 flashes/sec.
- **Touch:** Targets ≥44×44px (WCAG) / 48×48dp (Material). ≥8dp gap between targets.

---

## Animation & Motion System

**Transition hierarchy:** Micro (50–200ms, button/hover/toggles, ease-out) → Component (200–400ms, cards/dropdowns/tabs, standard easing) → Page/route (300–600ms, view changes, emphasized easing, animate enter+exit) → Hero/shared-element (400–800ms, persisting elements, animate position/size/shape).

**Hero animations:** Use for list→detail, thumbnail→fullscreen, card→page, FAB→dialog. React: `layoutId` (Framer Motion) or `view-transition-name` CSS. Libraries: Framer Motion (first), CSS View Transitions API, React Transition Group + FLIP. **Page transitions:** Never instant. Enter=fade+slide from nav direction (300–500ms). Exit=fade+opposite (200–400ms). Crossfade unrelated (300ms). Use `AnimatePresence`. **Loading:** Skeleton placeholders with shimmer sweep, stagger 50ms, crossfade to content (200ms). **Scroll:** Parallax bg at 50–70% speed. Reveal-on-scroll: fade+slide-up 16–24px, IntersectionObserver, 50ms stagger. Sticky header morph on threshold (200ms). **Gestures:** Swipe-to-dismiss with edge resistance/spring-back. Pull-to-refresh rubber-band. Drag-reorder with lift, 200ms reflow. **Stagger:** 30–60ms between elements, cap ≤400ms total.

---

## Responsive Layout

Mobile-first. Breakpoints: default(<640px), sm(640), md(768), lg(1024), xl(1280), 2xl(1536, max-w ~1280px). Nav: mobile=bottom bar (3–5 items), desktop=sidebar/rail, swap `md:hidden`/`hidden md:flex`. Grid: `grid-cols-1`→`md:2`→`lg:3/4`, gap `gap-4`→`md:gap-6`. Typography: body ≥16px, headlines `text-xl`→`md:text-3xl`. Touch: mobile=48dp targets+swipe, desktop=hover+36dp min (`@media (hover:hover)`). Containers: `max-w-screen-xl mx-auto px-4 sm:px-6 lg:px-8`. Images: `w-full`+`aspect-ratio`, `<picture>`+`srcset`, lazy-load. Tables: mobile=card layout/`overflow-x-auto`. Modals: mobile=full-screen/bottom-sheet, desktop=centered 480–640px. Forms: mobile=single-col, desktop=multi-col. Test at: 375/390/768/1024/1440px. No horizontal overflow.

---

## UI Checklist

- [ ] Design language consistent (default: M3), light+dark mode correct
- [ ] WCAG 2.1 AA contrast (4.5:1 text, 3:1 UI), visible focus indicators, keyboard-accessible
- [ ] `prefers-reduced-motion` respected, touch targets ≥44×44px
- [ ] Page transitions animate, hero animations for persisting elements, skeleton loading with shimmer
- [ ] Staggered list/grid entrances, semantic HTML + ARIA
- [ ] Responsive (375px/768px/1440px), nav adapts, no horizontal overflow



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

### `data_model.py`

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

### `themes.ts`

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

### `style-sets.ts`

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

### `useThemeColors.ts`

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

### `useThemeMode.ts`

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

### `eslint.config.js`

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

### `.prettierrc`

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

### `.prettierignore`

```
package-lock.json
pnpm-lock.yaml
node_modules
```

### `browser-compat.md`

```
# Browser Compatibility — Chrome, Safari, Edge

Audit and fix cross-browser compatibility issues targeting the three major engines: Blink (Chrome/Edge), WebKit (Safari).

## Target Browsers

| Browser | Engine | Minimum Version |
|---------|--------|-----------------|
| Chrome  | Blink  | Last 2 versions |
| Edge    | Blink  | Last 2 versions |
| Safari  | WebKit | Last 2 versions (including iOS Safari) |

## Audit Procedure

### CSS Compatibility

Scan all `.css`, `.scss`, `.less`, and style blocks in `.tsx`/`.vue`/`.svelte` files for:

1. **Flexbox/Grid gaps** — `gap` in flexbox is unsupported in Safari < 14.1. Use `margin` fallback or `@supports`.
2. **`backdrop-filter`** — Requires `-webkit-backdrop-filter` for Safari.
3. **`:has()` selector** — Supported in Safari 15.4+, Chrome 105+. Provide fallback for older targets.
4. **Container queries** (`@container`) — Safari 16+, Chrome 105+. Feature-detect with `@supports`.
5. **Subgrid** — Safari 16+, Chrome 117+. Provide grid fallback.
6. **`dvh`/`svh`/`lvh` units** — Safari 15.4+, Chrome 108+. Always provide `vh` fallback first.
7. **`color-mix()`**, `oklch()`, `lch()` — Safari 16.2+, Chrome 111+. Provide hex/rgb fallback.
8. **Scroll snap** — Prefix differences: use both `scroll-snap-type` and `-webkit-scroll-snap-type`.
9. **`text-wrap: balance`** — Chrome 114+ only, no Safari support. Use as progressive enhancement.
10. **`@starting-style`** and `transition-behavior: allow-discrete` — Chrome 117+, no Safari. Progressive enhancement only.
11. **CSS Nesting** (`a { & b { } }`) — Safari 17.2+, Chrome 120+. Use `@supports (selector(&))` for detection, or add `postcss-nesting` plugin for older targets.
12. **`@layer` (cascade layers)** — Safari 15.4+, Chrome 99+. Safe for last-2-versions targets; only flag if the project's browserslist includes Safari < 15.4.

**Fix pattern — progressive enhancement with fallback:**
```css
/* Fallback first */
height: 100vh;
/* Modern enhancement */
height: 100dvh;
```

**Fix pattern — @supports feature detection:**
```css
.card {
  /* Fallback layout */
  margin-bottom: 1rem;
}
@supports (gap: 1rem) {
  .card {
    margin-bottom: 0;
  }
  .container {
    gap: 1rem;
  }
}
```

**Fix pattern — vendor prefix:**
```css
.blur {
  -webkit-backdrop-filter: blur(10px);
  backdrop-filter: blur(10px);
}
```

### Native Form Controls

Native HTML form elements (`<select>`, `<option>`, `<input>`, `<progress>`, `<meter>`, `<datalist>`) are **OS-level controls** with severely limited and inconsistent styling across browsers. This is NOT fixable with CSS prefixes or polyfills.

**Problem elements (most to least painful):**

1. **`<option>` inside `<select>`** — Chrome partially supports `background`, `color`; Safari **completely ignores** all custom styles on `<option>`, rendering with system native appearance. Styled `<option>` will ALWAYS look different across browsers.
2. **`<select>` dropdown arrow** — Varies by OS/browser. `appearance: none` removes it but requires custom arrow.
3. **`<input type="date/time/color">`** — Picker UI is entirely browser-native, unstylable.
4. **`<progress>` / `<meter>`** — Require vendor-specific pseudo-elements (`::-webkit-progress-bar`, `::-moz-progress-bar`).

**Detection:** Flag any `<option>` or native form control with `style={}` or `className` that sets visual properties (background, color, border, font, padding). These will render inconsistently.

**Fix — replace with custom dropdown component:**
```tsx
// WRONG — will look different in Safari vs Chrome
<select style={{ background: '#333', color: '#fff' }}>
  <option style={{ background: '#222', color: '#fff' }}>Item</option>
</select>

// RIGHT — use a custom dropdown (headless UI, Radix, or hand-built)
// Libraries: @headlessui/react, @radix-ui/react-select, react-select
import { Listbox } from '@headlessui/react';
// Or: import * as Select from '@radix-ui/react-select';
// These render <div>-based dropdowns with full CSS control.
```

**Fix strategies for native form controls:**
1. **Replace with headless UI component** — Radix, Headless UI, React Select, etc. Full styling control. **(Preferred)**
2. **`appearance: none`** + custom styling — Works for `<select>` itself (not `<option>`). Removes native chrome.
3. **Accept the inconsistency** — If the styling difference is minor and cosmetic, document and move on.

### JavaScript API Compatibility

Scan all `.js`, `.ts`, `.tsx` files for:

1. **`structuredClone()`** — Safari 15.4+, Chrome 98+. Fallback: `JSON.parse(JSON.stringify())` for simple objects.
2. **`Array.prototype.at()` / `String.prototype.at()`** — Safari 15.4+, Chrome 92+. Fallback: `arr[arr.length - 1]` / `str[str.length - 1]`.
3. **`Object.hasOwn()`** — Safari 15.4+, Chrome 93+. Fallback: `Object.prototype.hasOwnProperty.call()`.
4. **`crypto.randomUUID()`** — Safari 15.4+, Chrome 92+. Requires secure context (HTTPS).
5. **`AbortSignal.timeout()`** — Safari 16+, Chrome 103+. Polyfill with manual `AbortController` + `setTimeout`.
6. **`Array.prototype.findLast()`/`findLastIndex()`** — Safari 15.4+, Chrome 97+. Polyfill with reverse iteration.
7. **`Promise.withResolvers()`** — Safari 17.4+, Chrome 119+. Very new — always polyfill or avoid.
8. **`Set` methods (`union`, `intersection`, `difference`)** — Safari 17+, Chrome 122+. Very new — polyfill.
9. **`Intl.Segmenter`** — Safari 16.4+, Chrome 87+. Safe for last-2-versions targets. Only flag if the project's browserslist includes Safari < 16.4.
10. **Resize Observer** — Widely supported but Safari < 13.1 needs polyfill. Check minimum target.
11. **`dialog` element** — Safari 15.4+. Use polyfill for older versions.
12. **Top-level `await`** — Safari 15+, Chrome 89+. Safe for modern targets, but check bundler output.

**Fix pattern — guard with availability check:**
```typescript
const clone = typeof structuredClone === 'function'
  ? structuredClone(obj)
  : JSON.parse(JSON.stringify(obj));
```

**Fix pattern — polyfill import:**
```typescript
// Install: pnpm add core-js
import 'core-js/actual/array/at';
import 'core-js/actual/structured-clone';
```

### HTML / Web API Compatibility

1. **`<dialog>` element** — Safari 15.4+. Include `dialog-polyfill` for older targets.
2. **`loading="lazy"` on images** — Safari 15.4+. Works without fallback (degrades to eager load).
3. **`Popover` API** — Safari 17+, Chrome 114+. Very new — use JS fallback.
4. **`View Transitions` API** — Chrome 111+ only, no Safari. Progressive enhancement only.
5. **`<search>` element** — Safari 17+, Chrome 118+. Degrades to generic element — safe to use.
6. **`inert` attribute** — Safari 15.5+, Chrome 102+. Polyfill available.

### Build Tooling Checks

1. **Browserslist config** — Ensure `.browserslistrc` or `browserslist` in `package.json` includes:
   ```
   last 2 Chrome versions
   last 2 Safari versions
   last 2 Edge versions
   ```
2. **PostCSS Autoprefixer** — Verify `autoprefixer` is in PostCSS config. It auto-adds `-webkit-` prefixes.
3. **Babel / SWC targets** — If using Babel or SWC, verify browser targets match the browserslist.
4. **TypeScript `lib`** — Ensure `tsconfig.json` has appropriate `lib` entries (e.g., `ES2022`, `DOM`).
5. **Vite/Webpack targets** — Check `build.target` (Vite) or `target` (Webpack) aligns with browser support.

## Reporting Format

After auditing, produce a report table:

```markdown
| File | Line | Issue | Browsers Affected | Fix |
|------|------|-------|-------------------|-----|
| src/App.tsx | 42 | `structuredClone()` | Safari < 15.4 | Add JSON fallback |
| src/styles.css | 18 | `gap` in flexbox | Safari < 14.1 | Add margin fallback |
```

## Fix Strategies (ordered by preference)

1. **Progressive enhancement** — Write fallback first, enhancement second. No JS needed.
2. **`@supports` / feature detection** — CSS-level branching.
3. **Runtime guard** — `if (typeof X === 'function')` before using modern APIs.
4. **Polyfill** — `core-js`, `dialog-polyfill`, etc. Only when no simpler option exists.
5. **PostCSS / Autoprefixer** — Handles vendor prefixes automatically at build time.
```

---

## Completion Checklist

- [ ] All requested features implemented.
- [ ] Formatter configured and run.
- [ ] Tests written and passing.
- [ ] Build succeeds.
- [ ] README generated.
- [ ] Project runs end-to-end.
