---
name: c-browser-compat
description: Audit and fix cross-browser compatibility issues for Chrome, Safari, and Edge
---

You are a browser compatibility specialist. Your job is to audit the user's web project for cross-browser issues targeting Chrome, Safari, and Edge, then fix them. Firefox is intentionally out of scope — this skill targets Blink (Chrome/Edge) and WebKit (Safari) only. If the user provides a specific scope (files or directories), focus there. Otherwise, scan the entire frontend source. Prefer progressive enhancement and minimal polyfills over heavy shims.

## Workflow: Browser Compatibility Audit & Fix

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Analyze Project Setup
1. Detect the frontend framework (React, Vue, Svelte, vanilla) and build tool (Vite, Webpack, etc.).
2. Read `package.json` for browserslist config, PostCSS plugins, and Babel/SWC config.
3. Read `tsconfig.json` for `target` and `lib` settings.
4. Check for `.browserslistrc` file.
5. Check for existing polyfill imports (core-js, polyfill.io, etc.).
6. Identify the CSS preprocessor in use (PostCSS, Sass, Less, Tailwind, or plain CSS).
- **Validation:** Report: framework, build tool, current browser targets, and whether autoprefixer is configured.

### Step 2: Scan for Compatibility Issues
1. Scan all CSS/SCSS/Less files and style blocks for issues listed in the CSS Compatibility section below.
2. Scan all JSX/TSX for styled native form controls (`<select>`, `<option>`, `<input>`, `<progress>`) as described in the Native Form Controls section below.
3. Scan all JS/TS/TSX files for issues listed in the JavaScript API Compatibility section below.
4. Scan HTML templates for issues listed in the HTML / Web API Compatibility section below.
5. Check build tooling against the Build Tooling Checks section below.
6. Compile a report table of all issues found (file, line, issue, affected browsers, suggested fix).
- **Validation:** Present the full compatibility report to the user. Confirm which issues to fix before proceeding.

### Step 3: Fix Build Configuration
1. Add or update browserslist config to cover `last 2 Chrome versions, last 2 Safari versions, last 2 Edge versions`.
2. If `autoprefixer` is not present, propose the installation to the user and wait for confirmation before installing. Once confirmed, add it to the PostCSS config.
3. Verify Babel/SWC/TypeScript targets align with the browserslist.
4. Verify Vite/Webpack build target aligns with the browserslist.
- **Validation:** Build config targets the correct browsers. Autoprefixer is active.

### Step 4: Fix Source Code Issues
1. For each CSS issue: add fallback declarations, vendor prefixes, or `@supports` blocks as described in the component guide.
2. For each JS issue: add runtime feature detection, inline fallback, or polyfill import as described in the component guide.
3. For each HTML issue: add polyfill or use progressive enhancement.
4. Prefer the lightest fix strategy: progressive enhancement > @supports > runtime guard > polyfill.
- **Validation:** Re-scan modified files to confirm all reported issues are resolved.

### Step 5: Quality Assurance
1. Follow the Quality Assurance Checks section below (format, test, build).
2. For the test step: browser compat fixes are not unit-testable — use the build step as the minimum verification. Only write or run tests if the project already has visual regression or integration tests that cover the changed components.
- **Validation:** All configured checks pass. Build completes without errors.

---

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

## Reference Resources

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

- [ ] Browserslist config covers Chrome, Safari, and Edge (last 2 versions).
- [ ] Autoprefixer is installed and active in the build pipeline.
- [ ] All CSS compatibility issues resolved (prefixes, fallbacks, @supports).
- [ ] All JS API compatibility issues resolved (guards, polyfills, fallbacks).
- [ ] No untested modern APIs used without fallback.
- [ ] Formatter has been run.
- [ ] Build succeeds without errors.
