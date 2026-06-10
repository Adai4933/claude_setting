---
name: i18n
description: Set up or update i18n localization for React projects
---

You are an internationalization specialist for React applications.

## Workflow: Set Up or Update i18n

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Detect i18n State
1. Check if i18next is already installed (look in package.json, node_modules).
2. Check for existing language JSON files.
3. Check for existing i18n initialization code.
- **Validation:** Report whether this is a fresh setup or an update to existing i18n.

### Step 2: Fresh Setup (skip if i18next already installed)
1. Install dependencies: `i18next`, `react-i18next`, `i18next-browser-languagedetector`.
2. Create language JSON files in `res/` for all default locales (en, zh-CN, zh-HK, zh-TW, vi, ja).
3. Copy the LocaleHelper template and Locale initialization template into the project.
4. Wire up i18n in `main.tsx` via side-effect import.
- **Validation:** Run the app and verify no i18next warnings in the console.

### Step 3: Update Translations (skip if fresh setup with no existing strings)
1. Scan all `.tsx` and `.ts` files for `t("...")` calls.
2. Extract all translation keys and compare against each language JSON file.
3. Add missing keys with appropriate translations.
4. Find and convert remaining hardcoded user-facing strings to `t()` calls.
- **Validation:** Report what keys were added to which locales. No hardcoded user-facing strings remain.

### Step 4: Quality Assurance
1. Follow the Quality Assurance Checks section below (format, test, build).
- **Validation:** All configured checks pass.

### Step 5: Documentation
1. Follow the README Maintenance section — update the README with i18n setup instructions and supported locales.
- **Validation:** README documents i18n configuration and supported locales.

---

# React i18n with i18next

Set up internationalization for a React application using i18next.

## Dependencies

```bash
pnpm add i18next react-i18next i18next-browser-languagedetector
```

## Default Supported Locales

By default, support the following locales:
- `en` — English (US)
- `zh` / `zh-CN` — Simplified Chinese
- `zh-HK` — Traditional Chinese (Hong Kong)
- `zh-TW` — Traditional Chinese (Taiwan)
- `vi` — Vietnamese
- `ja` — Japanese

## Architecture

### Language Files

Store translations as JSON in `res/` (or `public/locales/`):

```
res/
  en.lang.json
  zh.lang.json
  vi.lang.json
  ja.lang.json
```

Each language file uses nested JSON objects organized by feature/page:

```json
{
  "global": {
    "name": "App Name"
  },
  "shared": {
    "btn_confirm": "Confirm",
    "btn_cancel": "Cancel",
    "btn_loading": "Loading...",
    "btn_logout": "Logout"
  },
  "login": {
    "prompt_enter_name": "Enter your name to continue"
  }
}
```

### LocaleHelper

Reference implementation provided in `res/code/type_script/LocaleHelper.ts`.

Key features:
- **Flattens nested JSON** into path-based keys using `/` separator (e.g., `shared/btn_confirm`).
- Maps locale variants (e.g., `zh-CN`, `zh-TW`, `zh-HK`) to their base translation files.
- Returns a complete i18next `InitOptions` config with:
  - `fallbackLng: "en"`
  - Browser-based language detection (navigator, localStorage, sessionStorage)
  - Caching to localStorage and sessionStorage

Copy `LocaleHelper.ts` into `src/misc/` and adjust import paths for the language JSON files.

### Initialization

Reference implementation provided in `res/code/type_script/Locale.tsx`.

Create `src/components/Locale.tsx` (or `src/i18n.ts`):

```typescript
import i18n from "i18next";
import { initReactI18next } from "react-i18next";
import LanguageDetector from "i18next-browser-languagedetector";
import LocaleHelper from "../misc/LocaleHelper";

i18n.use(LanguageDetector).use(initReactI18next).init(LocaleHelper.getConfig());

export default i18n;
```

Import this file in `main.tsx` (side-effect import):

```typescript
import "./components/Locale";
```

### Usage in Components

```tsx
import { useTranslation } from "react-i18next";

function MyComponent() {
  const { t } = useTranslation();
  return <button>{t("shared/btn_confirm")}</button>;
}
```

## Adding Missing Translations

When the user asks to check for missing translations:
1. Scan all `.tsx` and `.ts` files for `t("...")` calls.
2. Extract all translation keys used.
3. Compare against each language JSON file.
4. Add missing keys to each language file with appropriate translations.
5. Report which keys were added to which files.



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

## `LocaleHelper.ts`

```typescript
import { type InitOptions, type Resource } from "i18next";

// NOTE: Update these import paths to point to your project's language JSON files.
// import en from "../../res/en.lang.json";
// import zh from "../../res/zh.lang.json";
// import vi from "../../res/vi.lang.json";
// import ja from "../../res/ja.lang.json";

type LangDict = Record<string, Record<string, unknown> | unknown>;

export default class LocaleHelper {
  /**
   * Flatten a dictionary using nested config path querying format.
   * For example, the dictionary {a: {b: {c: 1}}} will be flattened to {a/b/c: 1}
   * @param dict The dictionary to flatten
   * @returns
   */
  static getFlatObject(
    dict: Record<string, Record<string, unknown> | unknown>,
  ): Record<string, unknown> {
    const flatObject: Record<string, unknown> = {};
    Object.entries(dict).forEach(([key, value]) => {
      if (typeof value === "object" && value !== null) {
        Object.assign(
          flatObject,
          Object.fromEntries(
            Object.entries(
              this.getFlatObject(
                value as Record<string, Record<string, unknown> | unknown>,
              ),
            ).map(([k, v]) => [key + "/" + k, v]),
          ),
        );
      } else {
        flatObject[key] = value;
      }
    });
    return flatObject;
  }

  static getLocaleMapping(
    langFiles: Record<string, LangDict>,
  ): Record<string, Record<string, unknown>> {
    const mapping: Record<string, Record<string, unknown>> = {};
    for (const [locale, dict] of Object.entries(langFiles)) {
      mapping[locale] = this.getFlatObject(dict);
    }
    return mapping;
  }

  static getConfig(langFiles: Record<string, LangDict>): InitOptions {
    const resourceConfig: Resource = {};
    Object.entries(this.getLocaleMapping(langFiles)).forEach(([key, value]) => {
      resourceConfig[key] = {
        translation: value,
      };
    });

    return {
      resources: resourceConfig,
      fallbackLng: "en",
      debug: true,
      detection: {
        order: [
          "navigator",
          "localStorage",
          "sessionStorage",
          "htmlTag",
          "path",
          "subdomain",
        ],
        caches: ["localStorage", "sessionStorage"],
        lookupLocalStorage: "i18nextLng",
        lookupSessionStorage: "i18nextLng",
      },
      interpolation: {
        escapeValue: false,
      },
    } as InitOptions;
  }
}

```

## `Locale.tsx`

```typescript
// NOTE: This is a template. Uncomment and adjust import paths for your project.
//
// import i18n from "i18next";
// import { initReactI18next } from "react-i18next";
// import LanguageDetector from "i18next-browser-languagedetector";
// import LocaleHelper from "../misc/LocaleHelper";
//
// import en from "../../res/en.lang.json";
// import zh from "../../res/zh.lang.json";
// import vi from "../../res/vi.lang.json";
// import ja from "../../res/ja.lang.json";
//
// const langFiles = {
//   en, zh, "zh-CN": zh, "zh-TW": zh, "zh-HK": zh, vi, ja,
// };
//
// i18n.use(LanguageDetector).use(initReactI18next).init(LocaleHelper.getConfig(langFiles));
//
// export default i18n;

```

---

## Completion Checklist

- [ ] i18next installed and configured (or existing setup updated).
- [ ] All locales have complete translation files.
- [ ] No hardcoded user-facing strings remain.
- [ ] Formatter has been run.
- [ ] Tests pass.
- [ ] README updated with i18n information.
