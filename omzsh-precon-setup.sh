#!/bin/bash

# Function to detect package manager and install packages
install_packages() {
    if command -v apt > /dev/null; then
        echo "Using APT package manager."
        sudo apt update && sudo apt install -y "$@"
    elif command -v dnf > /dev/null; then
        echo "Using DNF package manager."
        sudo dnf install -y "$@"
    elif command -v yum > /dev/null; then
        echo "Using YUM package manager."
        sudo yum install -y "$@"
    elif command -v pacman > /dev/null; then
        echo "Using Pacman package manager."
        sudo pacman -Syu --noconfirm "$@"
    else
        echo "No supported package manager found. Install manually."
        exit 1
    fi
}

# Function to install shell management tools to use chsh and set zsh as default shell
install_shell_tools() {
    echo "Installing shell management utilities..."
    if command -v apt > /dev/null; then
        # Debian/Ubuntu
        sudo apt update && sudo apt install -y util-linux passwd
    elif command -v dnf > /dev/null; then
        # Fedora/RHEL 8+
        sudo dnf install -y util-linux-user
    elif command -v yum > /dev/null; then
        # CentOS/RHEL 7
        sudo yum install -y util-linux-user
    elif command -v pacman > /dev/null; then
        # Arch Linux
        sudo pacman -Syu --noconfirm util-linux
    fi
}

cleanup_all() {
    echo "Performing comprehensive cleanup..."
    rm -rf $HOME/.oh-my-zsh
    rm -f $HOME/.zshrc $HOME/.zsh_history
    rm -f $HOME/.p10k.zsh  # Remove p10k config

    # Remove zsh and related packages
    if command -v apt > /dev/null; then
        sudo apt remove --purge zsh neofetch -y
    elif command -v dnf > /dev/null; then
        sudo dnf remove zsh neofetch -y
    elif command -v yum > /dev/null; then
        sudo yum remove zsh neofetch -y
    elif command -v pacman > /dev/null; then
        sudo pacman -Rns --noconfirm zsh neofetch
    fi
}

# Cleanup existing installations
cleanup_all

# Install required packages
echo "Installing required packages..."
install_packages zsh git wget curl

# Install shell management tools
install_shell_tools

# Install Oh My Zsh
echo "Installing Oh My Zsh..."
ZSH= RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Configure .zshrc
cat > $HOME/.zshrc << 'EOF'
# Path to oh-my-zsh installation
export ZSH="$HOME/.oh-my-zsh"

# Theme settings
ZSH_THEME="robbyrussell"

# Plugins
plugins=(
    git
    zsh-autosuggestions
    zsh-syntax-highlighting
    colored-man-pages
    command-not-found
    history-substring-search
)

# Source oh-my-zsh
source $ZSH/oh-my-zsh.sh

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

# Common aliases
alias ls='ls --color=auto'
alias ll='ls -lah'
alias l='ls -lh'
alias grep='grep --color=auto'
EOF

# Install plugins
echo "Installing plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# Function to setup neofetch with custom ASCII art
setup_neofetch() {
    echo "Installing Neofetch..."
    install_packages neofetch

    # Create neofetch config directory
    mkdir -p $HOME/.config/neofetch

    # Create ASCII art file
    cat > $HOME/.config/neofetch/ascii_art.txt << 'EOF'
··························
:██████╗  ██████╗  ███████╗:
:██╔══██╗ ██╔══██╗ ██╔════╝:
:██████╔╝ ██║  ██║ █████╗  :
:██╔══██╗ ██║  ██║ ██╔══╝  :
:██║  ██║ ██████╔╝ ██║     :
:╚═╝  ╚═╝ ╚═════╝  ╚═╝     :
··························
Rapid Deployment Framework...
EOF

    # Create custom neofetch config
    cat > $HOME/.config/neofetch/config.conf << 'EOF'
print_info() {
    info title
    info underline
    info "OS" distro
    info "Host" model
    info "Kernel" kernel
    info "Uptime" uptime
    info "Packages" packages
    info "Shell" shell
    info "CPU" cpu
    info "Memory" memory
}

# ASCII Settings
ascii_distro="none"
ascii_colors=(4 4 4 4 4 6)
ascii_bold="on"

# Use custom ASCII art file
image_backend="ascii"
image_source="${HOME}/.config/neofetch/ascii_art.txt"
EOF

    # Add neofetch with explicit config to zshrc
    echo 'neofetch --config ${HOME}/.config/neofetch/config.conf --ascii ${HOME}/.config/neofetch/ascii_art.txt' >> $HOME/.zshrc
}

# Setup neofetch
setup_neofetch "$@"

# Set zsh as default shell
echo "Setting zsh as default shell..."
sudo chsh -s $(which zsh) $USER

# Add zsh launch to .bashrc for non-login shells
echo "Adding zsh launch to .bashrc..."
if ! grep -q "exec zsh" $HOME/.bashrc; then
    echo "# Start zsh if it exists" >> $HOME/.bashrc
    echo "if [ -f /bin/zsh ] || [ -f /usr/bin/zsh ]; then" >> $HOME/.bashrc
    echo "    if [[ \$- == *i* ]]; then" >> $HOME/.bashrc
    echo "        exec zsh" >> $HOME/.bashrc
    echo "    fi" >> $HOME/.bashrc
    echo "fi" >> $HOME/.bashrc
fi

# Switch to Zsh
echo "Switching to Zsh..."
exec zsh
