#!/usr/bin/env bash
set -euo pipefail

BASE_URL="${1:?Usage: smoke.sh <base-url> <sha>}"
EXPECTED_SHA="${2:?Usage: smoke.sh <base-url> <sha>}"

BASE_URL="${BASE_URL%/}"

echo "=== APPLICATION SMOKE TEST ==="
echo "URL: $BASE_URL"
echo "Expected SHA: $EXPECTED_SHA"

echo "Waiting for expected version..."

FOUND=false

TIMEOUT="${SMOKE_TIMEOUT_SECONDS:-120}"
DEADLINE=$((SECONDS + TIMEOUT))

while [ "$SECONDS" -lt "$DEADLINE" ]; do
    VERSION=$(curl -fsS --max-time 2 \
      "$BASE_URL/version.json" 2>/dev/null || true)

    if echo "$VERSION" | grep -Fq \
      "\"sha\":\"$EXPECTED_SHA\""; then
        FOUND=true
        break
    fi

    sleep 2
done

if [ "$FOUND" != "true" ]; then
    echo "FAIL: Expected SHA not found within ${TIMEOUT} seconds"
    exit 1
fi

echo "PASS: Version SHA matches"

HEALTH=$(curl -fsS "$BASE_URL/healthz")

if [ "$HEALTH" != "ok" ]; then
    echo "FAIL: Health endpoint incorrect"
    exit 1
fi

echo "PASS: Health endpoint"

PAGE=$(curl -fsS "$BASE_URL/")

if ! echo "$PAGE" | grep -Fq \
  "Azure DevOps Platform"; then
    echo "FAIL: Website title missing"
    exit 1
fi

echo "PASS: Website title"
echo "PASS: ALL SMOKE TESTS SUCCESSFUL"
