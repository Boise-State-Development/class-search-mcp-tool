#!/usr/bin/env bash
# Deploy CDK stack to AWS

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../common/load-env.sh"

show_config

STACK_NAME="${CDK_PROJECT_PREFIX}-stack"
CONTEXT_PARAMS=$(build_context_params)

log_info "Deploying CDK stack: ${STACK_NAME}"

cd "${REPO_ROOT}/infrastructure"

# Deploy using existing cdk.out if available (synth once, deploy anywhere)
if [[ -d "cdk.out" ]]; then
    log_info "Using pre-synthesized templates from cdk.out"
    eval "npx cdk deploy ${STACK_NAME} ${CONTEXT_PARAMS} --app cdk.out --require-approval never"
else
    log_info "No cdk.out found, synthesizing during deploy"
    eval "npx cdk deploy ${STACK_NAME} ${CONTEXT_PARAMS} --require-approval never"
fi

log_info "CDK deployment completed successfully"

# Extract and output the Function URL
FUNCTION_URL=$(aws cloudformation describe-stacks \
    --stack-name "${STACK_NAME}" \
    --query "Stacks[0].Outputs[?OutputKey=='LambdaFunctionUrl'].OutputValue" \
    --output text \
    --region "${CDK_AWS_REGION}" 2>/dev/null || echo "")

if [[ -n "${FUNCTION_URL}" ]]; then
    log_info "Lambda Function URL: ${FUNCTION_URL}"
    echo "function_url=${FUNCTION_URL}" >> "${GITHUB_OUTPUT:-/dev/null}"
fi
