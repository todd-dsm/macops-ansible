#!/usr/bin/env bash
# shellcheck source=/dev/null
# Simple wrapper to run Ansible
# Usage: ./bootstrap.sh [TEST] [additional ansible-playbook args]
set -e

# Get environment mode (TEST or LIVE)
ENV_MODE="${1:-LIVE}"
# Shift to get remaining arguments for ansible-playbook
shift 2>/dev/null || true

# Load variables into the environment quietly
source ./my-vars.env >/dev/null 2>&1

echo "Running Ansible with environment: $ENV_MODE"

cd ansible
ansible-playbook site.yml -i inventory/localhost -e "env_mode=$ENV_MODE" "$@"
