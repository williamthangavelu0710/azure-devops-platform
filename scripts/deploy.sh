#!/usr/bin/env bash
set -euo pipefail

ENVIRONMENT="${1:-}"
IMAGE_SHA="${2:-}"

if [[ "$ENVIRONMENT" != "dev" || -z "$IMAGE_SHA" ]]; then
  echo "Usage: bash scripts/deploy.sh dev <image-sha>"
  echo "Only DEV deployment is enabled for this capstone."
  exit 1
fi

if [[ ! "$IMAGE_SHA" =~ ^[a-fA-F0-9]{40}$ ]]; then
  echo "ERROR: Image SHA must be a 40-character Git commit SHA."
  exit 1
fi

command -v kubectl >/dev/null || {
  echo "ERROR: kubectl is required."
  exit 1
}

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TEMP_DIR="$(mktemp -d)"
PF_PID=""

cleanup() {
  if [[ -n "$PF_PID" ]]; then
    kill "$PF_PID" 2>/dev/null || true
  fi
  rm -rf "$TEMP_DIR"
}
trap cleanup EXIT

echo "Environment: dev"
echo "Image SHA: $IMAGE_SHA"
echo "Kubernetes context: $(kubectl config current-context)"

read -r -p "Deploy to this cluster? Type DEPLOY: " CONFIRM
if [[ "$CONFIRM" != "DEPLOY" ]]; then
  echo "Deployment cancelled."
  exit 1
fi

cp -R "$ROOT/kubernetes/." "$TEMP_DIR/"
sed -i "s|newTag: .*|newTag: $IMAGE_SHA|" \
  "$TEMP_DIR/overlays/dev/kustomization.yaml"

echo "Applying DEV manifests..."
kubectl apply -k "$TEMP_DIR/overlays/dev"

rollback() {
  echo "ERROR: Verification failed. Attempting rollback..."
  kubectl rollout undo deployment/azure-devops-web -n dev || true
  kubectl rollout status deployment/azure-devops-web \
    -n dev --timeout=180s || true
  exit 1
}

echo "Verifying rollout..."
kubectl rollout status deployment/azure-devops-web \
  -n dev --timeout=180s || rollback

echo "Starting local port-forward..."
kubectl -n dev port-forward deployment/azure-devops-web \
  18081:8080 > "$TEMP_DIR/portforward.log" 2>&1 &
PF_PID=$!

echo "Running smoke tests..."
if ! bash "$ROOT/scripts/smoke.sh" \
  http://127.0.0.1:18081 "$IMAGE_SHA"; then
  cat "$TEMP_DIR/portforward.log"
  rollback
fi

echo "PASS: DEV deployment and smoke tests successful."
