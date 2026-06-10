---
name: c-readme
description: Write a polished README for the project
---

You are a technical writing specialist. Write a README for the user's project that is beautiful, informationally correct, and concise.

## Workflow: Write Project README

**IMPORTANT — Sequential Workflow Orchestration Rules:**
- Execute steps in numbered order. Never jump ahead.
- After completing each step, validate it succeeded before proceeding.
- If validation fails, fix the issue in the current step before moving on. Retry up to 2 times.
- If a step fails after retries, report to the user: what failed, what you tried, and suggested next steps.
- On unrecoverable failure, rollback partial changes so the codebase is left clean.
- Announce each step before starting (e.g., "Step 1: Analyzing the codebase...").

### Step 1: Analyze Project
1. Read the project's source code, Makefile, and configuration files.
2. Identify the tech stack, prerequisites, entry points, and key features.
3. Find any existing README and note what can be kept or improved.
- **Validation:** List the key facts you discovered (name, purpose, stack, commands) before writing.

### Step 2: Draft README
1. Write the README following the template guidelines below.
2. Use the reference example README as inspiration for structure and tone — it demonstrates a well-organized README with clear sections for features, tech stack, API endpoints, setup, Docker, and development.
3. Adapt the structure to fit the current project's needs (not all sections may be relevant).
- **Validation:** Verify every section has accurate information by cross-referencing with the actual source code.

### Step 3: Validate Completeness
1. Check that a new contributor could set up and use the project by reading only the README.
2. Verify all commands in the README actually work.
3. Confirm all prerequisites and versions are accurate.
- **Validation:** Run any documented commands (like `make help`) to verify they work.

### Step 4: Finalize
1. Polish formatting — check for consistent heading levels, code block languages, and table alignment.
2. Remove any redundant or outdated information.
3. Ensure the README is concise — no walls of text.
- **Validation:** README is well-formatted and concise.

---

# README Writing Guidelines

Write a README that is beautiful, informative, and concise. Follow this structure:

## Structure

### Header
- Centered project logo (if available) or a styled title using HTML `<h1 align="center">`.
- One-line description in bold below the title.
- Badge row for key metadata (language version, platform, version).

```markdown
<p align="center">
  <img src="res/img/logo.svg" alt="Project Name" width="120" />
</p>

<h1 align="center">Project Name</h1>

<p align="center">
  <strong>One-line project description</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/python-3.13+-3776AB?logo=python&logoColor=white" alt="Python" />
  <img src="https://img.shields.io/badge/version-1.0.0-blue" alt="Version" />
</p>
```

### Overview
- 2-3 sentences describing what the project does.
- Bulleted list of key features.

### Quick Start
- Installation: `make install`
- Build/Run: show the primary commands
- Cleanup: `make clean` / `make uninstall`

### Prerequisites
- Table format with Requirement, Version, and Notes columns.

### Project Structure
- ASCII tree diagram of the key directories.

### Usage
- Table of all Makefile targets with descriptions.
- Code blocks for common workflows.

### Development
- How to format code: `make format`
- How to commit: `make commit`
- How to run tests: `make test`

### Troubleshooting
- Use collapsible `<details>` sections for common issues.

### Contributing
- Brief workflow (branch, change, format, PR).

### License
- One line.

## Style Rules

- Keep it concise — no walls of text.
- Use tables over prose for structured information.
- Use horizontal rules (`---`) to separate major sections.
- Use code blocks generously for commands.
- Prefer imperative mood ("Install dependencies" not "You can install dependencies by...").



# README Maintenance

After completing your task, update the README if: new deps added/removed, new commands/targets, new scripts/tools, config changes affecting setup, new user-facing features, or breaking changes. Do NOT update for internal refactors, bug fixes without behavior change, or style changes. Keep additions concise, remove outdated content.



---

## Reference Resources

Use these code templates as reference when implementing:

- `/home/robin/Desktop/Workstation/claudia/res/docs/readme-example.md`

---

## Completion Checklist

- [ ] All sections from the template are covered (where applicable).
- [ ] Commands in the README are accurate and tested.
- [ ] Prerequisites and versions are correct.
- [ ] README is concise and well-formatted.
- [ ] A new contributor can get started by reading the README alone.
