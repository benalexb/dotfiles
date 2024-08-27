#!/usr/bin/env bash
set -euo pipefail

# Constants
ZSH_CUSTOM="$HOME/.oh-my-zsh/custom"
LOCAL_FONT_DIR="$HOME/.local/share/fonts"
FONTS_SOURCE_DIR="$HOME/dotfiles/fonts"

# Log function to standardize output
log() {
    local level; level=$1
    shift
    printf "[%s] %s: %s\n" "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$level" "$*" >&2
}

# Function to create symlinks, with backup for existing files or symlinks
create_symlink() {
    local source target backup
    source=$1
    target=$2

    if [[ -e "$target" || -L "$target" ]]; then
        backup="${target}_bkup_$(date +%Y%m%d%H%M%S)"
        log INFO "Backing up existing $target to $backup"
        if ! mv "$target" "$backup"; then
            log ERROR "Failed to back up $target"
            return 1
        fi
    fi

    if ! ln -sfn "$source" "$target"; then
        log ERROR "Failed to create symlink: $target -> $source"
        return 1
    fi
}

# Function to clone or update a git repository
clone_or_update_repo() {
    local repo target_dir
    repo=$1
    target_dir=$2

    if [[ -d "$target_dir/.git" ]]; then
        if ! git -C "$target_dir" pull --ff-only; then
            log ERROR "Failed to update repository in $target_dir"
            return 1
        fi
    else
        if ! git clone --depth=1 "$repo" "$target_dir"; then
            log ERROR "Failed to clone repository $repo"
            return 1
        fi
    fi
}

# Function to install fonts to ~/.local/share/fonts
install_fonts() {
    log INFO "Installing fonts..."

    if ! mkdir -p "$LOCAL_FONT_DIR"; then
        log ERROR "Failed to create font directory $LOCAL_FONT_DIR"
        return 1
    fi

    local font_count=0
    local font target_font

    shopt -s nullglob
    for font in "$FONTS_SOURCE_DIR"/*/*.{ttf,otf}; do
        target_font="$LOCAL_FONT_DIR/$(basename "$font")"
        if [[ ! -e "$target_font" ]]; then
            if cp "$font" "$target_font"; then
                ((font_count++))
            else
                log ERROR "Failed to install font: $(basename "$font")"
            fi
        fi
    done
    shopt -u nullglob

    if ! fc-cache -fv "$LOCAL_FONT_DIR" &> /dev/null; then
        log ERROR "Failed to refresh font cache"
        return 1
    fi

    log INFO "$font_count fonts installed."
}

# Function to ensure zsh is installed
install_zsh() {
    if ! command -v zsh &> /dev/null; then
        log INFO "Installing zsh..."
        if ! sudo apt update -q && sudo apt install -y zsh; then
            log ERROR "Failed to install zsh."
            return 1
        fi
    fi
}

# Function to install oh-my-zsh if not present
install_oh_my_zsh() {
    if [[ ! -d "$HOME/.oh-my-zsh" ]]; then
        log INFO "Installing Oh My Zsh..."
        if ! sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"; then
            log ERROR "Failed to install Oh My Zsh."
            return 1
        fi
    fi
}

# Function to install zsh plugins and themes
install_zsh_plugins_and_themes() {
    log INFO "Installing zsh plugins and themes..."
    clone_or_update_repo "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k" || return 1
    clone_or_update_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" || return 1
    clone_or_update_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_CUSTOM/plugins/zsh-autosuggestions" || return 1
}

# Function to set up git configuration
setup_git_config() {
    log INFO "Setting up Git configuration..."
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
    log INFO "Starting setup..."

    install_zsh || return 1
    install_oh_my_zsh || return 1
    install_fonts || return 1

    install_zsh_plugins_and_themes || return 1

    create_symlink "$HOME/dotfiles/config/common/.aliases" "$HOME/.aliases" || return 1
    create_symlink "$HOME/dotfiles/config/common/.p10k.zsh" "$HOME/.p10k.zsh" || return 1
    create_symlink "$HOME/dotfiles/config/common/.vimrc" "$HOME/.vimrc" || return 1
    create_symlink "$HOME/dotfiles/config/debian/.zshrc" "$HOME/.zshrc" || return 1

    setup_git_config || return 1

    log INFO "Setup completed. Launching zsh..."
    exec zsh
}

# Run the main function
main

