#!/usr/bin/env bash
# Push Docker image to ECR

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../common/load-env.sh"

show_config

if [[ -z "${CDK_AWS_ACCOUNT_ID:-}" ]]; then
    log_error "CDK_AWS_ACCOUNT_ID is required for ECR push"
    exit 1
fi

IMAGE_NAME="${CDK_ECR_REPOSITORY_NAME}"
IMAGE_TAG="${CDK_IMAGE_TAG}"
ECR_REGISTRY="${CDK_AWS_ACCOUNT_ID}.dkr.ecr.${CDK_AWS_REGION}.amazonaws.com"
ECR_IMAGE="${ECR_REGISTRY}/${IMAGE_NAME}:${IMAGE_TAG}"

# Load image from tar if provided (CI/CD artifact)
if [[ -n "${LOAD_TAR:-}" && -f "${LOAD_TAR}" ]]; then
    log_info "Loading image from: ${LOAD_TAR}"
    docker load -i "${LOAD_TAR}"
fi

log_info "Authenticating with ECR..."
aws ecr get-login-password --region "${CDK_AWS_REGION}" | \
    docker login --username AWS --password-stdin "${ECR_REGISTRY}"

log_info "Tagging image for ECR: ${ECR_IMAGE}"
docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${ECR_IMAGE}"

log_info "Pushing image to ECR..."
docker push "${ECR_IMAGE}"

log_info "Image pushed successfully: ${ECR_IMAGE}"

# Output the image URI for downstream jobs
echo "ecr_image_uri=${ECR_IMAGE}" >> "${GITHUB_OUTPUT:-/dev/null}"
