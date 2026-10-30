# Azure DevOps Platform — Master Capstone Acceptance Checklist

> Source: **Capstone: Build a DevOps Platform on Azure**, Oct 26, 2026, 22 pages. Tracks original `P0.1`–`P9.6` acceptance items, plus checkpoints, final tests, and release safety.
> Repository: `williamthangavelu0710/azure-devops-platform` · Latest documentation PR: #24 (merged) · Current checklist update: local, not yet committed.
> Baseline evidence recorded from our chat through commit `8ab5e4c`; this checklist **does not imply** we have audited the complete live repository.

## Latest verified baseline — October 30, 2026

This section records subsequent verified progress. The original
acceptance matrix remains below for traceability.

| Area | Latest verified status |
|---|---|
| Architecture and evidence | PR #24 merged into main; commit dce3456 was the documentation branch commit |
| Main branch protection | One required approval restored after temporary single-operator exception |
| PR #24 CI | PASS; both required checks successful |
| Post-merge CI | PASS; GitHub Actions run 41133213490 |
| Post-merge CD | SUCCESS; run 41133277858; DEV deployment job skipped for documentation-only changes |
| Live DEV AKS | HEALTHY; deployment 1/1, pod Running, zero restarts |
| HPA | ACTIVE; CPU 2%/50%, minimum 1, maximum 3 replicas |
| HPA load test | PASS for CPU-triggered scaling 1 -> 3 -> 1 and three-pod /whoami load balancing; original hey test remains unverified |
| Failed-release rollback | Demonstrated with intentionally invalid readiness path; healthy release restored |
| PROD deployment | Not provisioned; facilitator-approved DEV-only exception |
| PROD approval/promotion | Omitted under facilitator-approved demo exception |
| Centralized monitoring and alerting | PARTIAL: kubectl top metrics, NGINX logs, readiness/liveness probes and HPA events verified October 30; centralized monitoring and alerting not implemented |
| Two ADRs | Not yet verified or completed |
| Final live demonstration | PENDING |
| Facilitator acceptance | PENDING |

The original assignment requirements are not automatically marked
PASS by these updates. Each acceptance criterion still requires
its specified evidence or a documented facilitator-approved exception.

---

## Current verified baseline — October 29, 2026

> This section supersedes outdated snapshot references below.
> Original acceptance criteria remain preserved for traceability.
> Detailed evidence: `docs/evidence.md`.

| Area | Current verified status |
|---|---|
| GitHub PR #14 | MERGED; merge commit `4fdc46e` |
| Main branch protection | One required approval restored after temporary solo-developer exception |
| Required CI checks | Both passed on PR #14 |
| Terraform network migration | PASS; three state moves, zero infrastructure changes |
| DEV Terraform validation | PASS; formatting, validation, and no-drift plan |
| DEV Azure OIDC | PASS; GitHub Actions run `40973658957` |
| Post-merge CI | PASS; run `40973503034` |
| Post-merge CD | PASS; run `40973564599`, DEV deployment skipped |
| DEV deployment gate | `DEV_DEPLOY_ENABLED=false` at last verification |
| Live DEV deployment | PENDING verification |
| HPA load test | PENDING |
| Monitoring and incident drill | PENDING |
| Failed-release rollback | PENDING |
| Final demonstration | PENDING |

### Facilitator-approved demo exceptions

- **DEV-only:** Karthik approved omitting a separately deployed PROD environment because of Azure Free Tier limitations.
- **Promotion/approval:** Karthik approved omitting the PROD approval and promotion stage from the final demo.
- These are exceptions to the original assignment, not evidence that the original PROD requirements were completed.
- The temporary PR #14 review-policy exception was a separate solo-developer action; it was not an independent review or a facilitator-approved waiver.

### Safety

- Keep DEV deployment disabled until explicitly authorized.
- Do not start AKS, apply Terraform, provision PROD, or destroy resources without explicit authorization.
- Continue to use feature branches and pull requests.

---

## Rules of use

- **PASS** only after the precise *Done when* criterion has evidence (command output, screenshot, URL, PR check, or documented verified exception agreed by facilitator).
- **PARTIAL** means some implementation or evidence exists, but full acceptance is not demonstrated.
- **UNVERIFIED** means the criterion has not been assessed adequately; it does **not** mean absent.
- **BLOCKED** means an external restriction or explicit dependency prevents completion; it is not counted as PASS.
- **PENDING** means future action such as reviewer approval, merge, demonstration, or teardown remains.
- After every test, update the row's status and evidence, date/commit, and link to logs in `docs/evidence.md` or the relevant PR.
- Stop and obtain explicit authorization before merging, starting AKS, provisioning PROD, applying Terraform, incurring costs, or destroying resources.

## Current project safety and evidence

| Control | Last observed evidence | Status |
|---|---|---|
| DEV AKS | Intentionally stopped to save Free Trial credits | Keep stopped |
| PROD | Not provisioned/deployed | Do not apply without approval |
| PR #5 | Open, no review; head `8ab5e4c` | Not merged |
| CI | Two PR jobs successful after `8ab5e4c` (user terminal output) | PASS for those jobs only |
| DEV CD gate | Repo `DEV_DEPLOY_ENABLED=false`; no DEV env variable override; conditional gate on branch | Configured, pending any merge validation |
| GitHub governance | Protection APIs 403 on private repo; secret scanning disabled | BLOCKED / partial |
| Review buddy | Karthik, GitHub handle not yet known | PENDING |

## Assignment-wide ground rules

- [ ] Infrastructure and application changes as code; document GitHub settings in `docs/github-settings.md`.
- [ ] PR review buddy approves **each** PR before merge; no direct push to main.
- [ ] No long-lived secrets in Git/GitHub/Kubernetes; Azure access via OIDC and ACR pull via identity.
- [ ] Resource names/tags conform to spec **or** explicit facilitator-approved deviation recorded.
- [ ] Confirm Azure quota, budget and cost controls; stop DEV cluster while idle.
- [ ] Be able to explain every Terraform/Docker/Kubernetes/workflow decision at demo.
- [ ] Record all non-spec naming/layout differences in an ADR or deviations section (current repo `azure-devops-platform`, `terraform/`, `kubernetes/`, `site/Dockerfile`, `dev` namespace rather than sample `hello`).

## Phase-by-phase acceptance matrix

### Phase 0 — Setup and access

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P0.1** | Tools and version proofs | `az`, Terraform >=1.9, `kubectl`, `kubelogin`, `kustomize`, Docker, `gh`, `tflint`, Trivy, Hadolint, HTMLHint, `hey`; collect version output. | **UNVERIFIED** | Some tools used; full version inventory not captured. |
| **P0.2** | Azure authorization | Training subscription selected; role assignment shows Owner or Contributor + RBAC Administrator. | **UNVERIFIED** | Azure access demonstrated, role proof not audited. |
| **P0.3** | Regional quota | DSv5 family headroom for ~14 vCPUs confirmed or approved exception documented. | **BLOCKED** | Prior Free Trial vCPU quota restriction; capture live `az vm list-usage` evidence. |
| **P0.4** | Provider registrations | ContainerService, ContainerRegistry, OperationalInsights, ManagedIdentity, Storage, Network, Insights registered. | **UNVERIFIED** | No complete registration check logged. |
| **P0.5** | Names and region | Initials/region agreed with facilitator and recorded in README. | **PARTIAL** | README shows WT / eastus; facilitator approval not verified. |

### Phase 1 — GitHub repository and website

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P1.1** | Repo foundation | `gh repo view`; README owner/initials/region; `.gitignore`, `.editorconfig`; required internal visibility or exception. | **PARTIAL** | Private repo works; README and files committed; internal visibility unsupported on personal account. |
| **P1.2** | Main protection | PR required, one approval, stale approval dismissed, conversations resolved, no force-push/delete, linear history; direct push rejected. | **BLOCKED** | GitHub private-repo plan returns HTTP 403 for rulesets/protection. |
| **P1.3** | Review and security plumbing | CODEOWNERS incl. buddy, PR template, Dependabot Docker/Actions/Terraform, secret scanning and push protection; buddy requested by test PR. | **PARTIAL** | Files committed; Karthik placeholder only; scanning disabled; push protection unavailable/unverified. |
| **P1.4** | Site and local browser | `site/` page heading/banner/footer; JS fetches env, version, whoami; nginx 8080 healthz/whoami; local banner works. | **PASS** | Browser screenshot local banner and unknown SHA/pod; Docker endpoint smoke logs. |
| **P1.5** | HTML lint | `make lint` runs HTMLHint with zero errors. | **PASS** | GitHub Actions CI succeeded after `make lint` workflow change, commit `1249ec1`. |
| **P1.6** | Reviewed and merged PR | Buddy approval and merge into main. | **PENDING** | PR #5 open; no approvals; no merge. |

### Phase 2 — Docker image

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P2.1** | Small build context | `.dockerignore` excludes `.git`, infra/k8s/docs/local files; build context <1 MB. | **PASS** | Docker build context 177 bytes in Step 293; .dockerignore exclusions reviewed and expanded. |
| **P2.2** | Hardened multi-stage image | Build on Alpine; generate `version.json` from `APP_VERSION`; Alpine nginx-unprivileged runtime; base tags + digests; source/revision OCI labels; image <50 MB; non-root inspect. | **PASS** | Multi-stage APP_VERSION build; both images pinned by digest; project OCI labels verified; image 27,466,007 bytes; runtime UID 101. |
| **P2.3** | CPU architecture | Inspect final image and confirm `amd64`. | **PASS** | docker image inspect confirmed linux/amd64 in Steps 274 and 293. |
| **P2.4** | Read-only runtime parity | Run with `--read-only --tmpfs /tmp -p 8080:8080`; page shows expected SHA and hostname; healthz HTTP 200. | **PASS** | Step 275: read-only root filesystem with tmpfs /tmp; health, version SHA, hostname and website verified. |
| **P2.5** | Reusable smoke test | `scripts/smoke.sh <base-url> <sha>` retries <=2 min, checks SHA, health and title, fails for wrong SHA; used in CI and CD. | **PARTIAL** | Positive and negative SHA smoke tests passed locally; scripts/smoke.sh integrated into CI and DEV CD, awaiting workflow execution and deployment verification. |
| **P2.6** | Trivy and Hadolint | Trivy `--ignore-unfixed --severity CRITICAL,HIGH`; zero fixable critical; Hadolint zero errors; HIGH findings fixed or justified in PR. | **PASS** | Step 292 Hadolint passed; Step 293 Trivy found zero HIGH/CRITICAL vulnerabilities with --ignore-unfixed. |
| **P2.7** | PR, merge and checkpoint | Reviewed PR merged and CP1 booked/completed (site in local container; protected main). | **PENDING** | Public repository and main branch protection verified; PR #5 remains open; updated CI, Karthik review, merge and CP1 still outstanding. |

### Phase 3 — Terraform foundation

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P3.1** | Bootstrap versions and validation | `infra/bootstrap` pins Terraform >=1.9 / azurerm 4.x; Azure AD storage auth; lock file committed; init/validate pass. | **PASS** | Steps 299-301: Terraform >=1.9, AzureRM 4.x, AAD storage auth, tracked lock file, fmt and validate pass. |
| **P3.2** | Tagged resource groups | Bootstrap plan shows shared, dev, prod groups with required tags. | **PARTIAL** | Step 302: shared and DEV groups exist with tags; PROD group absent; remaining bootstrap scope requires review. |
| **P3.3** | Secure Terraform state storage | StorageV2, no shared keys, TLS1.2, versioning, 7-day soft delete, tfstate, prevent_destroy, your blob role. | **PARTIAL** | Steps 302-303: Azure storage security, versioning and 7-day retention verified; prevent_destroy added in code; remaining role and state checks pending. |
| **P3.4** | Shared ACR | Basic ACR admin disabled; `az acr login` and manual P2 image push pass. | **PARTIAL** | Step 304: ACR Basic, admin disabled, provisioning succeeded; manual image push acceptance remains to verify. |
| **P3.5** | Migrate bootstrap state | AAD backend, `bootstrap.tfstate`, migrate-state, no local state, `terraform plan` no diff. | **PARTIAL** | Steps 303-305: platform AzureRM backend and AAD auth verified; DEV and PROD state blobs found; bootstrap state still local, migration and no-drift proof pending. |
| **P3.6** | Three least-privilege OIDC identities | Plan/dev/prod identities, correct subjects/audience and scoped roles; no subscription-scope assignments. | **PARTIAL** | DEV/PROD OIDC demonstrated; plan identity and role audit unverified. |
| **P3.7** | GitHub environments and IDs | Dev/prod environments; prod reviewer/branch restriction; relevant tenant/subscription/client variables; no Azure secrets. | **PARTIAL** | PROD GitHub vars exist; required reviewer and full identity variable audit pending. |
| **P3.8** | OIDC proof workflow | Throwaway dev workflow successfully logs into Azure using OIDC; remove workflow afterward. | **PARTIAL** | DEV CD OIDC succeeded earlier; exact throwaway workflow proof not available. |
| **P3.9** | Reusable module skeleton | Network, AKS and monitoring modules have typed/described variables, outputs, versions; tflint + fmt pass. | **UNVERIFIED** | Actual `terraform/` layout may differ from spec; audit needed. |
| **P3.10** | PR review and merge | Phase PR approved/merged. | **PENDING** | No phase-specific review/merge proof. |

### Phase 4 — Terraform environments

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P4.1** | DEV thin root stack | Remote backend `dev.tfstate`, provider, modules, typed vars, outputs, tfvars, RG data, tags. | **PARTIAL** | DEV Terraform works; exact module architecture and tags not yet audited. |
| **P4.2** | Network module | Dev 10.10.0.0/16, prod 10.20.0.0/16, /22 AKS subnet, input CIDR validation. | **UNVERIFIED** | Existing network created, exact CIDRs differ from prior lab examples; compare state/config. |
| **P4.3** | Monitoring module | Log Analytics 30-day retention and appropriate daily quota in both environments. | **UNVERIFIED** | No verified module/application evidence. |
| **P4.4** | AKS configuration | Pinned k8s version, Free tier, autoscaler, overlay CNI+network policy, Entra/Azure RBAC, disable local accounts, app routing, OMS, AcrPull and scoped deploy roles; running readiness proof. | **PARTIAL** | DEV AKS deployed; known network policy/Azure RBAC gaps recorded. DEV AKS verified Running/Succeeded on October 30, 2026; remaining configuration gaps require review. |
| **P4.5** | Terraform outputs | Cluster and RG listed in `terraform output`. | **UNVERIFIED** | Not yet captured. |
| **P4.6** | DEV no-drift proof | Terraform plan immediately after DEV apply shows zero change. | **PARTIAL** | Prior DEV plan 0/0/0 reported; revalidate targeted stack and drift. |
| **P4.7** | PROD plan without local apply | Prod is thin copy of dev differing only tfvars/backend key; plan passes; do not apply locally. | **PARTIAL** | PROD plan 9 add/0 change/0 destroy; module parity needs audit; not applied. |
| **P4.8** | Cost lifecycle | `az aks stop/start` documented in runbook; DEV stopped. | **PARTIAL** | DEV AKS verified Running/Succeeded on October 30, 2026; confirm stop/start procedures in the runbook before lifecycle acceptance. |
| **P4.9** | PR approval/merge | Phase PR reviewed and merged. | **PENDING** | No complete evidence. |

### Phase 5 — Kubernetes manifests

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P5.1** | Base manifests | Namespace, Deployment, Service, HPA, Ingress, Kustomization rendered. | **PARTIAL** | `kubernetes/base` exists; verify all expected objects and namespace naming deviation. |
| **P5.2** | Thin dev/prod overlays | ConfigMap generation, HPA range, ingress host, prod-only PDB, tag via Kustomize images; compare render diff. | **PARTIAL** | Overlays exist; full parity validation pending. |
| **P5.3** | ConfigMap rollout behavior | Env config mounted and change triggers pod rollout via hashed Kustomize name. | **PARTIAL** | ConfigMap mounted with `subPath`; this does not auto-update existing pod; hashed name change behavior unverified. |
| **P5.4** | Resources and probes | Requests 50m/64Mi limits 200m/128Mi; readiness and liveness healthz; describe pod proof. | **PASS — live pod verified** | October 30, 2026: kubectl describe pod verified Running/Ready, zero restarts, CPU request 50m and limit 200m, memory request 64Mi and limit 128Mi, readiness /healthz every 5 seconds, liveness /healthz every 10 seconds, RuntimeDefault seccomp, and no warning events. |
| **P5.5** | Pod hardening | Nonroot, RO rootfs, tmp writable, no privilege escalation/caps, RuntimeDefault; live pod proof. | **PASS — live Deployment configuration** | October 30, 2026: kubectl verified runAsNonRoot=true, runAsUser=101, runAsGroup=101, readOnlyRootFilesystem=true, allowPrivilegeEscalation=false, capabilities.drop=[ALL], seccompProfile=RuntimeDefault, and three writable emptyDir volumes for nginx. Running pod azure-devops-web-5d9f74b467-hnr8h independently confirmed UID/GID 101, non-root execution, read-only root filesystem, no privilege escalation, all capabilities dropped, and RuntimeDefault seccomp. |
| **P5.6** | HPA and prod PDB | CPU 50%, dev 1–3/prod 2–6, prod PDB minAvailable 1, maxUnavailable 0; HPA CPU known. | **PARTIAL — DEV verified** | E008 confirms live DEV HPA CPU 2%/50%, replica limits 1–3, and active metrics. PROD HPA/PDB not deployed under facilitator-approved EX001. Live kubectl verification confirmed DEV Deployment rollingUpdate.maxUnavailable=0 on October 30, 2026. |
| **P5.7** | Ingress | Web app routing ingress class and host resolves site in browser. | **UNVERIFIED** | Not yet evidenced. |
| **P5.8** | Manual deploy script | `scripts/deploy.sh <env> <sha>` and smoke test successfully deploy DEV. | **UNVERIFIED** | Previous DEV CD succeeded using inline commands; script acceptance pending. |
| **P5.9** | HPA scale demonstration | `hey` load scales 1 -> >=2 -> 1; changing hostnames and evidence saved. | **PARTIAL — autoscaling and load balancing PASS** | October 30, 2026: Controlled 120-second CPU workload triggered HPA scale-out 1 to 3 replicas; Kubernetes SuccessfulRescale events confirmed automatic scale-out and subsequent scale-in 3 to 1. A second test reached 400% CPU utilization against the 50% target and scaled to 3 healthy pods. Thirty HTTP requests through the ClusterIP Service /whoami endpoint returned three distinct pod hostnames (15, 4, and 11 responses), proving multi-pod routing. Original hey-based test remains unverified. |
| **P5.10** | Strict manifest validation | Kustomize outputs both pass kubeconform -strict -summary. | **UNVERIFIED** | Kustomize validated; kubeconform strict proof absent. |
| **P5.11** | PR review, merge and CP2 | Buddy approves/merges phase; CP2 demonstrates DEV + HPA + Terraform. | **PENDING** | Checkpoint not verified; DEV AKS verified Running/Succeeded on October 30, 2026. |

### Phase 6 — CI pipelines

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P6.1** | Workflow discipline | Top-level read permissions, per-PR concurrency with cancellation, major action pins; actionlint green. | **PARTIAL** | CI has contents:read; concurrency and actionlint not verified. |
| **P6.2** | Lint job | HTMLHint, Hadolint, strict kubeconform DEV/PROD; deliberate lint failure makes job fail. | **PARTIAL** | `make lint` passed in CI; other linters/negative test pending. |
| **P6.3** | Build-test-scan job | Buildx and GHA cache, APP_VERSION SHA, amd64, RO smoke.sh, Trivy critical failure; negative health test and cache evidence. | **PARTIAL** | CI builds amd64 image and runs inline health; full prescribed implementation absent/unverified. |
| **P6.4** | Gitleaks job | Scan PR commits and pass. | **UNVERIFIED** | No secret-scan job evidence. |
| **P6.5** | Infrastructure PR plans | Infra-triggered DEV+PROD OIDC matrix fmt/validate/tflint/Trivy/plan; publish plan summary; tag-change PR proof. | **UNVERIFIED** | Terraform validation CI passed; full plans/OIDC matrix not evidenced. |
| **P6.6** | Terraform deployment pipeline | After main push: apply DEV, plan PROD artifact, buddy approves prod, apply saved plan; no local PROD apply. | **UNVERIFIED** | PROD not deployed; pipeline cannot be accepted yet. |
| **P6.7** | Require status checks | Main requires checks that always run; negative smoke test blocks merge. | **BLOCKED** | GitHub private plan branch protection unsupported. |
| **P6.8** | Reviewed PR merged | Approved and merged Phase 6 PR. | **PENDING** | Not verified. |

### Phase 7 — Continuous deployment

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P7.1** | Single promotion pipeline | On site/Dockerfile/manifests change, build once, deploy/verify DEV, reviewer approves, promote SAME digest/SHA to PROD. | **PARTIAL** | DEV CD exists; PROD manual workflow separate; parity with specified automatic promotion unverified. |
| **P7.2** | Never rebuild for PROD | Verify ACR tag/digest; replay older PROD deployment without rebuilding. | **PARTIAL** | PROD release workflow validates published digest; live replay pending. |
| **P7.3** | Automatic rollback proven | Bad readiness/release turns run red, DEV old version still serves, PROD untouched. | **PASS — DEV-only demo scope** | E005–E007 in `docs/evidence.md`: PR #22 caused a failed rollout; CD run `41082536256` triggered automatic rollback; DEV recovered to 1/1 READY. PR #23 cleanup deployment succeeded. PROD not provisioned under EX001. |
| **P7.4** | Serialize deployments | Per-environment concurrency, cancel-in-progress false; prove queued deploys. | **PARTIAL** | DEV workflow concurrency set; PROD and double-merge proof pending. |
| **P7.5** | Reviewed PR merged | Phase 7 PR approved and merged. | **PENDING** | PR #5 open. |

### Phase 8 — Observability and incident drill

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P8.1** | Working log queries | `ContainerLogV2` + `KubePodInventory` queries saved in `docs/queries.kql` and both return rows. | **UNVERIFIED** | No query output shown. |
| **P8.2** | Terraform crash alert | Alert v2 >3 restarts/15 min; email action group; DEV and PROD via pipeline. | **UNVERIFIED** | Not verified; PROD not deployed. |
| **P8.3** | DEV crash-loop exercise | Deliberate busybox crash, troubleshoot via runbook, restore, alert email, zero outage, screenshot/log proof. | **UNVERIFIED** | Do only after approval/DEV startup. |
| **P8.4** | Final hardening | No fixable criticals, clean full-history Gitleaks, no `latest`, permissions each workflow, no subscription-scope role grants. | **UNVERIFIED** | Complete hardening evidence not gathered. |
| **P8.5** | Reviewed PR merged | Buddy review and merge. | **PENDING** | Not verified. |

### Phase 9 — Documentation, demo and teardown

| ID | Requirement | Done when / exact verification | Status | Evidence or outstanding work |
|---|---|---|---|---|
| **P9.1** | Architecture documentation | Azure + traffic diagram, CI/CD diagram, identity access table; buddy can explain release chain. | **PARTIAL** | README diagram exists; required `docs/architecture.md` audit pending. |
| **P9.2** | Two ADRs | Two Context/Decision/Consequences ADRs in `docs/adr/` merged. | **UNVERIFIED** | Not confirmed. |
| **P9.3** | Operational runbook | All operational and troubleshooting procedures with tested commands and buddy review. | **PARTIAL** | `docs/operations-runbook.md` referenced; required content and execution audit pending. |
| **P9.4** | 15-minute demo | Problem/architecture, PR->DEV->approval->PROD, HPA, failed release rollback, Q&A. | **PENDING** | Demo not conducted. |
| **P9.5** | Facilitator acceptance | Eight acceptance checks and >=70/100 scored by facilitator. | **PENDING** | Not yet attempted. |
| **P9.6** | Post-signoff teardown | After explicit approval, destroy PROD/DEV/bootstrap safely; evidence of empty groups and cost in `docs/evidence.md`. | **PENDING** | Never tear down without user signoff. |

## Milestone / checkpoint reviews

| Milestone | Timing | Evidence required | Status |
|---|---|---|---|
| CP1 | After Phase 2 | Local site container + protected main + reviewer meeting | PENDING — technical evidence collected; reviewer meeting and sign-off not completed |
| CP2 | After Phase 5 | DEV AKS app, HPA load evidence, Terraform walkthrough | PENDING |
| Demo | After Phase 9 | 15-minute live walkthrough + facilitator final acceptance | PENDING |

## Eight final acceptance tests (ALL eight required)

| ID | Facilitator check | Status | Evidence |
|---|---|---|---|
| **A1** | Heading PR: CI green, DEV updated <=15 minutes, PROD updated after approval | **PENDING** | — |
| **A2** | Healthz removed PR: smoke test red and cannot merge | **PENDING** | — |
| **A3** | Wrong readiness probe: pipeline red, DEV old version remains, PROD untouched | **PENDING** | — |
| **A4** | DEV and PROD Terraform pipeline plans show no drift | **PENDING** | — |
| **A5** | DEV HPA scales to >=2 pods under load | **PENDING** | — |
| **A6** | Repo/history/settings show no long-lived credentials or passwords | **PENDING** | — |
| **A7** | Engineer can explain three selected Terraform, manifest and workflow lines | **PENDING** | — |
| **A8** | Rollback PROD one revision using only runbook | **PENDING** | — |

## Grading (>=70/100 AND 8/8 acceptance checks)

| Area | Points | Evidence to collect |
|---|---:|---|
| CI/CD | 25 | Full lint/build/smoke/scan/push/DEV->PROD approval/rollback + OIDC |
| Terraform | 25 | Shared modules, remote state, role scoping, PROD only via pipeline, zero drift |
| Kubernetes | 20 | Probes/limits/HPA/PDB/ConfigMaps/non-root/read-only |
| Docs and demo | 15 | Architecture/identity diagram, 2 ADRs, tested runbook, live demo |
| Docker | 10 | Multistage, nonroot, amd64, <50 MB, no fixable critical CVEs |
| Security and operations | 5 | Gitleaks history, working alert, tested failure drill |

## Known deviations and decision log

| Item | Assignment expectation | Current deviation / open decision |
|---|---|---|
| GitHub visibility | Internal repo, protected main | Private personal repo; plan blocks required protection |
| Buddy reviews | CODEOWNERS you + buddy, actual approval | Karthik placeholder only; username needed |
| Repo layout | Root Dockerfile, `k8s/`, `infra/envs/`, etc. | `site/Dockerfile`, `kubernetes/`, `terraform/environments/`; must map requirements to implemented structure or refactor |
| Image stamp | `APP_VERSION` build argument | Docker currently uses `GIT_SHA`; decide to align before Phase 2 signoff |
| ConfigMap rollout | Kustomize generator hash changes Deployment reference | Static ConfigMap + `subPath` mount; pod rollout behavior needs correction/proof |
| CD promotion | One build -> DEV -> approval -> same image PROD | Separate DEV CD and manually dispatched PROD release; assess equivalence with facilitator |
| Repo security | secret scanning + push protection | Secret scanning disabled; availability or accepted substitute needed |
| Azure cost/quota | Enough regional DSv5 capacity | Free Trial regional quota issue; PROD not provisioned |

## Next actions (do not skip acceptance gates)

1. **Confirm PR #5 CI:** Already observed both checks PASS at head `8ab5e4c`; preserve URL in `docs/evidence.md`.
2. **Complete Phase 2 audit and fixes:** digest pinning, size, user, architecture, read-only container, smoke.sh (both correct/wrong SHA), Trivy/Hadolint.
3. Audit Phase 0 and outstanding Phase 1 governance, then evaluate Phases 3–9 sequentially using exact evidence.
4. Resolve Karthik GitHub username and determine a workable plan for branch protection and approval before merge.
5. No merge, DEV AKS start, PROD apply, or teardown without explicit user approval.

## Evidence entry template

```text
Date (UTC):
Criterion: P?.?
Commit / branch:
Command or workflow URL:
Expected:
Actual:
Evidence file / PR URL:
Result: PASS | PARTIAL | UNVERIFIED | BLOCKED | PENDING
Owner / reviewer:
```
