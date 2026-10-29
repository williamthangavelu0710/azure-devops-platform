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
