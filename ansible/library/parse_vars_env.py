#!/usr/bin/python

# Copyright: (c) 2025, Todd Thomas
# GNU General Public License v3.0+ (see COPYING or https://www.gnu.org/licenses/gpl-3.0.txt)

from __future__ import (absolute_import, division, print_function)
__metaclass__ = type

DOCUMENTATION = r'''
---
module: parse_vars_env

short_description: Parse my-vars.env shell script variables into Ansible facts

version_added: "1.0.0"

description: 
    - Sources my-vars.env shell script and converts exported variables to Ansible facts
    - Handles quote stripping and variable name mapping automatically
    - Supports TEST and LIVE environment modes

options:
    env_mode:
        description: Environment mode to pass to my-vars.env
        required: false
        type: str
        default: 'LIVE'
    vars_file:
        description: Path to the variables file
        required: false
        type: str
        default: 'my-vars.env'

author:
    - Todd Thomas
'''

EXAMPLES = r'''
# Load variables in TEST mode
- name: Load my-vars.env variables
  parse_vars_env:
    env_mode: TEST

# Load variables in LIVE mode (default)
- name: Load my-vars.env variables
  parse_vars_env:
'''

RETURN = r'''
ansible_facts:
    description: Dictionary of variables extracted from my-vars.env
    type: dict
    returned: always
    sample: {
        "my_full_name": "Todd Thomas",
        "my_email_add": "todd.dsm@gmail.com",
        "my_mbp_is_for": "work"
    }
'''

import subprocess
import os
import re
from ansible.module_utils.basic import AnsibleModule


def clean_value(value):
    """Remove quotes and clean up variable values"""
    if not value:
        return value
    
    # Remove surrounding quotes (single or double)
    value = re.sub(r'^["\'](.*)["\']\s*$', r'\1', value.strip())
    return value


def parse_shell_vars(stdout_text):
    """Parse shell environment output into clean dictionary"""
    vars_dict = {}
    
    # Variable mappings from shell to Ansible fact names
    var_mappings = {
        'myFullName': 'my_full_name',
        'myEmailAdd': 'my_email_add', 
        'myMBPisFor': 'my_mbp_is_for',
        'myHostName': 'my_host_name',
        'myDomaiName': 'my_domain_name',
        'dataRestore': 'data_restore',
        'myBackups': 'my_backups',
        'sysBackups': 'sys_backups',
        'myCode': 'my_code',
        'myDocs': 'my_docs', 
        'myDownloads': 'my_downloads',
        'adminDir': 'admin_dir',
        'backupDir': 'backup_dir',
        'knownHosts': 'known_hosts',
        'hostRemote': 'host_remote',
        'solarizedGitRepo': 'solarized_git_repo',
        'termStuff': 'term_stuff'
    }
    
    for line in stdout_text.split('\n'):
        line = line.strip()
        if '=' in line and not line.startswith('#'):
            try:
                key, value = line.split('=', 1)
                key = key.strip()
                
                # Map shell variable names to Ansible fact names
                if key in var_mappings:
                    ansible_var_name = var_mappings[key]
                    vars_dict[ansible_var_name] = clean_value(value)
                    
            except ValueError:
                # Skip malformed lines
                continue
    
    return vars_dict


def main():
    # Define module arguments
    module_args = dict(
        env_mode=dict(type='str', required=False, default='LIVE'),
        vars_file=dict(type='str', required=False, default='my-vars.env')
    )

    # Create the module object
    module = AnsibleModule(
        argument_spec=module_args,
        supports_check_mode=True
    )

    # Get parameters
    env_mode = module.params['env_mode']
    vars_file = module.params['vars_file']

    # Check if vars file exists
    if not os.path.exists(vars_file):
        module.fail_json(msg=f"Variables file {vars_file} not found")

    # Build the command to source the file and output environment
    cmd = f"cd .. && source {vars_file} {env_mode} && env | grep -E '^(my|export)'"
    
    try:
        # Execute the command
        result = subprocess.run(
            cmd, 
            shell=True, 
            capture_output=True, 
            text=True,
            cwd=os.path.dirname(os.path.abspath(__file__))
        )
        
        if result.returncode != 0:
            module.fail_json(
                msg=f"Failed to source {vars_file}",
                stderr=result.stderr,
                cmd=cmd
            )
            
        # Parse the variables
        parsed_vars = parse_shell_vars(result.stdout)
        
        # Validate critical variables
        required_vars = ['my_full_name', 'my_email_add', 'admin_dir']
        missing_vars = [var for var in required_vars if var not in parsed_vars]
        
        if missing_vars:
            module.fail_json(
                msg=f"Required variables missing: {', '.join(missing_vars)}"
            )
            
        # Check for unconfigured placeholder values
        if parsed_vars.get('my_full_name') == 'fName lName':
            module.fail_json(
                msg="my-vars.env not configured properly. myFullName cannot be 'fName lName'"
            )

        # Return success with the parsed variables as facts
        module.exit_json(
            changed=False,
            ansible_facts=parsed_vars,
            message=f"Successfully loaded {len(parsed_vars)} variables from {vars_file}"
        )
        
    except Exception as e:
        module.fail_json(msg=f"Error parsing variables: {str(e)}")


if __name__ == '__main__':
    main()