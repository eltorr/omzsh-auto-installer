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

# Function to install shell management tools
install_shell_tools() {
    echo "Installing shell management utilities..."
    if command -v apt > /dev/null; then
        # Debian/Ubuntu
        sudo apt update && sudo apt install -y util-linux passwd
    elif command -v dnf > /dev/null; then
        # Fedora/RHEL 8+
        sudo dnf install -y util-linux
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

# Function to properly register zsh shell
register_zsh_shell() {
    echo "Registering zsh shell..."
    ZSH_PATH=$(which zsh)
    if [ -n "$ZSH_PATH" ]; then
        echo "Found zsh at: $ZSH_PATH"
        # Check if zsh is already in /etc/shells
        if ! grep -q "$ZSH_PATH" /etc/shells; then
            echo "Adding $ZSH_PATH to /etc/shells"
            echo "$ZSH_PATH" | sudo tee -a /etc/shells
        else
            echo "$ZSH_PATH already in /etc/shells"
        fi
    else
        echo "ZSH not found! Installation may have failed."
        exit 1
    fi
}

# Function to setup neofetch with custom ASCII art
setup_neofetch() {
    echo "Installing Neofetch..."
    # Try to install neofetch from package manager
    if ! install_packages neofetch; then
        echo "Installing Neofetch from source repository..."
        # Remove existing directory if present
        rm -rf /tmp/neofetch
        
        # Clone and install neofetch
        cd /tmp
        git clone https://github.com/dylanaraps/neofetch.git
        cd neofetch
        # No compilation needed - just copy the script
        sudo cp -v neofetch /usr/local/bin/
        sudo chmod +x /usr/local/bin/neofetch
        cd $HOME
        echo "Neofetch installed to /usr/local/bin/"
    fi

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

########################################
# MAIN SCRIPT EXECUTION STARTS HERE
########################################

echo "=== Starting ZSH and Developer Environment Setup ==="

# 1. Cleanup existing installations
echo "Step 1: Cleaning up any existing installations..."
cleanup_all

# 2. Install all required dependencies
echo "Step 2: Installing all required dependencies..."
install_packages zsh git wget curl
install_shell_tools

# 3. Register ZSH shell
echo "Step 3: Registering ZSH shell..."
register_zsh_shell

# 4. Install Oh My Zsh and configure shell
echo "Step 4: Installing Oh My Zsh and configuring shell..."
ZSH= RUNZSH=no KEEP_ZSHRC=yes CHSH=no sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 5. Configure .zshrc
echo "Step 5: Creating ZSH configuration..."
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

# 6. Install plugins
echo "Step 6: Installing ZSH plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting

# 7. Setup Neofetch
echo "Step 7: Setting up Neofetch..."
setup_neofetch

# 8. Configure .bashrc to launch zsh
echo "Step 8: Setting up .bashrc to launch ZSH automatically..."
if ! grep -q "exec zsh" $HOME/.bashrc; then
    echo "# Start zsh if it exists" >> $HOME/.bashrc
    echo "if [ -f /bin/zsh ] || [ -f /usr/bin/zsh ] || [ -f /usr/sbin/zsh ]; then" >> $HOME/.bashrc
    echo "    if [[ \$- == *i* ]]; then" >> $HOME/.bashrc
    echo "        exec zsh" >> $HOME/.bashrc
    echo "    fi" >> $HOME/.bashrc
    echo "fi" >> $HOME/.bashrc
fi

# 9. Set zsh as default shell
echo "Step 9: Setting ZSH as default shell..."
ZSH_PATH=$(which zsh)
if [ -n "$ZSH_PATH" ]; then
    echo "Attempting to change shell with chsh..."
    sudo chsh -s "$ZSH_PATH" "$USER"
    
    echo "NOTE: For the shell change to take effect, you may need to log out and log back in."
    echo "ZSH path: $ZSH_PATH"
    echo "Current user: $USER"
    echo "Current shell according to passwd: $(getent passwd "$USER" | cut -d: -f7)"
else
    echo "ZSH not found! Cannot change shell."
fi

echo "=== Setup complete! ==="
echo "Starting ZSH for current session..."

# 10. Switch to Zsh for current session
exec "$ZSH_PATH" -l
