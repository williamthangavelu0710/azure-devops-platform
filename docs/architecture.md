# Azure DevOps Platform - Architecture

## 1. Purpose and Scope

This capstone demonstrates a production-inspired DevOps platform
built using Microsoft Azure, Terraform, Docker, Kubernetes,
Kustomize, GitHub Actions, and Microsoft Entra ID.

The platform automates infrastructure provisioning, application
validation, container image publishing, and deployment to AKS.

### Deployment Scope

DEV:
- Provisioned using Terraform.
- Deployed to Azure Kubernetes Service.
- Uses Azure Container Registry for container images.
- Supports automated CI/CD, health checks, HPA, and rollback.

PROD:
- Configuration exists for future deployment.
- Infrastructure has not been provisioned.
- Not included in the final demonstration.

### Facilitator-Approved Exceptions

On October 29, 2026, facilitator Karthik approved:
- A DEV-only demonstration due to Azure Free Tier limitations.
- Omitting the PROD approval and promotion stages.

These exceptions do not mean the original PROD requirements
were implemented or verified.

## 2. Azure Infrastructure Architecture

Terraform provisions and manages the Azure infrastructure.

Infrastructure components:

- Azure Resource Group: Organizes DEV resources.
- Azure Virtual Network: Provides network connectivity.
- Azure Kubernetes Service (AKS): Hosts the application.
- Azure Container Registry (ACR): Stores Docker images.
- Microsoft Entra ID: Provides identity and authentication.
- Azure Managed Identities: Support service-to-service access.

### Infrastructure Diagram

    Terraform
        |
        +-- Azure Resource Group
        |
        +-- Azure Virtual Network
        |
        +-- Azure Container Registry
        |       |
        |       +-- SHA-tagged Docker images
        |
        +-- Azure Kubernetes Service
                |
                +-- DEV Namespace
                        |
                        +-- NGINX Deployment
                        |       |
                        |       +-- Application Pods
                        |       +-- Readiness Probe
                        |       +-- Liveness Probe
                        |
                        +-- Kubernetes Service
                        |
                        +-- Horizontal Pod Autoscaler

### Application Traffic Flow

```text
HTTP Client (azure-devops.local)
    |
    v
NGINX Ingress Controller
    |
    v
Ingress Rule (host: azure-devops.local, path: /)
    |
    v
Kubernetes Service (port 80 -> targetPort 8080)
    |
    v
NGINX Application Pod (port 8080)
```

The Ingress controller routes matching HTTP requests to the DEV
Kubernetes Service, which forwards traffic to ready application pods.

### Application Deployment

The NGINX application runs inside the Kubernetes DEV namespace.

The Kubernetes Service provides connectivity to the application
pods. Readiness and liveness probes use the /healthz endpoint.

The Horizontal Pod Autoscaler uses CPU utilization to adjust
the number of application replicas.

Verified HPA configuration:
- Minimum replicas: 1
- Maximum replicas: 3
- Target CPU utilization: 50 percent

Container images are stored in ACR and deployed to AKS
using GitHub Actions and Kustomize.

## 3. CI/CD Pipeline Architecture

GitHub Actions automates application validation, image publishing,
and deployment to the DEV environment.

### Continuous Integration (CI)

A pull request triggers CI checks before merging.

CI workflow:
1. Developer opens a GitHub pull request.
2. GitHub Actions runs application and infrastructure checks.
3. Docker builds the application container.
4. Automated smoke tests validate the container.
5. Trivy scans for security vulnerabilities.
6. CI results are reported on the pull request.
7. Changes are merged after required checks pass.

### Continuous Deployment (CD)

A merge to the main branch triggers DEV deployment.

CD workflow:
1. GitHub Actions authenticates to Azure using OIDC.
2. Docker builds the application image.
3. The image is tagged using the Git commit SHA.
4. The image is pushed to Azure Container Registry.
5. Kustomize prepares the Kubernetes DEV manifests.
6. The updated application is deployed to AKS.
7. Kubernetes rollout verification checks deployment health.
8. A successful rollout completes the deployment.
9. A failed rollout triggers the rollback procedure.

### CI/CD Flow Diagram

    GitHub Pull Request
            |
            v
    GitHub Actions CI
            |
            v
    Build + Test + Trivy Scan
            |
            v
    Merge to Main
            |
            v
    GitHub Actions DEV CD
            |
            v
    Azure Authentication (OIDC)
            |
            v
    Build and Push Image to ACR
            |
            v
    Deploy to AKS DEV (Kustomize)
            |
            v
    Kubernetes Rollout Verification
            |
            +-- Success --> Healthy DEV Release
            |
            +-- Failure --> Rollback Procedure

### Deployment Scope

The final demonstration uses automatic deployment to DEV only.

A separate PROD deployment and manual promotion approval
are excluded under the facilitator-approved scope exception.

## 4. Security Architecture

The platform uses several security controls across GitHub,
Azure, container images, and Kubernetes.

### Identity and Access

- Microsoft Entra ID provides Azure identity management.
- GitHub Actions uses OIDC for Azure authentication.
- OIDC avoids storing long-lived Azure credentials in GitHub.
- Azure RBAC controls access to Azure resources.
- Kubernetes RBAC provides namespace-scoped permissions.

### Identity and Access Responsibilities

| Component | Responsibility | Access mechanism |
|---|---|---|
| GitHub Actions | Runs the DEV deployment workflow | GitHub workflow permissions and OIDC federation |
| Microsoft Entra ID | Authenticates the federated workflow identity | Short-lived OIDC-based authentication |
| Azure RBAC | Authorizes access to Azure resources, including ACR and AKS | Azure role assignments; exact scopes require separate audit |
| Kubernetes RBAC | Authorizes deployment operations in the DEV namespace | Namespace-scoped Role and RoleBinding |
| Kubernetes pod security context | Enforces non-root execution and container privilege restrictions | runAsNonRoot, runAsUser, readOnlyRootFilesystem, and restricted Linux capabilities |

### CI/CD Security

- GitHub Actions runs CI checks on pull requests; enforcement of branch protection rules is limited by the GitHub repository plan and requires separate verification.
- Pull requests provide a controlled integration workflow.
- Trivy scans container images for vulnerabilities.
- Git commit SHA tags support image traceability.
- Deployment verification detects unhealthy releases.

### Kubernetes Security

- Application workloads run in the DEV namespace.
- Readiness probes prevent unready pods from receiving traffic.
- Liveness probes detect unhealthy containers.
- Deployment rollback restores a previously healthy release.

### Known Security Limitations

The following limitations remain in the DEV environment:

- The AKS API endpoint is publicly accessible.
- Azure RBAC for Kubernetes authorization is not enabled.
- Kubernetes network policies are not enabled.
- A separate production environment is not deployed.

### Production Hardening Recommendations

Before production deployment, evaluate:

- Private AKS API access or restricted authorized IP ranges.
- Azure RBAC integration for Kubernetes authorization.
- Kubernetes network policies.
- Stronger workload identity and least-privilege controls.
- Centralized security monitoring and alerting.
- Policy enforcement and additional runtime security controls.

This capstone demonstrates selected DevSecOps practices,
but it is not represented as a fully production-hardened platform.

## 5. Monitoring, Observability, and Rollback

### Application Health Monitoring

Kubernetes monitors the application using:

- Readiness probes against the /healthz endpoint.
- Liveness probes against the /healthz endpoint.
- Deployment rollout status.
- Pod status, events, and container logs.

Readiness probes determine whether pods can receive traffic.
Liveness probes detect containers that need restarting.

### Resource Monitoring

Kubernetes Metrics Server provides CPU and memory metrics.

Operational commands include:
- kubectl get pods -n dev
- kubectl top pods -n dev
- kubectl get hpa -n dev
- kubectl describe hpa -n dev
- kubectl rollout status deployment/azure-devops-web -n dev

### Horizontal Pod Autoscaling

The HPA monitors CPU utilization and adjusts replicas.

Configured scaling limits:
- Minimum replicas: 1
- Maximum replicas: 3
- CPU utilization target: 50 percent

A load test demonstrated automatic scaling from one to three replicas and back to one.

### Automated Deployment Rollback

The GitHub Actions deployment workflow checks rollout health.

If verification fails, the rollback procedure restores
the previously healthy application deployment.

An intentionally unhealthy release was tested using
an invalid readiness probe path.

The failed deployment triggered rollback, and the
application returned to a healthy state.

### Monitoring Limitations

The current DEV environment uses Kubernetes-native
health checks and resource metrics.

The following are not implemented:
- Prometheus and Grafana dashboards.
- Azure Monitor Container Insights.
- Centralized alerting and incident notifications.

These are recommended enhancements for future production use.

## 6. Architecture Decisions

### Infrastructure as Code

Decision: Use Terraform to provision Azure infrastructure.

Rationale:
- Infrastructure definitions are version-controlled.
- Resources can be recreated consistently.
- Configuration changes can be reviewed before deployment.

### Container Orchestration

Decision: Use Azure Kubernetes Service (AKS).

Rationale:
- Kubernetes manages container scheduling and deployment.
- Readiness and liveness probes support application health.
- HPA demonstrates automatic workload scaling.

### CI/CD Platform

Decision: Use GitHub Actions.

Rationale:
- CI checks run automatically on pull requests.
- CD deploys approved changes merged into main.
- Azure OIDC authentication avoids long-lived credentials.
- Git commit SHA tags support release traceability.

### Kubernetes Configuration

Decision: Use Kustomize for environment-specific manifests.

Rationale:
- Base manifests are reusable.
- DEV configuration is maintained separately.
- PROD configuration can be retained without deployment.

### Environment Scope

Decision: Deploy DEV only for the final demonstration.

Rationale:
- Azure Free Tier and subscription limitations.
- Facilitator-approved scope exception.
- Avoid unnecessary production infrastructure costs.

### Operational Considerations

- Terraform changes should be reviewed before applying.
- GitHub Actions provides CI/CD execution history.
- Kubernetes rollout status provides deployment verification.
- The operations runbook documents troubleshooting.
- Failed releases can be rolled back to a healthy revision.
- Azure resource costs should be monitored.
- AKS resources should be stopped or removed when not needed.

### Future Improvements

- Implement a separate production environment.
- Add deployment approvals and promotion controls.
- Enable centralized monitoring and alerting.
- Strengthen Kubernetes networking and access controls.
- Expand automated security and integration testing.
