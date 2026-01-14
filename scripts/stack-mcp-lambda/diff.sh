#!/usr/bin/env bash
# Show CDK diff for the stack

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../common/load-env.sh"

show_config

STACK_NAME="${CDK_PROJECT_PREFIX}-stack"
CONTEXT_PARAMS=$(build_context_params)

log_info "Showing CDK diff for stack: ${STACK_NAME}"

cd "${REPO_ROOT}/infrastructure"

# Run diff (use existing cdk.out if available)
if [[ -d "cdk.out" ]]; then
    eval "npx cdk diff ${STACK_NAME} ${CONTEXT_PARAMS} --app cdk.out" || true
else
    eval "npx cdk diff ${STACK_NAME} ${CONTEXT_PARAMS}" || true
fi

log_info "CDK diff completed"
