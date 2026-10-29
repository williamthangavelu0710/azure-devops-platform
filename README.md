# Azure DevOps Platform

## Project Information

| Field | Value |
|---|---|
| Owner | William Thangavelu |
| Initials | WT |
| Azure Region | East US (`eastus`) |
| GitHub Repository | `williamthangavelu0710/azure-devops-platform` |
| Environments | DEV and PROD |
| Repository Visibility | Private |


A production-inspired DevOps capstone demonstrating infrastructure as code, containerization, Kubernetes orchestration, secure CI/CD, and automated application deployment on Microsoft Azure.

## Technology Stack

| Category | Technologies |
|---|---|
| Cloud Platform | Microsoft Azure |
| Infrastructure as Code | Terraform |
| Containerization | Docker |
| Container Registry | Azure Container Registry (ACR) |
| Container Orchestration | Azure Kubernetes Service (AKS) |
| Kubernetes Configuration | Kustomize |
| CI/CD Automation | GitHub Actions |
| Authentication | Microsoft Entra ID, OpenID Connect (OIDC) |
| Security | Trivy, Microsoft Entra ID, Kubernetes RBAC |
| Web Application | NGINX |
| Version Control | Git and GitHub |

## Environments

- **Development (DEV):** Provisioned and successfully deployed to Azure AKS.
- **Production (PROD):** Terraform and Kubernetes configuration prepared for future deployment; not provisioned.

## Architecture

```mermaid
flowchart TD
    A[Developer] --> B[GitHub Repository]
    B --> C[GitHub Actions CI]
    C --> D[Lint, Build and Security Scan]
    D --> E[CI Test Image]
    D --> G[Successful CI Triggers CD]
    G --> P[Build and Publish SHA-Tagged Image]
    P --> F[Azure Container Registry]

    G --> H[Microsoft Entra ID / OIDC]
    H --> I[Azure Kubernetes Service]
    F --> I

    T[Terraform] --> V[Azure Virtual Network]
    T --> I
    T --> F
    T --> M[Managed Identities and RBAC]

    I --> K[DEV Namespace]
    K --> L[NGINX Web Application]
[200~


```

## Deployment Architecture

- **Terraform:** Provisions Azure networking, AKS, ACR, and managed identities.
- **GitHub Actions CI:** Validates application and infrastructure code.
- **Azure Container Registry:** Stores the versioned Docker image.
- **GitHub Actions CD:** Uses OIDC authentication and Kustomize to deploy to AKS.
- **AKS:** Hosts the NGINX application in the `dev` namespace.
- **Kubernetes RBAC:** Restricts deployment permissions to the required namespace.

## Validation Results

- GitHub Actions CI workflow completed successfully.
- Azure OIDC authentication from GitHub Actions succeeded.
- Kubernetes authentication and DEV deployment permissions were verified.
- Automated deployment through Kustomize completed successfully.
- Kubernetes Deployment rollout completed successfully.
- Application pod reached `1/1 Running` with zero restarts.
- An HTTP request inside the NGINX container returned the expected application HTML.
- AKS was stopped after validation to reduce compute costs.


## Security Findings and Engineering Decisions

The Terraform configuration is scanned using Trivy as part of GitHub Actions CI. The infrastructure scan reports HIGH and CRITICAL findings without blocking the pipeline. These findings have been reviewed but are not all remediated.

| Finding | Current State | Decision |
|---|---|---|
| AZU-0041: AKS API server access | Public API endpoint without authorized IP restrictions | Open. Evaluate private cluster access or authorized IP ranges while accounting for GitHub-hosted runners. |
| AZU-0042: Azure RBAC authorization | Microsoft Entra authentication enabled; Azure RBAC for Kubernetes authorization disabled | Retain Kubernetes RBAC with namespace-scoped deployment permissions. Document as an intentional authorization design. |
| AZU-0043: Kubernetes network policy | Azure CNI Overlay with Azure dataplane; network policy disabled | Open. Defer Cilium migration until disruption, compatibility, and rollback planning are completed. |

### CI/CD Security Controls

- GitHub Actions authenticates to Azure using OIDC instead of a stored Azure client secret.
- The deployment identity uses Kubernetes RBAC permissions scoped to the existing `dev` namespace.
- The CD workflow checks deployment permissions before applying Kubernetes manifests.
- The CD workflow verifies Deployment rollout status after applying manifests.
- Trivy scans the application container image and Terraform configuration.
- Terraform state and sensitive local files are excluded from Git.

### Security Limitations

This is a production-inspired learning environment, not a production-hardened deployment. Public API access and missing Kubernetes network-policy enforcement remain known risks. Successful CI validation does not mean the infrastructure is free of security findings.

### Operational Cost Management

The AKS cluster is stopped when not required for testing to reduce compute costs. Other Azure resources, including container registry and storage, may continue to incur charges.

## Latest Verification Status

- **GitHub Actions CI:** Successfully validated the PR #2 merge on `main` (run `40715157022`).
- **Application validation:** Build and container image security checks passed.
- **Infrastructure validation:** Terraform checks passed; Trivy infrastructure findings remain documented.
- **Kustomize validation:** DEV manifests rendered successfully with one Deployment and one Service in the `dev` namespace, using ACR image `azure-devops-web:v3`.
- **Live CD validation:** Automatic GitHub Actions run `40664894813` completed successfully using Azure OIDC authentication, Kubernetes authorization checks, Kustomize deployment, and rollout verification.
- **Kubernetes verification:** Deployment `azure-devops-web` reported `1/1` available; application Pod reported `1/1 Running` with zero restarts.
- **Application HTTP validation:** Successfully retrieved the NGINX application HTML from inside the running Pod, confirming `Deployment Successful!`.
- **AKS power state:** Confirmed `Stopped` after final validation to reduce compute costs.


### Deployment Prerequisites

The DEV AKS cluster must be running before application deployment.

The `dev` namespace and required Kubernetes RBAC resources must exist in the cluster. Their RBAC configuration is version-controlled at:

`kubernetes/rbac/dev/github-actions-deployer.yaml`

The CD workflow does not automatically bootstrap these prerequisites.

### Automated CI/CD Pipeline

GitHub Actions provides automated CI/CD for the DEV environment.

**Continuous Integration (`ci.yml`)**

Runs on pull requests targeting `main` and pushes to `main`.

The pipeline performs application validation, Docker image builds, health checks, container vulnerability scanning, Terraform validation, and infrastructure security scanning.

**Continuous Deployment (`cd.yml`)**

Runs after a successful CI workflow triggered by a push to `main`.

The workflow:

1. Checks whether application or DEV Kubernetes deployment files changed.
2. Skips application deployment for unrelated changes.
3. Authenticates to Azure using Microsoft Entra ID and OIDC.
4. Builds and publishes a Git-SHA-tagged Docker image to Azure Container Registry.
5. Authenticates to AKS and verifies Kubernetes permissions.
6. Deploys the DEV Kustomize configuration.
7. Verifies rollout status and attempts rollback if rollout verification fails.

The deployment gate is configured but its runtime behavior still requires verification.

**Important:** AKS is intentionally stopped to control costs. Application changes should not be merged into `main` until the cluster is started and ready for deployment.

### Verified Deployment

- Successful automatic CD run: `40664894813`
- Application: `azure-devops-web`
- Namespace: `dev`
- Deployment reached `1/1` available
- Application health endpoint `/healthz` returned HTTP `200 OK`
- Kubernetes HPA and ConfigMap were verified
- AKS was stopped after successful testing

### Operations and Troubleshooting

See the [Operations Runbook](docs/operations-runbook.md) for cluster lifecycle management, deployment verification, application health checks, troubleshooting, rollback, security controls, and operational handoff procedures.

### Production Readiness

The DEV environment has been successfully deployed and tested.

The PROD environment has not been provisioned. Production promotion, security hardening, and live rollback failure testing remain future work.
