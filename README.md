# Azure DevOps Platform

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
    D --> E[Docker Image]
    E --> P[Separate Image Publication Step]
    P --> F[Azure Container Registry]

    B --> G[GitHub Actions CD]
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

- **GitHub Actions CI Run #24:** Successful on commit `7c12246`.
- **Application validation:** Build and container image security checks passed.
- **Infrastructure validation:** Terraform checks passed; Trivy infrastructure findings remain documented.
- **Kustomize validation:** DEV manifests rendered locally with one Deployment and one Service in the `dev` namespace, using ACR image `azure-devops-web:v3`.
- **Previous live CD validation:** OIDC authentication, Kubernetes deployment, application rollout, and HTTP response succeeded before the latest workflow changes.
- **Current live CD validation:** Pending. The updated authorization check and rollout verification still require an end-to-end test.
- **AKS power state:** Stopped after earlier validation to reduce compute costs.

### Deployment Prerequisites

The `dev` namespace and its Kubernetes RBAC Role/RoleBinding must already exist before running the CD workflow. Namespace creation is intentionally excluded from the application deployment overlay.

The CD workflow is manually triggered and deploys an existing versioned container image from ACR. Image publication to ACR is currently a separate step rather than an automatic CI-to-ACR release.
