#!/usr/bin/env bash
# Install CDK dependencies

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

source "${SCRIPT_DIR}/../common/load-env.sh"

log_info "Installing CDK dependencies..."

cd "${REPO_ROOT}/infrastructure"
npm ci

log_info "CDK dependencies installed successfully"
