## omzsh-auto-installer

Automates Oh My Zsh installation with Powerlevel10k, plugins, and Neofetch.

**Features:**

*   Installs Zsh, Oh My Zsh, Powerlevel10k (wizard disabled), plugins (autosuggestions, syntax highlighting), and Neofetch.
*   Sets Zsh as the default shell.

**Installation:**

**1. Download and Run:**

```bash
curl -sSL https://raw.githubusercontent.com/eltorr/omzsh-auto-installer/refs/heads/main/omzsh-setup.sh > omzsh-setup.sh
chmod +x omzsh-setup.sh
./omzsh-setup.sh
```

**2. Run Inline:**

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/eltorr/omzsh-auto-installer/refs/heads/main/omzsh-setup.sh)"
```

**Post-Installation:**

**Powerlevel10k Configuration (Optional):**

Edit `~/.p10k.zsh` for customization. See [https://github.com/romkatv/powerlevel10k](https://github.com/romkatv/powerlevel10k) for details.

**Disclaimer:** Use at your own risk.
