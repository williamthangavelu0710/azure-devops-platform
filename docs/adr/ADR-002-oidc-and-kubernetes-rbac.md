# ADR-002: GitHub Actions OIDC and Kubernetes RBAC

**Status:** Accepted for capstone demonstration
**Date:** 2026-10-31

## Context

The Azure DevOps Platform requires GitHub Actions to authenticate with Azure, publish container images to Azure Container Registry (ACR), and deploy applications to Azure Kubernetes Service (AKS).

Storing long-lived Azure credentials in GitHub secrets introduces credential rotation and exposure risks.

Kubernetes deployment operations also require appropriate authorization.

During the October 30-31 deployment work, the CD pipeline failed because its Azure-authenticated identity lacked permission to access Kubernetes Ingress resources in the DEV namespace.

## Decision

Use GitHub Actions OpenID Connect (OIDC) federation for Azure authentication instead of storing long-lived Azure client secrets.

Use Azure identity and role assignments for authorized access to Azure resources.

Use namespace-scoped Kubernetes RBAC to authorize application deployment operations.

The DEV deployment Role includes permissions for the Kubernetes resources managed by the deployment pipeline, including Ingress resources.

The Ingress permissions are:

- API group: networking.k8s.io
- Resource: ingresses
- Verbs: get, list, watch, create, update, patch

The Role definition is maintained in:

kubernetes/rbac/dev/github-actions-deployer.yaml

## Consequences

### Positive

- Eliminates the need for long-lived Azure client secrets in GitHub Actions.
- Uses short-lived federated authentication.
- Restricts Kubernetes deployment permissions to the DEV namespace.
- Makes deployment authorization auditable through version-controlled YAML.
- Supports automated CI/CD deployment and verification.

### Trade-offs

- OIDC requires correctly configured federated credentials and Azure role assignments.
- Kubernetes RBAC must be updated when deployments introduce new resource types.
- Missing permissions can cause deployment failures.
- The version-controlled RBAC manifest must be applied during cluster setup or maintenance; the application CD workflow does not automatically reconcile it.

## Verification

On October 31, 2026:

- Kubernetes Ingress permissions were corrected in the live DEV Role.
- The permanent RBAC manifest was merged through PR #32.
- GitHub Actions CD run 41170890392 completed successfully.
- The AKS application Deployment reached 1/1 Ready.
- NGINX Ingress routing returned the expected application page.

## Operational Considerations

Review RBAC permissions whenever Kubernetes manifests introduce additional resource types.

Avoid granting unnecessary cluster-wide privileges.

Apply the version-controlled RBAC manifest during cluster setup or authorized maintenance.

Use GitHub Actions logs, kubectl authorization checks, and Kubernetes events to troubleshoot authorization failures.
