# Cleanup existing installations
cleanup_all

# Update and install Zsh and necessary packages
echo "Installing Zsh, Git, Wget, and Curl..."
install_packages zsh git wget curl

# Install Oh My Zsh without switching to zsh shell automatically
echo "Installing Oh My Zsh..."
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Configure .zshrc
cat > $HOME/.zshrc << 'EOF'
# Path to your oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme configuration
ZSH_THEME="agnoster"

# Configure prompt segments
prompt_context() {
  if [[ "$USER" != "$DEFAULT_USER" || -n "$SSH_CLIENT" ]]; then
    prompt_segment black default "%(!.%{%F{yellow}%}.)$USER@%m"
  fi
}

# Plugins
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
  colored-man-pages
  command-not-found
  history-substring-search
)

source $ZSH/oh-my-zsh.sh

# User configuration
PROMPT_EOL_MARK=''
setopt PROMPT_SP

# Useful aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias l='ls -lh'
alias grep='grep --color=auto'

# Terraform aliases
alias tf='terraform'
alias tfin='terraform init'
alias tfap='terraform apply'
alias tfapa='terraform apply -auto-approve'
alias tdes='terraform destroy'
alias tdesa='terraform destroy -auto-approve'
alias tplan='terraform plan'
alias tfmt='terraform fmt'
alias tfinap='terraform init && terraform apply'
alias tfinapa='terraform init && terraform apply -auto-approve'
alias tfinda='terraform init && terraform destroy -auto-approve'
alias tfws='terraform workspace'
alias tfwsl='terraform workspace list'
alias tfwss='terraform workspace select'
alias tfwsn='terraform workspace new'
alias tfv='terraform validate'

# SSH without strict host checking
alias ssho='ssh -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'

# Set terminal title
precmd () { print -Pn "\e]0;%~\a" }
EOF

# Install plugins
echo "Installing plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Setup neofetch
setup_neofetch "$@"

# Apply changes and switch to Zsh
echo "Switching to Zsh and applying changes..."
exec zsh
