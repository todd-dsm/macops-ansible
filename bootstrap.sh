#!/usr/bin/env bash
# Simple wrapper to run Ansible
# Usage: ./run-ansible.sh [TEST] [additional ansible-playbook args]

set -e

# Get environment mode (TEST or LIVE)
ENV_MODE="${1:-LIVE}"

# Shift to get remaining arguments for ansible-playbook
shift 2>/dev/null || true

echo "Running Ansible with environment: $ENV_MODE"

cd ansible
ansible-playbook site.yml -i inventory/localhost -e "env_mode=$ENV_MODE" "$@"