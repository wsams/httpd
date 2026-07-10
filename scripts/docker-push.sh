#!/usr/bin/env bash
set -euo pipefail

REPO="wsams/httpd"

# Ubuntu 22.04 LTS → tags: 22.04, 22
docker build --pull -f Dockerfile.22.04 \
  -t "${REPO}:22.04" \
  -t "${REPO}:22" \
  .
docker push "${REPO}:22.04"
docker push "${REPO}:22"

# Ubuntu 24.04 LTS → tags: 24.04, lts, latest
docker build --pull -f Dockerfile.24.04 \
  -t "${REPO}:24.04" \
  -t "${REPO}:lts" \
  -t "${REPO}:latest" \
  .
docker push "${REPO}:24.04"
docker push "${REPO}:lts"
docker push "${REPO}:latest"

# Ubuntu 24.10 → tags: 24.10, 24 (newest 24.x)
docker build --pull -f Dockerfile.24.10 \
  -t "${REPO}:24.10" \
  -t "${REPO}:24" \
  .
docker push "${REPO}:24.10"
docker push "${REPO}:24"
