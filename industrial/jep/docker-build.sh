#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
IMAGE_TAG="${1:-moqui-jep:latest}"
MOQUI_IMAGE="${2:-moqui:latest}"
JEP_VERSION="${JEP_VERSION:-4.3.1}"
NUMPY_VERSION="${NUMPY_VERSION:-}"

echo "Building ${IMAGE_TAG} from base image ${MOQUI_IMAGE}"

docker build \
  -t "${IMAGE_TAG}" \
  --build-arg "MOQUI_IMAGE=${MOQUI_IMAGE}" \
  --build-arg "JEP_VERSION=${JEP_VERSION}" \
  --build-arg "NUMPY_VERSION=${NUMPY_VERSION}" \
  "${SCRIPT_DIR}"
