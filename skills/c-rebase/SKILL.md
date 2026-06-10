---
name: c-rebase
description: Clean up branch commits: squash related changes, reformat messages to Conventional Commits, and force-push. Use when user says "rebase", "clean up commits", "squash", or wants tidy PR history.
---

You are a git history specialist. The user wants you to clean up the commits on their current branch before merging. You identify the base branch, analyze new commits, squash related ones together, reformat all commit messages to Conventional Commits style, and force-push the result. You never touch commits that belong to the base branch.

## Workflow: Rebase and Clean Branch History

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Identify Base Branch and Scope
1. Determine the current branch name with `git branch --show-current`.
2. Guard: if the current branch is `main` or `master`, stop immediately and tell the user this skill is for feature/PR branches only.
3. Try to detect the base branch automatically using these methods in order:
4.   (a) If `gh` CLI is authenticated, run `gh pr view --json baseRefName -q .baseRefName` to get the PR base branch.
5.   (b) Otherwise, infer from `git log --oneline --merges -1` or common defaults (`main`, `master`, `develop`).
6. Identify the divergence point: `git merge-base <base-branch> HEAD`.
7. List new commits on this branch: `git log --oneline <merge-base>..HEAD`.
8. If there are 0 new commits, tell the user and stop.
- **Validation:** Base branch identified, merge-base computed, and list of new commits displayed.

### Step 2: Analyze and Group Commits
1. Read the full diff and message of each new commit: `git log --stat -p <merge-base>..HEAD`.
2. Group related commits that should be squashed together — e.g., a feature commit followed by fix-ups, typo corrections, or 'WIP' commits that continue the same logical change.
3. For each group, decide on a single Conventional Commits message that accurately describes the combined change.
4. For commits that are already standalone and well-scoped, keep them separate but reformat the message to Conventional Commits style if needed.
5. Present the proposed commit plan to the user: which commits get squashed, what the new messages will be, and the final ordering.
- **Validation:** Commit plan displayed showing original commits, proposed grouping, and new messages.

### Step 3: Perform Interactive Rebase
1. Create a backup tag at the current HEAD: `git tag backup-pre-rebase-$(date +%s)` so the user can recover if needed.
2. Use `git rebase -i <merge-base>` with a scripted `GIT_SEQUENCE_EDITOR` to apply the squash/reword plan — do NOT use an interactive terminal editor.
3. For squashing: mark the first commit of each group as `pick` and subsequent commits as `fixup` or `squash`.
4. For rewording: use `GIT_SEQUENCE_EDITOR` or `git commit --amend` after each step to set the Conventional Commits message.
5. Alternative approach if scripted rebase is complex: use `git reset --soft <merge-base>` followed by individual `git commit` calls to reconstruct the desired history from scratch.
6. After the rebase, verify the final diff matches the original: `git diff <backup-tag>..HEAD` should be empty (same tree, different history).
- **Validation:** Rebase complete. `git diff <backup-tag>..HEAD` shows no changes (identical tree). `git log --oneline <merge-base>..HEAD` shows the cleaned-up commits.

### Step 4: Force-Push
1. Run `git push --force-with-lease` to update the remote branch.
2. If the branch has no upstream, use `git push -u origin HEAD --force-with-lease`.
3. Verify the push succeeded.
- **Validation:** Remote branch updated. `git log --oneline origin/<branch>..HEAD` shows nothing (local and remote match).

### Step 5: Offer PR Submission
1. Check if a PR already exists for this branch: `gh pr view --json number 2>/dev/null`.
2. If no PR exists, ask the user if they want to create one. If yes (or in AFK mode), create the PR with `gh pr create` using a title derived from the cleaned commit history and a body summarizing the changes.
3. If a PR already exists, inform the user that the force-push has updated it.
- **Validation:** PR status communicated to the user.

---

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



---

## Completion Checklist

- [ ] Current branch is not main/master.
- [ ] Base branch correctly identified (via gh or git heuristics).
- [ ] All new commits analyzed and grouped by logical change.
- [ ] Commit messages follow Conventional Commits format.
- [ ] Backup tag created before rebase.
- [ ] Rebase preserves identical tree (no code changes lost).
- [ ] Force-push succeeded.
- [ ] PR created or updated.
