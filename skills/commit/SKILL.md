---
name: commit
description: Stage, format, and commit changes with a conventional (commitizen) commit message, then optionally push
---

You are a git commit assistant. Your job is to stage the user's changes, craft a clear commitizen-style commit message, run any configured formatter, and commit — then ask whether to push.

## Workflow: Commit Changes

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Check Staged Files
1. Follow the Staging Changes section below to determine which files to commit.
- **Validation:** Confirm which files are staged and ready for commit.

### Step 2: Analyze Changes and Draft Commit Message
1. Run `git diff --cached` to inspect the full diff of staged changes.
2. Run `git log --oneline -10` to see recent commit style for context.
3. Draft a commit message following the Commitizen-Style Commit Messages section below.
4. Present the drafted commit message to the user and ask for approval or edits.
- **Validation:** User has approved or edited the commit message.

### Step 3: Run Formatter and Re-stage
1. Follow the Format and Re-stage section below — run the formatter if one is configured, then re-stage any modified files.
- **Validation:** Staged files include any formatting changes (or no formatter was detected).

### Step 4: Create the Commit
1. Run `git commit` with the approved commit message.
2. Use a heredoc to pass the message so multi-line bodies are preserved correctly.
3. Verify the commit succeeded by running `git log --oneline -1`.
- **Validation:** The new commit appears in git log with the correct message.

### Step 5: Offer to Push
1. Follow the Push to Remote section below — ask the user and push if requested.
- **Validation:** Push succeeded, or user chose not to push.

---

# Staging Changes

Determine which files to commit by inspecting the current git state.

## Procedure

1. Run `git status` to see the working-tree state.
2. **If files are already staged** (changes in the index) — leave the staging area as-is. The user intentionally staged those files.
3. **If nothing is staged** but there are unstaged changes or untracked files — stage everything with `git add -A`.
4. **If the working tree is completely clean** (nothing staged, nothing unstaged, nothing untracked) — report to the user that there is nothing to commit and **stop**.

After this step, confirm which files are staged and ready for commit.



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



# Format and Re-stage

Run the project's formatter (if configured) and ensure formatted files are staged before committing.

## Detecting a Formatter

Look for these signals:

- **General:** `tidy.sh` in the project root, `make format` or `make tidy` target in the Makefile
- **Python:** `ruff.toml`, `pyproject.toml` with `[tool.ruff]`, `.flake8`
- **TypeScript/JavaScript:** `.prettierrc`, `eslint.config.js`, `.eslintrc.*`, `biome.json`
- **Rust:** `rustfmt.toml`
- **Go:** `gofmt` / `goimports` (always available)

If no formatter is detected, skip this step entirely.

## Running the Formatter

Use the first available option:

1. `tidy.sh` (preferred — wraps all formatters)
2. `make format` or `make tidy`
3. The language-specific formatter directly (last resort)

## Re-staging

After the formatter runs, some staged files may have been modified on disk but are now out of sync with the index. Run `git add` on every file that the formatter touched so the formatted versions are what gets committed.



# Push to Remote

After the commit is created, ask the user whether they want to push.

- **If yes:** run `git push`. If the current branch has no upstream, use `git push -u origin HEAD`.
- **If no:** stop — the commit is done.



---

## Completion Checklist

- [ ] Staged files verified (auto-staged if nothing was staged).
- [ ] Commit message follows commitizen / conventional-commits format.
- [ ] Formatter ran and formatted files re-staged (if applicable).
- [ ] Commit created successfully.
- [ ] User was asked about pushing.
