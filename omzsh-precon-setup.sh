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

cleanup_all() {
    echo "Performing comprehensive cleanup..."

    # Remove Zsh-specific components
    echo "Removing Zsh..."
    rm -rf $HOME/.oh-my-zsh
    rm -f $HOME/.zshrc $HOME/.zsh_history
    if command -v apt > /dev/null; then
        sudo apt remove --purge zsh -y
    elif command -v dnf > /dev/null; then
        sudo dnf remove zsh -y
    elif command -v yum > /dev/null; then
        sudo yum remove zsh -y
    elif command -v pacman > /dev/null; then
        sudo pacman -Rns --noconfirm zsh
    fi

    # Remove Powerlevel10k configuration (if it exists outside Oh My Zsh)
    echo "Removing Powerlevel10k configuration..."
    rm -f $HOME/.p10k.zsh

    # Remove other shell configurations (bash, fish, etc.) if needed
    echo "Removing Bash configuration (if it was modified for zsh)..."
    if grep -q 'exec zsh' $HOME/.bashrc; then
        sed -i '/exec zsh/d' $HOME/.bashrc
    fi

    # Remove other potential terminal customizations
    echo "Removing other potential terminal customizations..."
    # Example: if you've modified your terminal's profile settings directly
    # (These paths are examples and might vary depending on your system)
    # rm -f $HOME/.config/terminator/config # For Terminator
    # rm -f $HOME/.config/gnome-terminal/ # For Gnome Terminal
    # ... add other terminal-specific paths as needed

    # Remove related packages (if they were installed specifically for zsh)
    echo "Removing related packages (if applicable)..."
    if command -v apt > /dev/null; then
        sudo apt remove --purge neofetch -y
    elif command -v dnf > /dev/null; then
        sudo dnf remove neofetch -y
    elif command -v yum > /dev/null; then
        sudo yum remove neofetch -y
    elif command -v pacman > /dev/null; then
        sudo pacman -Rns --noconfirm neofetch
    fi
    
    # Remove any custom fonts you might have installed for Powerlevel10k
    echo "Removing custom fonts (if applicable)..."
    # Example: If you installed fonts to ~/.local/share/fonts
    # rm -rf $HOME/.local/share/fonts/Meslo* # Replace Meslo* with the actual font name

    echo "Comprehensive cleanup complete."
}

# Cleanup existing installations
cleanup_all

# Update and install Zsh and necessary packages
echo "Installing Zsh, Git, Wget, and Curl..."
install_packages zsh git wget curl

# Install Oh My Zsh without switching to zsh shell automatically
echo "Installing Oh My Zsh..."
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Check if .zshrc exists, if not, create a default one
if [ ! -f $HOME/.zshrc ]; then
    echo "Creating a default .zshrc from template..."
    cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc
fi

# Update .zshrc with necessary configurations before p10k
sed -i '1i\
# Disable p10k configuration wizard and use ASCII\
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true\
POWERLEVEL9K_MODE=ascii\
\
# Disable special characters\
POWERLEVEL9K_VCS_DISABLE_GITSTATUS=true\
POWERLEVEL9K_DISABLE_HOT_RELOAD=true\
\
# Fix prompt spacing\
ZLE_RPROMPT_INDENT=0\
POWERLEVEL9K_LEGACY_ICON_SPACING=true' $HOME/.zshrc

# Create a basic p10k config file using pure ASCII characters
cat > $HOME/.p10k.zsh << 'EOF'
# Force ASCII mode
POWERLEVEL9K_MODE=ascii

# Basic p10k configuration
typeset -g POWERLEVEL9K_LEFT_PROMPT_ELEMENTS=(user dir vcs newline prompt_char)
typeset -g POWERLEVEL9K_RIGHT_PROMPT_ELEMENTS=(status time)

# Minimal ASCII symbols
typeset -g POWERLEVEL9K_VCS_BRANCH_ICON=''
typeset -g POWERLEVEL9K_HOME_ICON=''
typeset -g POWERLEVEL9K_HOME_SUB_ICON='/'
typeset -g POWERLEVEL9K_FOLDER_ICON=''
typeset -g POWERLEVEL9K_VCS_STAGED_ICON='*'
typeset -g POWERLEVEL9K_VCS_UNSTAGED_ICON='!'
typeset -g POWERLEVEL9K_VCS_UNTRACKED_ICON='?'
typeset -g POWERLEVEL9K_PROMPT_CHAR_OK_VIINS_CONTENT_EXPANSION='$'

# Directory truncation
typeset -g POWERLEVEL9K_SHORTEN_STRATEGY="truncate_to_last"
typeset -g POWERLEVEL9K_SHORTEN_DIR_LENGTH=1
typeset -g POWERLEVEL9K_DIR_MAX_LENGTH=30
typeset -g POWERLEVEL9K_DIR_SHOW_WRITABLE=true

# Simple prompt style
typeset -g POWERLEVEL9K_PROMPT_ON_NEWLINE=true
typeset -g POWERLEVEL9K_MULTILINE_FIRST_PROMPT_PREFIX=""
typeset -g POWERLEVEL9K_MULTILINE_NEWLINE_PROMPT_PREFIX=""
typeset -g POWERLEVEL9K_MULTILINE_LAST_PROMPT_PREFIX="$ "

# Disable all fancy features
typeset -g POWERLEVEL9K_VCS_DISABLE_GITSTATUS=true
typeset -g POWERLEVEL9K_DISABLE_HOT_RELOAD=true
EOF

# Install and configure Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i '/ZSH_THEME=/c\ZSH_THEME="powerlevel10k/powerlevel10k"' $HOME/.zshrc

# Install and configure plugins
echo "Installing plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i '/plugins=(/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' $HOME/.zshrc

# Function to setup neofetch with custom ASCII art
setup_neofetch() {
    local ascii_art_path=${1:-"$HOME/.config/neofetch/ascii_art.txt"}
    
    echo "Installing Neofetch..."
    install_packages neofetch

    # Create neofetch config directory if it doesn't exist
    mkdir -p $HOME/.config/neofetch

    # If custom ASCII art path is provided and exists, copy it
    if [ "$1" ] && [ -f "$1" ]; then
        echo "Using custom ASCII art from: $1"
        cp "$1" $HOME/.config/neofetch/ascii_art.txt
    fi

    # Create custom neofetch config if it doesn't exist
    if [ ! -f "$HOME/.config/neofetch/config.conf" ]; then
        echo "Creating default neofetch config..."
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
    fi

    # Add neofetch with explicit config to zshrc
    echo 'neofetch --config ${HOME}/.config/neofetch/config.conf --ascii ${HOME}/.config/neofetch/ascii_art.txt' >> $HOME/.zshrc
}

# Function to setup default directory
setup_default_directory() {
    local default_dir="/vm/ovfs/configs/goldbuild-vlaptop"
    
    # Create the directory if it doesn't exist
    echo "Creating default working directory..."
    mkdir -p "$default_dir"
    
    # Add to .bashrc (for backup/initial login)
    echo "cd $default_dir" >> $HOME/.bashrc
    
    # Add to .zshrc (for zsh)
    echo "cd $default_dir" >> $HOME/.zshrc
    
    # Set proper ownership
    chown -R $USER:$USER "$default_dir"
}

# Call setup_neofetch with optional custom ASCII art path
setup_neofetch "$@"

# Setup default directory
setup_default_directory

# Add Terraform aliases to .zshrc
cat >> $HOME/.zshrc << 'EOF'

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
alias tfst='terraform state'
alias tfstl='terraform state list'
alias tfsts='terraform state show'
alias tfo='terraform output'
alias tfim='terraform import'
alias tfpr='terraform providers'

# Terraform workspace color status in prompt
alias tfwsc='terraform workspace show | grep "*" > /dev/null && echo -n "($(terraform workspace show))"'

# Combined commands
alias tfinv='terraform init && terraform validate'
alias tfinp='terraform init && terraform plan'
alias tfref='terraform refresh'

# Terraform with variables
alias tfapv='terraform apply -var-file'
alias tplv='terraform plan -var-file'

# Terraform state manipulation
alias tfstm='terraform state mv'
alias tfstr='terraform state rm'
alias tfstp='terraform state pull'
alias tfstpu='terraform state push'

# Terraform documentation
alias tfdoc='terraform-docs'
EOF

# Apply changes and switch to Zsh
echo "Switching to Zsh and applying changes..."
exec zsh
