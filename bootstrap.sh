#!/usr/bin/env bash
# shellcheck source=/dev/null
# Simple wrapper to run Ansible
# Usage: ./bootstrap.sh [TEST] [additional ansible-playbook args]
set -e

# Get environment mode (TEST or LIVE)
ENV_MODE="${1:-LIVE}"
# Shift to get remaining arguments for ansible-playbook
shift 2>/dev/null || true

# duration calculator
START_EPOCH=$(date +%s)
#echo "DEBUG: Writing start time: $START_EPOCH to /tmp/ansible_start_time"
echo "$START_EPOCH" > /tmp/ansible_start_time

#VERIFY=$(cat /tmp/ansible_start_time)
#echo "DEBUG: File immediately contains: $VERIFY"

#CTIME=$(stat --format="%Z"    /tmp/ansible_start_time)
#echo "File ctime: $CTIME"

# Load variables into the environment quietly
source ./my-vars.env >/dev/null 2>&1

echo "Running Ansible with environment: $ENV_MODE"

cd ansible
ansible-playbook site.yml -i inventory/localhost -e "env_mode=$ENV_MODE" "$@"
