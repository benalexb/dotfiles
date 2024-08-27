#!/usr/bin/env bash
set -euo pipefail

# Constants
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
LOCAL_FONT_DIR="$HOME/.local/share/fonts"
FONTS_SOURCE_DIR="$HOME/dotfiles/fonts"

# Log function to standardize output
log() {
    local level=$1
    shift
    echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')][$level] $*"
}

# Function to create symlinks, with backup for existing files or symlinks
create_symlink() {
    local source=$1
    local target=$2

    if [ -e "$target" ]; then
        local backup="${target}_bkup_$(date +%Y%m%d%H%M%S)"
        log INFO "Backing up $target to $backup"
        mv "$target" "$backup"
    fi

    ln -sfn "$source" "$target"
    log INFO "Created symlink: $target -> $source"
}

# Function to clone or update a git repository
clone_or_update_repo() {
    local repo=$1
    local target_dir=$2

    if [ -d "$target_dir/.git" ]; then
        log INFO "Updating existing repository in $target_dir"
        git -C "$target_dir" pull --ff-only
    else
        log INFO "Cloning repository from $repo into $target_dir"
        git clone --depth=1 "$repo" "$target_dir"
    fi
}

# Function to install fonts to ~/.local/share/fonts
install_fonts() {
    log INFO "Starting font installation from $FONTS_SOURCE_DIR..."

    mkdir -p "$LOCAL_FONT_DIR"

    local font_count=0

    # Loop through each font file and copy it
    for font in "$FONTS_SOURCE_DIR"/*/*.{ttf,otf}; do
        if [ -f "$font" ]; then
            local target_font="$LOCAL_FONT_DIR/$(basename "$font")"

            if [ ! -e "$target_font" ]; then
                if cp "$font" "$target_font"; then
                    log INFO "Installed font: $(basename "$font")"
                    ((font_count++))
                else
                    log ERROR "Failed to install font: $(basename "$font")"
                fi
            else
                log INFO "Skipping font: $(basename "$font") (already installed)"
            fi
        fi
    done

    fc-cache -fv "$LOCAL_FONT_DIR"

    if [ "$font_count" -gt 0 ]; then
        log INFO "$font_count fonts installed successfully."
    else
        log INFO "No new fonts were installed."
    fi

    log INFO "Font installation completed!"
}

# Function to ensure zsh is installed
install_zsh() {
    if ! command -v zsh &> /dev/null; then
        log INFO "zsh not found. Installing zsh..."
        sudo apt update && sudo apt install -y zsh || {
            log ERROR "Failed to install zsh."
            exit 1
        }
    else
        log INFO "zsh is already installed."
    fi
}

# Function to install oh-my-zsh if not present
install_oh_my_zsh() {
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        log INFO "Installing Oh My Zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" || {
            log ERROR "Failed to install Oh My Zsh."
            exit 1
        }
    else
        log INFO "Oh My Zsh is already installed."
    fi
}

# Function to install zsh plugins and themes
install_zsh_plugins_and_themes() {
    log INFO "Installing zsh plugins and themes"
    clone_or_update_repo "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"
    clone_or_update_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
    clone_or_update_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
}

# Function to set up git configuration
setup_git_config() {
    log INFO "Setting up Git configuration"
    git config --global user.name "Benjamin Barreto"
    git config --global user.email "benalexb@gmail.com"
    git config --global core.editor "vim"
    git config --global core.pager "delta"
    git config --global init.defaultbranch "master"
    git config --global interactive.difffilter "delta --color-only --features=interactive"
    git config --global --add include.path "${HOME}/dotfiles/config/common/delta.gitconfig"
    git config --global --add include.path "${HOME}/dotfiles/config/common/delta-themes.gitconfig"
}

# Main function to coordinate the setup
main() {
    log INFO "Starting setup script"

    install_zsh
    install_oh_my_zsh
    install_fonts
    install_zsh_plugins_and_themes

    create_symlink "$HOME/dotfiles/config/common/.aliases" "$HOME/.aliases"
    cre
