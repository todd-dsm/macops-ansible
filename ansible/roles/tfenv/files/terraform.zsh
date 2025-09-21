# --------------------------------------------------------------------------- #
#                                  Terraform                                  #
# --------------------------------------------------------------------------- #
alias tf="$(whence -p terraform)"
complete -o nospace -C TERRAFORM_PATH tf
# zsh-native completion for tf alias
compdef _terraform tf
# Enable terraform completion if not already loaded
autoload -Uz compinit && compinit
# Terraform constants
export TF_LOG='DEBUG'
export TF_LOG_PATH='/tmp/terraform.log'
#export TFLINT_CONFIG_FILE="$HOME/.config/tf"
