#!/usr/bin/env bash
# Common environment loading script
# Sources configuration from environment variables and context files

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Logging helpers
log_info() { echo "[INFO] $*"; }
log_warn() { echo "[WARN] $*" >&2; }
log_error() { echo "[ERROR] $*" >&2; }

# Helper to get JSON value from context file
get_json_value() {
    local key="$1"
    local file="$2"
    if [[ -f "$file" ]]; then
        jq -r ".context.${key} // empty" "$file" 2>/dev/null || echo ""
    else
        echo ""
    fi
}

# Context file location
CONTEXT_FILE="${REPO_ROOT}/infrastructure/cdk.json"

# Export configuration variables (priority: env var > context file > default)
export CDK_PROJECT_PREFIX="${CDK_PROJECT_PREFIX:-$(get_json_value "projectPrefix" "${CONTEXT_FILE}")}"
export CDK_PROJECT_PREFIX="${CDK_PROJECT_PREFIX:-mcp-docker-lambda}"

export CDK_AWS_REGION="${CDK_AWS_REGION:-$(get_json_value "awsRegion" "${CONTEXT_FILE}")}"
export CDK_AWS_REGION="${CDK_AWS_REGION:-us-west-2}"

export CDK_AWS_ACCOUNT_ID="${CDK_AWS_ACCOUNT_ID:-${AWS_ACCOUNT_ID:-}}"

export CDK_ECR_REPOSITORY_NAME="${CDK_ECR_REPOSITORY_NAME:-${CDK_PROJECT_PREFIX}-mcp-tool}"

export CDK_IMAGE_TAG="${CDK_IMAGE_TAG:-latest}"

export CDK_LAMBDA_MEMORY_MB="${CDK_LAMBDA_MEMORY_MB:-512}"
export CDK_LAMBDA_TIMEOUT_SECONDS="${CDK_LAMBDA_TIMEOUT_SECONDS:-30}"

# OpenSearch configuration
export CDK_OPENSEARCH_HOST="${CDK_OPENSEARCH_HOST:-}"
export CDK_OPENSEARCH_REGION="${CDK_OPENSEARCH_REGION:-us-west-2}"
export CDK_OPENSEARCH_ACCOUNT_ID="${CDK_OPENSEARCH_ACCOUNT_ID:-}"
export CDK_OPENSEARCH_DOMAIN_NAME="${CDK_OPENSEARCH_DOMAIN_NAME:-}"

# Build CDK context parameters string
build_context_params() {
    local context_params=""

    context_params="${context_params} --context projectPrefix=\"${CDK_PROJECT_PREFIX}\""
    context_params="${context_params} --context awsRegion=\"${CDK_AWS_REGION}\""
    context_params="${context_params} --context ecrRepositoryName=\"${CDK_ECR_REPOSITORY_NAME}\""
    context_params="${context_params} --context imageTag=\"${CDK_IMAGE_TAG}\""
    context_params="${context_params} --context lambdaMemoryMb=\"${CDK_LAMBDA_MEMORY_MB}\""
    context_params="${context_params} --context lambdaTimeoutSeconds=\"${CDK_LAMBDA_TIMEOUT_SECONDS}\""

    if [[ -n "${CDK_AWS_ACCOUNT_ID:-}" ]]; then
        context_params="${context_params} --context awsAccountId=\"${CDK_AWS_ACCOUNT_ID}\""
    fi

    # OpenSearch context parameters
    if [[ -n "${CDK_OPENSEARCH_HOST:-}" ]]; then
        context_params="${context_params} --context opensearchHost=\"${CDK_OPENSEARCH_HOST}\""
    fi
    if [[ -n "${CDK_OPENSEARCH_REGION:-}" ]]; then
        context_params="${context_params} --context opensearchRegion=\"${CDK_OPENSEARCH_REGION}\""
    fi
    if [[ -n "${CDK_OPENSEARCH_ACCOUNT_ID:-}" ]]; then
        context_params="${context_params} --context opensearchAccountId=\"${CDK_OPENSEARCH_ACCOUNT_ID}\""
    fi
    if [[ -n "${CDK_OPENSEARCH_DOMAIN_NAME:-}" ]]; then
        context_params="${context_params} --context opensearchDomainName=\"${CDK_OPENSEARCH_DOMAIN_NAME}\""
    fi

    echo "${context_params}"
}

# Display current configuration
show_config() {
    log_info "Configuration:"
    log_info "  Project Prefix:    ${CDK_PROJECT_PREFIX}"
    log_info "  AWS Region:        ${CDK_AWS_REGION}"
    log_info "  AWS Account ID:    ${CDK_AWS_ACCOUNT_ID:-<not set>}"
    log_info "  ECR Repository:    ${CDK_ECR_REPOSITORY_NAME}"
    log_info "  Image Tag:         ${CDK_IMAGE_TAG}"
    log_info "  Lambda Memory:     ${CDK_LAMBDA_MEMORY_MB} MB"
    log_info "  Lambda Timeout:    ${CDK_LAMBDA_TIMEOUT_SECONDS} seconds"
    log_info "  OpenSearch Host:   ${CDK_OPENSEARCH_HOST:-<not set>}"
    log_info "  OpenSearch Region: ${CDK_OPENSEARCH_REGION}"
    log_info "  OpenSearch Account: ${CDK_OPENSEARCH_ACCOUNT_ID:-<not set>}"
    log_info "  OpenSearch Domain: ${CDK_OPENSEARCH_DOMAIN_NAME:-<not set>}"
}

# Export functions for use in other scripts
export -f log_info log_warn log_error get_json_value build_context_params show_config
