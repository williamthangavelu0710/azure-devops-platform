# Azure DevOps Platform - 15-Minute DEV-Only Demo Runbook

## Scope and preparation
Facilitator Karthik approved a DEV-only demonstration on October 29, 2026. Separate PROD provisioning and the approval/promotion stage are excluded from the demo. This is a scope exception, not proof of PROD implementation.

AKS is intentionally stopped for cost control. Do not start AKS, merge a PR, deploy, or change Azure resources without explicit authorization. Confirm any live steps before the presentation.

## 0-2 minutes - Problem and architecture
Explain repeatable, secure application delivery to Azure Kubernetes Service. Walk through Terraform, GitHub Actions, OIDC, Azure Container Registry, AKS, Kubernetes Service, Ingress, and HPA.

References: docs/architecture.md, ADR-001, ADR-002.

## 2-7 minutes - Pull request, CI, and DEV delivery
Show GitHub PR #33 and its successful Terraform and application CI checks. Explain the intended PR-to-DEV delivery path, image build and scan, ACR publication, and Kubernetes deployment verification.

Evidence: E002, E003, E004, E007, E009, E012. PR #33 is documentation-only and does not prove a new DEV deployment. E012 records a post-merge CD failure while AKS was stopped. Do not claim a successful latest deployment.

## 7-10 minutes - Kubernetes health and autoscaling
Explain readiness/liveness probes, resource requests and limits, HPA target of 50 percent CPU, and replica range 1-3. Show E010 evidence for CPU-triggered scale-out from one to three replicas and scale-in to one. Explain the 30-request Service load-balancing test across three pod hostnames.

The Service test does not establish browser-visible hostname changes. The original hey-based test was not performed.

## 10-13 minutes - Failed release and recovery
Show PR #22 and CD run 41082536256. Explain how the intentionally incorrect readiness probe returned HTTP 404, rollout verification failed, and automatic DEV rollback restored the previous healthy revision. Show E005-E007 evidence.

Do not repeat the failed release live without explicit authorization.

## 13-15 minutes - Operations, limitations, and Q&A
Explain kubectl metrics, application logs, security controls, Terraform no-drift evidence, and operational runbook. Disclose that centralized Prometheus/Grafana and alerting were not verified. Ingress browser routing and the latest post-merge DEV deployment also require verification.

Request facilitator acceptance against the DEV-only adapted scope. Do not claim eight acceptance checks passed without corresponding evidence and facilitator sign-off.

## References
- docs/evidence.md: E001-E012
- docs/architecture.md
- docs/operations-runbook.md
- docs/capstone-master-checklist.md
- docs/adr/ADR-001-dev-only-aks-architecture.md
- docs/adr/ADR-002-oidc-and-kubernetes-rbac.md
