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
            log INFO "Processing font: $font"
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
        else
            log WARNING "No valid font files found at: $font"
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
       
