
# Azure DevOps Platform — Operations Runbook

## 1. Purpose

This runbook documents the operational procedures for the Azure DevOps Platform capstone, including deployment monitoring, application verification, troubleshooting, rollback, security, and cost management.

This is a production-inspired learning environment, not a production-hardened system.

## 2. Platform Overview

| Component | Configuration |
|---|---|
| Cloud | Microsoft Azure |
| Resource Group | rg-azure-devops-platform-dev |
| AKS Cluster | aks-azure-devops-platform-dev |
| Container Registry | acrdevopswt20261027 |
| Kubernetes Namespace | dev |
| Application Deployment | azure-devops-web |
| Application Container Port | 8080 |
| Health Endpoint | /healthz |
| Infrastructure as Code | Terraform |
| Deployment Configuration | Kustomize |
| CI/CD | GitHub Actions |
| Authentication | Microsoft Entra ID and OIDC |

Production configuration is prepared but the production environment has not been provisioned.

## 3. AKS Lifecycle Management

### Check AKS Power State

```bash
az aks show \
  --resource-group rg-azure-devops-platform-dev \
  --name aks-azure-devops-platform-dev \
  --query "powerState.code" \
  -o tsv
```

### Start AKS

Only start the cluster when testing or deployment is required.

```bash
az aks start \
  --resource-group rg-azure-devops-platform-dev \
  --name aks-azure-devops-platform-dev
```

Wait for the operation to finish before accessing Kubernetes.

### Stop AKS

After completing validation:

```bash
az aks stop \
  --resource-group rg-azure-devops-platform-dev \
  --name aks-azure-devops-platform-dev
```

Verify the power state reports `Stopped`.

**Cost warning:** Stopping AKS reduces compute costs, but ACR, storage, and other Azure resources may continue to incur charges.

## 4. Kubernetes Access and Verification

### Obtain Cluster Credentials

```bash
az aks get-credentials \
  --resource-group rg-azure-devops-platform-dev \
  --name aks-azure-devops-platform-dev \
  --overwrite-existing
```

Microsoft Entra authentication may require kubelogin.

### Check Nodes

```bash
kubectl get nodes
```

### Check Deployment

```bash
kubectl get deployment azure-devops-web -n dev
```

### Check Pods

```bash
kubectl get pods -n dev -o wide
```

### Check Services

```bash
kubectl get services -n dev
```

### Check Horizontal Pod Autoscaler

```bash
kubectl get hpa -n dev
```

The DEV HPA is configured for CPU-based autoscaling with a minimum of one and maximum of five replicas.

## 5. Application Health Verification

Forward a local port to the application:

```bash
kubectl port-forward -n dev deployment/azure-devops-web 9090:8080
```

Keep that terminal running.

From a second terminal:

```bash
curl -i http://localhost:9090/healthz
```

Expected result:

```text
HTTP/1.1 200 OK

ok
```

The application health endpoint was successfully verified during capstone testing.

## 6. GitHub Actions CI/CD

Repository:

https://github.com/williamthangavelu0710/azure-devops-platform

### Continuous Integration

Workflow: `.github/workflows/ci.yml`

Triggered by pushes to `main` and pull requests targeting `main`.

CI performs:

- Node.js dependency installation
- HTML validation
- Docker image build
- Container health smoke test
- Trivy container security scan
- Terraform formatting and validation
- Terraform security configuration scan

### Continuous Deployment

Workflow: `.github/workflows/cd.yml`

Triggered after a successful CI workflow associated with a push to `main`.

CD performs:

1. Detect relevant application or DEV Kubernetes manifest changes.
2. Authenticate to Azure using GitHub OIDC.
3. Build and publish a Git-SHA-tagged image to ACR.
4. Authenticate to AKS.
5. Check Kubernetes deployment permissions.
6. Apply the DEV Kustomize overlay.
7. Verify rollout status.
8. Attempt rollback if rollout verification fails.

Documentation-only and RBAC-only changes are intended to skip application deployment.

**Verification status:** Successful automatic CD deployment was demonstrated. The change-detection gate has passed configuration review but still requires runtime verification.

### Check CI Runs

```bash
gh run list --workflow ci.yml --branch main --limit 5
```

### Check CD Runs

```bash
gh run list --workflow cd.yml --limit 5
```

### Inspect a Run

```bash
gh run view RUN_ID --log
```

Replace `RUN_ID` with the actual GitHub Actions run ID.

## 7. Troubleshooting

### Deployment Not Ready

```bash
kubectl describe deployment azure-devops-web -n dev
```

```bash
kubectl get pods -n dev
```

### Inspect Application Logs

```bash
kubectl logs -n dev deployment/azure-devops-web
```

### Inspect Recent Kubernetes Events

```bash
kubectl get events -n dev --sort-by=.lastTimestamp
```

### Check Deployment Permissions

```bash
kubectl auth can-i patch deployments.apps -n dev
```

### Common Issues

| Symptom | Investigation |
|---|---|
| ImagePullBackOff | Check ACR image tag, pull permissions, and registry connectivity |
| CrashLoopBackOff | Check container logs, startup configuration, and probes |
| Forbidden | Check Kubernetes Role and RoleBinding permissions |
| Pending Pod | Check node capacity, scheduling, and resource requests |
| Health check failure | Inspect readiness/liveness probes and application logs |
| AKS unreachable | Check AKS power state and authentication |

## 8. Deployment Rollback

### Review Deployment History

```bash
kubectl rollout history deployment/azure-devops-web -n dev
```

### Roll Back to Previous Revision

```bash
kubectl rollout undo deployment/azure-devops-web -n dev
```

### Verify Rollback

```bash
kubectl rollout status deployment/azure-devops-web -n dev --timeout=180s
```

The CD workflow includes automated rollback handling when rollout verification fails.

**Limitation:** The rollback failure path has not been deliberately exercised in a live failure-injection test. A rollback may also require the previous image to remain available in ACR.

## 9. Security Controls

Implemented controls include:

- OIDC authentication between GitHub Actions and Azure
- Microsoft Entra authentication
- Namespace-scoped Kubernetes RBAC for deployment operations
- Container image scanning using Trivy
- Terraform configuration scanning using Trivy
- Versioned Docker images identified by Git commit SHA
- Git exclusions for Terraform state and sensitive local files

RBAC configuration is maintained at:

`kubernetes/rbac/dev/github-actions-deployer.yaml`

### Known Security Limitations

- AKS API server access is public without authorized IP restrictions.
- Kubernetes network policy enforcement is not enabled.
- Some HIGH and CRITICAL Terraform security findings remain unresolved.
- Terraform security findings currently do not block CI.

These risks must be reviewed before any production deployment.

## 10. Operational Handoff Checklist

- [x] Terraform infrastructure provisioned for DEV
- [x] Docker application built and scanned
- [x] GitHub Actions CI validated
- [x] Azure OIDC authentication verified
- [x] Automated DEV deployment completed
- [x] Application health endpoint verified
- [x] Kubernetes RBAC configuration committed
- [x] AKS stopped after validation
- [ ] CD change-detection gate verified at runtime
- [ ] Production deployment and promotion process implemented
- [ ] Live rollback failure scenario tested
- [ ] Outstanding security findings reviewed for production readiness

## 11. Final Operational State

The DEV environment was successfully deployed and tested.

AKS is intentionally stopped for cost management.

GitHub Actions CI and CD workflows are enabled. A future application change merged into `main` may trigger a deployment, so the AKS cluster must be running before deployment is attempted.

Production is not provisioned.
