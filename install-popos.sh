#!/bin/bash
set -euo pipefail

# Function to create symlinks, with backup for existing files or symlinks
create_symlink() {
    local source=$1
    local target=$2

    if [ -e "$target" ]; then
        mv "$target" "${target}_bkup_$(date +%Y%m%d%H%M%S)"
    fi

    ln -sfn "$source" "$target"
}

# Function to clone or update a git repository
clone_or_update_repo() {
    local repo=$1
    local target_dir=$2

    if [ -d "$target_dir/.git" ]; then
        git -C "$target_dir" pull --ff-only
    else
        git clone --depth=1 "$repo" "$target_dir"
    fi
}

# Function to install fonts, skipping duplicates
install_fonts() {
    local fonts_dir="$HOME/env/fonts"
    local target_fonts_dir="$HOME/.local/share/fonts"

    mkdir -p "$target_fonts_dir"

    if [ ! -d "$fonts_dir" ]; then
        echo "Fonts directory not found: $fonts_dir" >&2
        return 1
    fi

    find "$fonts_dir" -type f \( -iname "*.ttf" -o -iname "*.otf" \) | while read -r font; do
        local target_font="$target_fonts_dir/$(basename "$font")"

        if [ ! -e "$target_font" ]; then
            cp "$font" "$target_font"
            echo "Installed font: $(basename "$font")"
        else
            echo "Skipping font: $(basename "$font") (already installed)"
        fi
    done

    fc-cache -fv "$target_fonts_dir"
    echo "Fonts installation completed!"
}

# Install zsh if not installed
install_zsh() {
    if ! command -v zsh &> /dev/null; then
        echo "zsh not found. Installing zsh..."
        sudo apt update && sudo apt install -y zsh
    else
        echo "zsh is already installed."
    fi
}

# Ensure the script is running in the user's home directory
cd "$HOME"

# Execute the installation steps

install_zsh

install_fonts

# Install oh-my-zsh if not already installed
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    echo "Installing Oh My Zsh..."
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# Install powerlevel10k theme
clone_or_update_repo "https://github.com/romkatv/powerlevel10k.git" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

# Install zsh-syntax-highlighting plugin
clone_or_update_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

# Install zsh-autosuggestions plugin
clone_or_update_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

# Create symlinks for configuration files
create_symlink "$HOME/env/config/common/.aliases" "$HOME/.aliases"
create_symlink "$HOME/env/config/common/.p10k.zsh" "$HOME/.p10k.zsh"
create_symlink "$HOME/env/config/common/.vimrc" "$HOME/.vimrc"
create_symlink "$HOME/env/config/debian/.zshrc" "$HOME/.zshrc"

# Set up git configuration
git config --global user.name "Benjamin Barreto"
git config --global user.email "benalexb@gmail.com"
git config --global core.editor "vim"
git config --global core.pager "delta"
git config --global init.defaultbranch "master"
git config --global interactive.difffilter "delta --color-only --features=interactive"
git config --global --add include.path "${HOME}/env/config/common/delta.gitconfig"
git config --global --add include.path "${HOME}/env/config/common/delta-themes.gitconfig"

# Ensure Oh My Zsh is sourced correctly
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    echo "Sourcing Oh My Zsh..."
    source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
else
    echo "Oh My Zsh installation seems to have failed." >&2
    exit 1
fi

# Start zsh
exec zsh
