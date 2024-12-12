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

# Function to remove existing Zsh and Oh My Zsh installations
cleanup_zsh() {
    echo "Removing existing Zsh and Oh My Zsh installations..."
    rm -rf $HOME/.oh-my-zsh
    if command -v apt > /dev/null; then
        sudo apt remove --purge zsh -y
    elif command -v dnf > /dev/null; then
        sudo dnf remove zsh -y
    elif command -v yum > /dev/null; then
        sudo yum remove zsh -y
    elif command -v pacman > /dev/null; then
        sudo pacman -Rns --noconfirm zsh
    fi
    rm -f $HOME/.zshrc $HOME/.zsh_history
    echo "Cleanup complete."
}

# Cleanup existing installations
cleanup_zsh

# Update and install Zsh and necessary packages
echo "Installing Zsh, Git, Wget, and Curl..."
install_packages zsh git wget curl

# Install Oh My Zsh without switching to zsh shell automatically
echo "Installing Oh My Zsh..."
RUNZSH=no KEEP_ZSHRC=yes sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Check if .zshrc exists; if not, create a default one
if [ ! -f $HOME/.zshrc ]; then
    echo "Creating a default .zshrc from template..."
    cp $HOME/.oh-my-zsh/templates/zshrc.zsh-template $HOME/.zshrc
fi

# Set Zsh as the default shell
echo "Setting Zsh as the default shell..."
chsh -s $(which zsh)

# Install Powerlevel10k theme
echo "Installing Powerlevel10k theme..."
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
sed -i '/^ZSH_THEME=/c\ZSH_THEME="powerlevel10k/powerlevel10k"' $HOME/.zshrc

# Disable automatic configuration wizard
echo "Disabling automatic Powerlevel10k configuration wizard..."
echo 'export POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true' >> $HOME/.zshrc

# Install and configure plugins
echo "Installing plugins..."
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
sed -i '/^plugins=(/c\plugins=(git zsh-autosuggestions zsh-syntax-highlighting)' $HOME/.zshrc

# Install Neofetch for system information on terminal start
echo "Installing Neofetch..."
install_packages neofetch
if ! grep -q 'neofetch' $HOME/.zshrc; then
    echo "neofetch" >> $HOME/.zshrc
fi

# Modify .bashrc to launch Zsh
echo "Configuring .bashrc to launch Zsh..."
if ! grep -q 'exec zsh' $HOME/.bashrc; then
    echo 'exec zsh' >> $HOME/.bashrc
fi

# Apply changes and switch to Zsh
echo "Switching to Zsh and applying changes..."
exec zsh
