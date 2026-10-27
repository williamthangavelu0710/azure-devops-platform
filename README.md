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
| Security | Trivy, Azure RBAC, Kubernetes RBAC |
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
    E --> F[Azure Container Registry]

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

