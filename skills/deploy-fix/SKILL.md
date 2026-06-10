---
name: deploy-fix
description: Diagnose and fix deployment/build/CI failures, then harden the deploy script so the same error class self-heals. Use whenever the user pastes a failing deploy/build output — make deploy errors, docker build failures, helm/kubectl errors, registry/mirror timeouts, pnpm/pip/uv install failures inside Docker, kubeconfig or ACR auth errors, staging rollout timeouts — or says "deploy fail", "fix deploy", "build error when deploy", "it returns error when deploy". Also use when a deploy succeeded only after manual steps and the user wants those steps folded into the pipeline.
---

You are fixing a broken deploy and then making the pipeline absorb the lesson. A deploy fix that lives only in the conversation is lost the next time the same error appears — the job has two halves: fix the failure now, then fold the fix into the deploy script/Makefile so the error class never needs a human again.

## Workflow

### Step 1: Locate the failing stage
Parse the pasted output and name the stage: dependency install → image build → registry push/pull → manifest apply (helm/kubectl) → migration → rollout → smoke. Quote the decisive error line back. If output is truncated before the root cause, ask for the full log of that stage rather than guessing.

### Step 2: Diagnose against the environment's realities
Check the usual suspects for this setup before exotic theories:
- **Mirror/network**: builds run behind CN mirrors (e.g. `docker.1ms.run`, `registry.npmmirror.com`, PyPI mirrors). Timeouts and 403s are often mirror-side. Any fix must preserve the existing mirror-switching conditionals (e.g. `USE_CN`) — a fix that hardcodes one mirror breaks the other environment.
- **Credentials/freshness**: expired kubeconfig, registry auth (ACR secrets), missing login step.
- **Environment drift**: staging vs production vs local config; confirm which environment the command targeted before changing anything.
- If the deploy runs on a remote machine, output the diagnostic commands for the user to run and wait for pasted results — do not run them locally.

### Step 3: Fix minimally
The fix touches only the broken stage. Hard constraints:
- Never modify the production CI path (e.g. GitHub Actions auto-deploy) while fixing a staging/local deploy — they share files; check blast radius before editing.
- Fallbacks (mirror, registry, base image) are configurable variables with defaults, never hardcoded URLs.
- Secrets stay in gitignored files with `.example` templates — never inline in scripts.
If the fix requires changing deploy scripts/Makefile/Dockerfile, present the change and wait for an explicit approval token before applying.

### Step 4: Re-run and confirm
Re-run the deploy (or hand the user the exact command if the machine is remote). The fix is confirmed when the previously failing stage passes — not when the edit is made. If it fails again, return to Step 2 with the new output; do not re-apply the same fix.

### Step 5: Harden the pipeline
Once the deploy succeeds, fold the fix into automation so this error class self-heals. Patterns that have worked here:
- Auth/freshness errors → add a refresh/login step to the deploy flow (kubeconfig refresh, registry login from the gitignored secrets file).
- Mirror flakiness → add a configurable fallback (try primary, fall back to secondary; `USE_CN` logic intact for both).
- Missing precondition → add a check with a clear error message early in the script, so the failure is diagnosed in one line instead of a stack trace.
Keep hardening additive and scoped to the error class just seen — do not speculatively armor stages that haven't failed.

### Step 6: Report
State: root cause (one sentence), the fix (file:line), proof it works (the re-run result), and what hardening was added so the error self-heals next time.

## Example

Input: "deploy to staging error" + helm rollout timeout log
Right: identify rollout stage → find image pull failing on stale ACR secret → refresh secret, re-run, deploy green → add secret refresh to `make deploy` so next expiry self-heals → report all three.
Wrong: bump the helm timeout and declare victory.
