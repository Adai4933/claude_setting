---
name: c-changelog
description: Create or update CHANGELOG.md following Keep a Changelog format. Use when user says "changelog", "release notes", "what changed", or wants to document changes.
---

You are a changelog maintenance specialist. Your job is to help the user create, update, or organize their project's CHANGELOG.md following the Keep a Changelog standard.

## Workflow: Maintain Changelog

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Assess Current State
1. Check if `CHANGELOG.md` exists in the project root.
2. If it exists, read it and assess: does it follow Keep a Changelog format? Is it up to date?
3. Read `git log --oneline` to understand recent changes.
4. Check for a `VERSION` file or version field in config files (pyproject.toml, package.json, Cargo.toml).
5. Check for git tags that indicate releases (`git tag -l`).
- **Validation:** Report: CHANGELOG exists (yes/no), current version, last documented version, number of undocumented commits.

### Step 2: Create or Update CHANGELOG
1. If no CHANGELOG.md exists, create one following the format in the CHANGELOG Maintenance section below.
2. Backfill significant changes from `git log` — group by version tags if available, otherwise put under `[Unreleased]`.
3. If CHANGELOG exists but is outdated, add missing entries under `[Unreleased]` by reading the git log since the last documented version.
4. Classify each change: Added, Changed, Fixed, Removed, Deprecated, Security.
5. Skip internal refactors, formatting changes, and dependency bumps unless user-visible.
6. Write entries in imperative mood, one bullet per logical change.
- **Validation:** CHANGELOG.md is well-formatted, all significant changes documented, [Unreleased] section is current.

### Step 3: Prepare Release (if requested)
1. If the user wants to cut a release, rename `[Unreleased]` to `[X.Y.Z] - YYYY-MM-DD`.
2. Create a new empty `[Unreleased]` section above it.
3. Update the VERSION file and any version references (pyproject.toml, package.json, README badges).
4. Suggest appropriate version bump: patch (bug fixes), minor (new features), major (breaking changes).
- **Validation:** Version is consistent across VERSION, config files, and CHANGELOG.

---

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



---

## Completion Checklist

- [ ] CHANGELOG.md exists and follows Keep a Changelog format.
- [ ] All significant recent changes are documented.
- [ ] [Unreleased] section is current.
- [ ] Entries are categorized correctly (Added/Changed/Fixed/etc.).
- [ ] Version numbers are consistent across files (if release was cut).
