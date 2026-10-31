# Azure DevOps Platform — Verification Evidence

This document records technical verification results and approved
scope exceptions for the DEV-only capstone.

## Verified results — October 29, 2026

### E001 — Terraform network module migration
- Result: PASS
- Environment: DEV
- Verification: Terraform plan reported zero additions, changes, or destruction.
- State migration: Three expected resource address moves.
- Post-migration: Terraform formatting, validation, and refreshed no-drift plan passed.
- Infrastructure impact: No Azure resources added, changed, or destroyed.

### E002 — GitHub pull request and CI
- Result: PASS
- Pull request: https://github.com/williamthangavelu0710/azure-devops-platform/pull/14
- Merge commit: 4fdc46e301e839023db8959e0c33151778ec9564
- Required CI checks: Both passed.
- Review exception: Temporary solo-developer exception; no independent approval.
- Branch protection: One required approval restored after merge.

### E003 — GitHub Actions Azure OIDC
- Result: PASS
- Workflow: DEV OIDC Authentication Test
- Run: https://github.com/williamthangavelu0710/azure-devops-platform/actions/runs/40973658957
- Azure login: Successful.
- Subscription verification: Successful.
- Authentication method: OIDC without a stored client secret.

### E004 — Post-merge CI/CD
- Result: PASS
- CI run: https://github.com/williamthangavelu0710/azure-devops-platform/actions/runs/40973503034
- CD run: https://github.com/williamthangavelu0710/azure-devops-platform/actions/runs/40973564599
- CI: Successful.
- Deployment change detection: Successful.
- Deploy to DEV: Skipped.
- DEV_DEPLOY_ENABLED: false at verification.

## Facilitator-approved demo scope exceptions

### EX001 — DEV-only environment
- Facilitator: Karthik
- Approval reported: October 29, 2026
- Original requirement: Separate DEV and PROD environments.
- Approved demo scope: DEV-only deployment due to Azure Free Tier limitations.
- Separate PROD provisioning is not required for the final demo.
- This is a demo scope exception, not evidence that PROD requirements were implemented.

### EX002 — CI/CD approval and promotion
- Facilitator: Karthik
- Approval reported: October 29, 2026
- Original requirement: Approval and promotion from DEV to PROD.
- Approved demo scope: No separate PROD promotion or approval step.
- Remaining focus: PR, CI, image build/scan, ACR, DEV deployment,
  verification, HPA, monitoring, and rollback.

## Outstanding verification

- Live DEV deployment through GitHub Actions.
- ACR image publication and deployed image verification.
- Kubernetes readiness, liveness, and security controls.
- HPA scaling under load.
- Monitoring and incident evidence.
- Deliberately failed release and rollback verification.
- Architecture documentation and final demonstration.

## Evidence policy

PASS means verified by an actual test or supported command output.
PARTIAL means implemented but not fully verified.
PENDING means further work is required.
EXCEPTION means a facilitator-approved change to the original scope.

## Additional verification — October 30, 2026

### E005 — Deliberately failed DEV release
- Result: PASS
- Pull request: https://github.com/williamthangavelu0710/azure-devops-platform/pull/22
- CD run: https://github.com/williamthangavelu0710/azure-devops-platform/actions/runs/41082536256
- Test: Changed the Kubernetes readiness probe to /rollback-test-failure.
- Kubernetes returned HTTP 404 for the readiness probe.
- GitHub Actions detected the unsuccessful rollout and failed the deployment.

### E006 — Automatic rollback
- Result: PASS
- Workflow reported: DEV rollout failed. Restoring previous revision.
- Kubernetes Deployment recovered to 1/1 READY and 1 AVAILABLE.
- Readiness probe restored to /healthz.
- Previously healthy application image restored.
- This verifies automatic rollback in the DEV environment.

### E007 — Cleanup deployment
- Result: PASS
- Cleanup pull request: https://github.com/williamthangavelu0710/azure-devops-platform/pull/23
- Successful CD run: https://github.com/williamthangavelu0710/azure-devops-platform/actions/runs/41084850474
- Deployment revision: 7
- Image tag: bf93a992deb38016c9cc0b5ac0693ad7d132b828
- Application pod: azure-devops-web-5d9f74b467-hnr8h
- Deployment READY: 1/1
- Readiness endpoint: /healthz
- GitHub branch protection restored to one required approval.

### E008 — Kubernetes HPA and resource metrics
- Result: PASS for current HPA health and metrics.
- HPA: azure-devops-web
- Namespace: dev
- CPU utilization: 2% against a 50% target.
- Minimum replicas: 1
- Maximum replicas: 3
- Current replicas: 1
- AbleToScale: True
- ScalingActive: True
- ScalingLimited: False
- kubectl top pods successfully returned CPU and memory metrics.
- Earlier temporary HPA metric warnings were observed during pod replacement.
- No newer warnings appeared in the subsequent namespace event listing.
- Historical load-test scaling evidence should be documented separately.

## Remaining documentation and acceptance work — October 30, 2026

- Review architecture documentation and diagrams.
- Review operational runbook against implemented DEV workflows.
- Verify ADR requirements and record approved deviations.
- Review security hardening and incident-monitoring requirements.
- Consolidate HPA load-test evidence.
- Prepare and rehearse the 15-minute DEV-only demonstration.
- Obtain facilitator acceptance under the approved DEV-only scope.
- Perform infrastructure teardown only after explicit authorization.

### E009 — PR #25 acceptance checklist merge and review-control restoration

**Date:** October 30, 2026

- **Pull request:** https://github.com/williamthangavelu0710/azure-devops-platform/pull/25
- **Result:** Merged into `main`.
- **Post-merge CI:** Run `41136448478` — success.
- **Post-merge CD:** Run `41136520172` — success.
- **Deployment behavior:** `Detect DEV Deployment Changes` succeeded; `Deploy to DEV` was skipped because this was a documentation-only change.
- **Solo-operator review exception:** With operator authorization, temporarily changed `required_approving_review_count` from `1` to `0` to merge PR #25.
- **Restoration:** Immediately after merging, restored `required_approving_review_count=1`, with stale-review dismissal enabled.
- **Limitation:** PR #25 was merged without an independent approving review under the documented temporary exception. This is not equivalent to satisfying the original reviewer-approval acceptance criterion.
- **Azure impact:** No infrastructure changes were made through this documentation update. DEV AKS was last verified `Running / Succeeded`.

### E010 — Live HPA scaling, load balancing, and operational health

**Date:** October 30, 2026

- **Environment:** Azure AKS, namespace `dev`.
- **Result:** PASS for CPU-triggered autoscaling, multi-pod Service routing, resource metrics, logs, and live pod health.
- **HPA scale-out:** A controlled 120-second CPU workload in the existing NGINX container triggered automatic scaling from 1 to 3 replicas.
- **HPA scale-in:** Kubernetes recorded `SuccessfulRescale` back to 1 replica after CPU utilization decreased.
- **Second scaling test:** HPA reached 400% CPU utilization against its 50% target and scaled to 3 healthy replicas.
- **Service load balancing:** Thirty HTTP requests to `http://azure-devops-web.dev.svc.cluster.local/whoami` returned three distinct pod hostnames, with response counts of 15, 4, and 11.
- **Resource monitoring:** `kubectl top pods -n dev` returned CPU and memory usage for all three application pods.
- **Application logs:** `kubectl logs -n dev deployment/azure-devops-web --tail=20` returned NGINX access logs.
- **Pod health:** `kubectl describe pod` confirmed Running/Ready, zero restarts, configured CPU/memory requests and limits, readiness and liveness probes on `/healthz`, and no warning events.
- **Cluster health:** The inspected application and system pods were Running with zero restarts.
- **Limitations:** The original `hey`-based scaling test was not performed; CPU stress was used instead. Centralized monitoring, managed Prometheus/Grafana, and alerting were not implemented or verified. The load-balancing test demonstrates Kubernetes Service routing, not browser-visible hostname changes.
- **Infrastructure impact:** No infrastructure configuration changes were made during documentation updates.

## E011 — Final Technical Validation and CP2 Readiness (October 30, 2026)

### Kubernetes manifest validation
- Original strict validation: 12/12 resources passed.
- Updated DEV overlay: 5/5 resources passed kubeconform strict validation.
- Updated PROD overlay: 6/6 resources passed kubeconform strict validation.
- PROD validation was local only; no PROD environment was deployed.

### P5.7 — Ingress
- Base Ingress manifest created with nginx ingressClassName.
- DEV hostname: azure-devops.local.
- PROD placeholder hostname: azure-devops-prod.example.com.
- Both overlays rendered and passed strict schema validation.
- Live Ingress controller availability, DNS resolution, and browser routing remain unverified.

### P5.8 — Manual deployment
- scripts/deploy.sh created for DEV-only deployment.
- Bash syntax validation passed.
- Invalid SHA and PROD deployment requests were rejected.
- Operator confirmation safeguard successfully cancelled an unauthorized deployment.
- Live manual deployment and smoke testing remain pending.

### P5.3 — ConfigMap rollout
- DEV ConfigMap generation uses Kustomize content-based hashing.
- Original hash: t974bd42kk.
- Modified configuration hash: c7kh6ggf54.
- Deployment references matched their corresponding generated ConfigMap names.
- Live pod rollout following a ConfigMap change remains pending.

### P5.1/P5.2 — Manifest and overlay acceptance
- DEV: namespace dev, HPA 1–3 replicas, CPU target 50%.
- PROD: namespace prod, HPA 2–6 replicas, CPU target 50%, PDB included.
- Both overlays passed strict schema validation.
- PROD is outside the facilitator-approved deployment scope.
- PROD ConfigMap remains static; DEV uses hashed generation.

### P5.11 — CP2 checkpoint readiness
- DEV application deployment and health previously verified.
- HPA scale-out, scale-in, and multi-pod routing previously demonstrated.
- Terraform infrastructure previously validated.
- PR #27 merged; no independent reviewer approval claimed.
- Facilitator CP2 acceptance remains pending.

### Infrastructure state
- AKS intentionally stopped to limit unnecessary runtime costs.
- No live deployment or infrastructure modification performed during these local checks.

## E012 — PR #28 Merge and Post-Merge Pipeline Verification (October 30–31, 2026)

### Pull request
- PR #28 successfully merged into main.
- Both pull-request CI checks passed.
- Main-branch CI run 41162577847 passed.
- Required approving review count restored to 1 after a temporary single-operator exception.
- No independent reviewer approval claimed.

### Post-merge deployment
- CD run 41162619398 failed at the Kubernetes authentication connectivity check.
- Error: Kubernetes API hostname could not be resolved.
- Azure CLI confirmed AKS power state: Stopped.
- AKS provisioning state: Succeeded.
- Failure is consistent with the intentionally stopped cluster.
- No successful post-merge DEV deployment claimed.

### Follow-up
- Keep AKS stopped for cost control.
- When live testing is authorized, restart AKS and verify deployment, smoke tests, and remaining live checks.
- Facilitator CP2 acceptance remains pending.

## E013 — Repository Credential and GitHub Actions Security Audit (October 31, 2026)

- Result: PASS for the security checks performed; A6 final acceptance pending facilitator review.
- Gitleaks version: 8.30.1.
- Full-history command: `gitleaks git --redact --no-banner --log-opts="--all" --exit-code=1`.
- Gitleaks scanned 78 commits and approximately 192.49 KB; no leaks found.
- GitHub repository-level Actions secrets: none configured.
- GitHub DEV environment secrets: none configured.
- GitHub PROD environment secrets: none configured.
- Repository Actions variable: `DEV_DEPLOY_ENABLED=true`; not a credential.
- DEV environment Actions variables: none configured.
- PROD environment variables: Azure client, subscription, and tenant identifiers; no passwords or client secrets identified.
- Default GitHub Actions workflow permissions: read.
- GitHub Actions pull-request review approval permission: disabled.
- CI workflow permissions: contents read.
- DEV CD and OIDC-test permissions: contents read and id-token write.
- PROD release permissions: contents read, actions read, and id-token write.
- No job-level permission overrides found by the workflow search.
- Azure OIDC authentication was previously verified in E003.
- Limitations: Gitleaks detection is not exhaustive. Organization-level secrets, external credential stores, and Azure identity role assignments were not independently audited in this check.
- Acceptance: A6 has supporting evidence but remains subject to facilitator review.
