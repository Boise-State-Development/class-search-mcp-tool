#!/usr/bin/env bash
# Build Docker image for MCP tool

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../common/load-env.sh"

show_config

IMAGE_NAME="${CDK_ECR_REPOSITORY_NAME}"
IMAGE_TAG="${CDK_IMAGE_TAG}"

log_info "Building Docker image: ${IMAGE_NAME}:${IMAGE_TAG}"

cd "${REPO_ROOT}/mcp-tool"

docker build \
    --platform linux/amd64 \
    -t "${IMAGE_NAME}:${IMAGE_TAG}" \
    -f Dockerfile \
    .

log_info "Docker image built successfully: ${IMAGE_NAME}:${IMAGE_TAG}"

# Export image as tar for artifact passing (CI/CD)
if [[ "${EXPORT_TAR:-false}" == "true" ]]; then
    TAR_FILE="${REPO_ROOT}/${IMAGE_NAME}-${IMAGE_TAG}.tar"
    log_info "Exporting image to: ${TAR_FILE}"
    docker save "${IMAGE_NAME}:${IMAGE_TAG}" -o "${TAR_FILE}"
    log_info "Image exported successfully"
fi
