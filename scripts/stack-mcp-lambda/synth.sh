#!/usr/bin/env bash
# Synthesize CDK CloudFormation templates

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../common/load-env.sh"

show_config

STACK_NAME="${CDK_PROJECT_PREFIX}-stack"
CONTEXT_PARAMS=$(build_context_params)

log_info "Synthesizing CDK stack: ${STACK_NAME}"

cd "${REPO_ROOT}/infrastructure"

# Build TypeScript
npm run build

# Synthesize CloudFormation templates
eval "npx cdk synth ${STACK_NAME} ${CONTEXT_PARAMS} --output cdk.out"

log_info "CDK synthesis completed successfully"
log_info "Output directory: ${REPO_ROOT}/infrastructure/cdk.out"
