# ADR-001: DEV-Only AKS Architecture

**Status:** Accepted for capstone demonstration
**Date:** 2026-10-31

## Context

The original capstone specification required separate DEV and PROD Azure Kubernetes Service environments, including a deployment approval and promotion workflow.

Azure Free Tier subscription quotas and cost constraints limited the feasibility of deploying both environments.

On October 29, 2026, facilitator Karthik approved a DEV-only demonstration and waived the PROD approval/promotion stage for the final demo.

## Decision

Deploy and demonstrate one AKS DEV environment.

The platform will demonstrate:
- Terraform-managed Azure infrastructure
- GitHub Actions CI/CD
- Azure OIDC authentication
- Azure Container Registry
- Kubernetes deployment, health probes, and HPA
- NGINX Ingress routing
- Deployment verification and rollback

The PROD environment will not be provisioned for the capstone demonstration.

## Consequences

### Positive
- Reduces Azure resource consumption and cost.
- Preserves the core CI/CD and Kubernetes learning objectives.
- Allows live demonstration of application delivery, scaling, routing, and recovery.

### Trade-offs
- No independently deployed PROD environment.
- No live DEV-to-PROD promotion or approval demonstration.
- Production parity and promotion controls remain unverified.

## Operational Considerations

Stop the DEV AKS cluster when it is not required for testing or demonstration.

The DEV-only approach is a facilitator-approved exception, not evidence that the original PROD acceptance criteria were completed.
