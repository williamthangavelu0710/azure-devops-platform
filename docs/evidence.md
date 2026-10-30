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
