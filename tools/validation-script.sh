#!/usr/bin/env bash
# Comprehensive validation script for macops-ansible automation
# Tests all automated configurations from 0-100%

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASS=0
FAIL=0
WARN=0

# Test result functions
pass() {
    echo -e "${GREEN}✓${NC} $1"
    ((PASS++))
}

fail() {
    echo -e "${RED}✗${NC} $1"
    ((FAIL++))
}

warn() {
    echo -e "${YELLOW}⚠${NC} $1"
    ((WARN++))
}

header() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "$1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# Start validation
echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║         MACOPS-ANSIBLE AUTOMATION VALIDATION                       ║"
echo "╚════════════════════════════════════════════════════════════════════╝"
echo ""
echo "Starting comprehensive validation at $(date)"

# ============================================================================
# FOUNDATION VALIDATION
# ============================================================================
header "FOUNDATION & PREREQUISITES"

# Admin directories
[[ -d "$HOME/.config/admin/logs" ]] && pass "Admin logs directory exists" || fail "Admin logs directory missing"
[[ -d "$HOME/.config/admin/backup" ]] && pass "Admin backup directory exists" || fail "Admin backup directory missing"
[[ -d "$HOME/.config/shell" ]] && pass "Shell config directory exists" || fail "Shell config directory missing"

# SSH configuration
[[ -f "$HOME/.ssh/known_hosts" ]] && pass "SSH known_hosts exists" || warn "SSH known_hosts missing"
grep -q "github.com" "$HOME/.ssh/known_hosts" 2>/dev/null && pass "GitHub SSH key present" || warn "GitHub SSH key missing"

# Solarized theme
[[ -d "$HOME/Downloads/solarized" ]] && pass "Solarized theme downloaded" || warn "Solarized theme missing"

# ============================================================================
# SHELL ENVIRONMENT
# ============================================================================
header "SHELL ENVIRONMENT"

[[ "$SHELL" == "/bin/zsh" ]] && pass "Default shell is ZSH" || fail "Default shell is not ZSH: $SHELL"
[[ -d "$HOME/.oh-my-zsh" ]] && pass "Oh My ZSH installed" || fail "Oh My ZSH missing"
[[ -f "$HOME/.zshrc" ]] && pass ".zshrc exists" || fail ".zshrc missing"

# Custom shell configurations
[[ -f "$HOME/.oh-my-zsh/custom/homebrew.zsh" ]] && pass "Homebrew config present" || warn "Homebrew config missing"
[[ -f "$HOME/.config/shell/aliases.zsh" ]] && pass "Custom aliases present" || warn "Custom aliases missing"
[[ -f "$HOME/.config/shell/functions.zsh" ]] && pass "Custom functions present" || warn "Custom functions missing"

# ============================================================================
# PROGRAMMING LANGUAGES
# ============================================================================
header "PROGRAMMING LANGUAGES"

# Rust
if command -v rustc &> /dev/null; then
    pass "Rust installed: $(rustc --version | cut -d' ' -f2)"
    [[ -d "$HOME/.cargo/bin" ]] && pass "Cargo bin directory exists" || warn "Cargo bin directory missing"
else
    fail "Rust not installed"
fi

# Go
if command -v go &> /dev/null; then
    pass "Go installed: $(go version | awk '{print $3}')"
    [[ -d "$HOME/go/bin" ]] && pass "Go workspace bin directory exists" || warn "Go workspace bin missing"
    grep -q "$HOME/go/bin" /etc/paths 2>/dev/null && pass "Go bin in system path" || warn "Go bin not in system path"
else
    fail "Go not installed"
fi

# Node.js
if command -v node &> /dev/null; then
    pass "Node.js installed: $(node --version)"
    command -v npm &> /dev/null && pass "npm installed: $(npm --version)" || warn "npm missing"
else
    fail "Node.js not installed"
fi

# Python
if command -v python3 &> /dev/null; then
    pass "Python3 installed: $(python3 --version | awk '{print $2}')"
    command -v pip3 &> /dev/null && pass "pip3 installed" || warn "pip3 missing"
else
    fail "Python3 not installed"
fi

# ============================================================================
# DEVELOPMENT TOOLS
# ============================================================================
header "DEVELOPMENT TOOLS"

# AWS CLI
if command -v aws &> /dev/null; then
    pass "AWS CLI installed: $(aws --version | cut -d' ' -f1 | cut -d'/' -f2)"
    [[ -f "$HOME/.oh-my-zsh/custom/aws.zsh" ]] && pass "AWS config present" || warn "AWS config missing"
    [[ -f "$HOME/.aws/cli/alias" ]] && pass "AWS CLI aliases installed" || warn "AWS CLI aliases missing"
else
    fail "AWS CLI not installed"
fi

# Terraform (via tfenv)
if command -v terraform &> /dev/null; then
    pass "Terraform installed: $(terraform version -json | grep -o '"terraform_version":"[^"]*' | cut -d'"' -f4)"
    command -v tfenv &> /dev/null && pass "tfenv installed" || warn "tfenv missing"
    grep -q "terraform" "$HOME/.zshrc" 2>/dev/null && pass "Terraform OMZSH plugin configured" || warn "Terraform plugin missing"
else
    fail "Terraform not installed"
fi

# Packer
command -v packer &> /dev/null && pass "Packer installed: $(packer version | head -1 | awk '{print $2}')" || fail "Packer not installed"

# Vault
command -v vault &> /dev/null && pass "Vault installed: $(vault version | head -1 | awk '{print $2}')" || fail "Vault not installed"

# Google Cloud SDK
if [[ -d "/opt/homebrew/Caskroom/google-cloud-sdk" ]]; then
    pass "Google Cloud SDK installed"
    grep -q "gcloud" "$HOME/.zshrc" 2>/dev/null && pass "gcloud OMZSH plugin configured" || warn "gcloud plugin missing"
else
    fail "Google Cloud SDK not installed"
fi

# Ansible
if command -v ansible &> /dev/null; then
    pass "Ansible installed: $(ansible --version | head -1 | awk '{print $3}')"
    [[ -d "$HOME/.ansible" ]] && pass "Ansible directory exists" || warn "Ansible directory missing"
    [[ -f "$HOME/.ansible/ansible.cfg" ]] && pass "Ansible config present" || warn "Ansible config missing"
else
    fail "Ansible not installed"
fi

# ============================================================================
# CONTAINERIZATION
# ============================================================================
header "CONTAINERIZATION"

if command -v docker &> /dev/null; then
    pass "Docker installed"
    grep -q "docker" "$HOME/.zshrc" 2>/dev/null && pass "Docker OMZSH plugin configured" || warn "Docker plugin missing"
else
    fail "Docker not installed"
fi

command -v pack &> /dev/null && pass "Buildpacks (pack) installed" || warn "Buildpacks not installed"
command -v dive &> /dev/null && pass "dive installed" || warn "dive not installed"

# ============================================================================
# KUBERNETES ECOSYSTEM
# ============================================================================
header "KUBERNETES ECOSYSTEM"

# Core tools
if command -v kubectl &> /dev/null; then
    pass "kubectl installed: $(kubectl version --client -o json 2>/dev/null | grep -o '"gitVersion":"[^"]*' | cut -d'"' -f4)"
    grep -q "kubectl" "$HOME/.zshrc" 2>/dev/null && pass "kubectl OMZSH plugin configured" || warn "kubectl plugin missing"
else
    fail "kubectl not installed"
fi

command -v helm &> /dev/null && pass "Helm installed: $(helm version --short 2>/dev/null | awk '{print $1}')" || fail "Helm not installed"
command -v minikube &> /dev/null && pass "Minikube installed" || warn "Minikube not installed"
command -v k9s &> /dev/null && pass "k9s installed" || warn "k9s not installed"
command -v eksctl &> /dev/null && pass "eksctl installed" || warn "eksctl not installed"

# Context switching tools
command -v kubectx &> /dev/null && pass "kubectx installed" || warn "kubectx not installed"
command -v kubens &> /dev/null && pass "kubens installed" || warn "kubens not installed"
[[ -f "$HOME/.ktx" ]] && pass "ktx function installed" || warn "ktx function missing"

# Service mesh
command -v istioctl &> /dev/null && pass "istioctl installed" || warn "istioctl not installed"
command -v linkerd &> /dev/null && pass "linkerd installed" || warn "linkerd not installed"
command -v cilium &> /dev/null && pass "cilium-cli installed" || warn "cilium-cli not installed"

# GitOps
command -v flux &> /dev/null && pass "Flux installed" || warn "Flux not installed"
command -v argocd &> /dev/null && pass "ArgoCD installed" || warn "ArgoCD not installed"

# Krew and plugins
if command -v kubectl-krew &> /dev/null; then
    pass "Krew plugin manager installed"
    grep -q ".krew/bin" /etc/paths 2>/dev/null && pass "Krew in system path" || warn "Krew not in system path"
else
    warn "Krew not installed"
fi

# ============================================================================
# GUI APPLICATIONS
# ============================================================================
header "GUI APPLICATIONS"

[[ -d "/Applications/Google Chrome.app" ]] && pass "Google Chrome installed" || warn "Chrome not installed"
[[ -d "/Applications/Firefox.app" ]] && pass "Firefox installed" || warn "Firefox not installed"
[[ -d "/Applications/Slack.app" ]] && pass "Slack installed" || warn "Slack not installed"
[[ -d "/Applications/Discord.app" ]] && pass "Discord installed" || warn "Discord not installed"
[[ -d "/Applications/Cursor.app" ]] && pass "Cursor installed" || warn "Cursor not installed"
[[ -d "/Applications/Postman.app" ]] && pass "Postman installed" || warn "Postman not installed"
[[ -d "/Applications/Wireshark.app" ]] && pass "Wireshark installed" || warn "Wireshark not installed"

# Font check
fc-list 2>/dev/null | grep -qi "hack" && pass "Hack font installed" || warn "Hack font not found"

# ============================================================================
# SYSTEM UTILITIES
# ============================================================================
header "SYSTEM UTILITIES"

# Networking tools
command -v nmap &> /dev/null && pass "nmap installed" || fail "nmap not installed"
command -v tcpdump &> /dev/null && pass "tcpdump installed" || warn "tcpdump not installed"
command -v sipcalc &> /dev/null && pass "sipcalc installed" || warn "sipcalc not installed"

# System utilities
command -v tree &> /dev/null && pass "tree installed" || fail "tree not installed"
command -v watch &> /dev/null && pass "watch installed" || warn "watch not installed"
command -v tmux &> /dev/null && pass "tmux installed" || warn "tmux not installed"
command -v jq &> /dev/null && pass "jq installed" || fail "jq not installed"
command -v yq &> /dev/null && pass "yq installed" || warn "yq not installed"

# Build tools
command -v cmake &> /dev/null && pass "cmake installed" || warn "cmake not installed"
command -v bazel &> /dev/null && pass "bazel installed" || warn "bazel not installed"

# dockutil
command -v dockutil &> /dev/null && pass "dockutil installed" || warn "dockutil not installed"

# ============================================================================
# MACOS CONFIGURATION
# ============================================================================
header "MACOS CONFIGURATION"

# Finder preferences
viewStyle=$(defaults read com.apple.finder FXPreferredViewStyle 2>/dev/null)
[[ "$viewStyle" == "Nlsv" ]] && pass "Finder default view: List" || warn "Finder view not set to List: $viewStyle"

showExt=$(defaults read NSGlobalDomain AppleShowAllExtensions 2>/dev/null)
[[ "$showExt" == "1" ]] && pass "Show all file extensions: enabled" || warn "Show extensions disabled"

searchScope=$(defaults read com.apple.finder FXDefaultSearchScope 2>/dev/null)
[[ "$searchScope" == "SCcf" ]] && pass "Search current folder by default" || warn "Search scope not set to current folder"

# Dock preferences
tileSize=$(defaults read com.apple.dock tilesize 2>/dev/null)
[[ "$tileSize" == "42" ]] && pass "Dock tile size: 42px" || warn "Dock tile size not 42: $tileSize"

# Screenshot preferences
screenshotDir=$(defaults read com.apple.screencapture location 2>/dev/null)
[[ "$screenshotDir" == "$HOME/Pictures/screens" ]] && pass "Screenshot location configured" || warn "Screenshot location not set"
[[ -d "$HOME/Pictures/screens" ]] && pass "Screenshots directory exists" || warn "Screenshots directory missing"
[[ -L "$HOME/Desktop/screens" ]] && pass "Desktop screenshots symlink exists" || warn "Desktop symlink missing"

# TextEdit preferences
richText=$(defaults read com.apple.TextEdit RichText 2>/dev/null)
[[ "$richText" == "0" ]] && pass "TextEdit: Plain text mode" || warn "TextEdit not in plain text mode"

font=$(defaults read com.apple.TextEdit NSFixedPitchFont 2>/dev/null)
[[ "$font" == "Hack-Regular" ]] && pass "TextEdit font: Hack-Regular" || warn "TextEdit font not Hack: $font"

# Security settings
guestLogin=$(sudo defaults read /Library/Preferences/com.apple.loginwindow GuestEnabled 2>/dev/null)
[[ "$guestLogin" == "0" ]] && pass "Guest login disabled" || warn "Guest login not disabled"

# ============================================================================
# FINAL SUMMARY
# ============================================================================
header "VALIDATION SUMMARY"

TOTAL=$((PASS + FAIL + WARN))

echo ""
echo "Results:"
echo "  ${GREEN}✓ Passed:${NC}  $PASS/$TOTAL"
echo "  ${RED}✗ Failed:${NC}  $FAIL/$TOTAL"
echo "  ${YELLOW}⚠ Warnings:${NC} $WARN/$TOTAL"
echo ""

if [[ $FAIL -eq 0 ]]; then
    echo -e "${GREEN}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${GREEN}║  ✓ AUTOMATION VALIDATION SUCCESSFUL                                ║${NC}"
    echo -e "${GREEN}╚════════════════════════════════════════════════════════════════════╝${NC}"
    exit 0
else
    echo -e "${RED}╔════════════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${RED}║  ✗ AUTOMATION VALIDATION FAILED                                    ║${NC}"
    echo -e "${RED}║    Review failed checks above                                      ║${NC}"
    echo -e "${RED}╚════════════════════════════════════════════════════════════════════╝${NC}"
    exit 1
fi
