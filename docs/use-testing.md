# Testing and Usage Guide

## Command Examples

### Individual Role Testing
Test specific programming languages or tools in isolation:

```bash
# Test Rust installation and configuration
% ./bootstrap.sh TEST --tags "rust"

# Test Terraform with tfenv setup  
% ./bootstrap.sh TEST --tags "terraform"

# Test Node.js with nmpm installation
% ./bootstrap.sh TEST --tags "nodejs"

# Test Kubernetes CLI with ktx setup
% ./bootstrap.sh TEST --tags "kubernetes"

# Test Go installation and paths
% ./bootstrap.sh TEST --tags "go"
```

### Dry Run Testing
Use `--check` to see what **would** be changed without making actual changes:

```bash
# Check what Rust setup would do
% ./bootstrap.sh TEST --tags "rust" --check

# Check Kubernetes installation without executing
% ./bootstrap.sh TEST --tags "kubernetes" --check

# Check all development tools without changes
% ./bootstrap.sh TEST --tags "development-tools" --check
```

### Group Testing
Test multiple related roles together:

```bash
# Test all programming language roles
% ./bootstrap.sh TEST --tags "development-tools"

# Test foundation setup (SSH keys, validation, backups)
% ./bootstrap.sh TEST --tags "foundation"

# Test foundation + all development tools
% ./bootstrap.sh TEST --tags "foundation,development-tools"
```

### Full System Testing
```bash
# Complete automation (when ready)
% ./bootstrap.sh TEST

# Production run (removes TEST parameter)
% ./bootstrap.sh
```

## Ansible Syntax and Validation

### Syntax Checking
Verify YAML syntax and playbook structure before running:

```bash
# Check syntax of entire playbook
% cd ansible
% ansible-playbook site.yml --syntax-check

# Check specific playbook
% ansible-playbook playbooks/development-tools.yml --syntax-check
```

### List Available Tags
See all available tags across the automation:

```bash
% cd ansible  
% ansible-playbook site.yml --list-tags
```

### Verbose Output
Get detailed information about what Ansible is doing:

```bash
# Standard verbose output
% ./bootstrap.sh TEST --tags "rust" -v

# Very verbose (connection debugging)
% ./bootstrap.sh TEST --tags "rust" -vv

# Extremely verbose (full debugging)  
% ./bootstrap.sh TEST --tags "rust" -vvv
```

## Understanding --check Mode

The `--check` flag runs Ansible in **"dry run" mode**:

- **Shows what would change** without making actual changes
- **Safe to run** on any system - no modifications occur
- **Useful for validation** before running the real automation
- **Reports "changed" status** for actions that would be taken
- **Files are not created** or modified in check mode

**Example check output:**
```
TASK [Install Rust] ****************************************************
changed: [localhost]  # This would install Rust (but doesn't in check mode)

TASK [Configure Rust system path] *************************************  
changed: [localhost]  # This would modify /etc/paths (but doesn't in check mode)
```

## Troubleshooting

### Common Issues
```bash
# Permission errors - may need elevated privileges
% ./bootstrap.sh TEST --tags "terraform" --ask-become-pass

# Clear Ansible cache if roles aren't found
% rm -rf ~/.ansible/cp/

# Force role refresh
% cd ansible && ansible-galaxy install --force -r requirements.yml
```

### Role-Specific Notes

**Terraform:**
- Requires `sudo` for tfenv operations
- Removes existing Homebrew terraform installations
- Adds terraform plugin to Oh My ZSH automatically

**Node.js:**
- Installs nmpm as local package (not global)
- Configures XDG directory structure for clean organization

**Kubernetes:**
- Installs ktx from GitHub repository
- Sets up completion and shell integration automatically

**SSH Keys (Foundation):**
- Must run before any Git-based operations
- Creates idempotent known_hosts entries