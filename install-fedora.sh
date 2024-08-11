#!/bin/bash

# Create symlinks and handle existing files or symlinks
create_symlink() {
  local source=$1
  local target=$2

  if [ -L "$target" ]; then
    rm "$target"
  elif [ -e "$target" ]; then
    mv "$target" "${target}_bkup"
  fi

  ln -s "$source" "$target"
}

# Remove existing directory before git clone
clone_and_replace() {
  local repo=$1
  local target_dir=$2

  if [ -d "$target_dir" ]; then
    rm -rf "$target_dir"
  fi

  git clone "$repo" "$target_dir"
}

# Install fonts located in ~/env/fonts, skipping duplicates.
install_fonts() {
    local fonts_dir="$HOME/env/fonts"
    local target_fonts_dir="$HOME/.local/share/fonts"

    # Create target fonts directory if it doesn't exist
    mkdir -p "$target_fonts_dir"

    if [ ! -d "$fonts_dir" ]; then
        echo "Fonts directory not found: $fonts_dir"
        return 1
    fi

    find "$fonts_dir" -type f \( -iname "*.ttf" -o -iname "*.otf" \) | while IFS= read -r font; do
        local font_file=$(basename "$font")
        local target_font="$target_fonts_dir/$font_file"

        if [ -e "$target_font" ]; then
            echo "Skipping font: $font_file (already installed)"
        else
            cp "$font" "$target_font"
            echo "Installed font: $font_file"
        fi
    done

    # Update font cache
    fc-cache -fv "$target_fonts_dir"

    echo "Fonts installation completed!"
}

# Check if zsh is installed; if not, install it
install_zsh() {
  if ! command -v zsh > /dev/null 2>&1; then
    echo "zsh could not be found. Installing zsh..."
    sudo dnf install -y zsh
  else
    echo "zsh is already installed."
  fi
}

# Run the zsh installation function
# install_zsh

# Install fonts
# install_fonts

# Change to the home directory
cd $HOME

# 1. Install ohmyzsh only if $ZSH is not set
if [ -z "$ZSH" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
fi

# 2. Install powerlevel10k
clone_and_replace "https://github.com/romkatv/powerlevel10k.git" "$HOME/.oh-my-zsh/custom/themes/powerlevel10k"

# 3. Install zsh-syntax-highlighting
clone_and_replace "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$HOME/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"

# 4. Install zsh-autosuggestions
clone_and_replace "https://github.com/zsh-users/zsh-autosuggestions" "$HOME/.oh-my-zsh/custom/plugins/zsh-autosuggestions"

# 5. Create symlinks for .aliases .p10k.zsh .vimrc
create_symlink "$HOME/env/config/common/.aliases" "$HOME/.aliases"
create_symlink "$HOME/env/config/common/.p10k.zsh" "$HOME/.p10k.zsh"
create_symlink "$HOME/env/config/common/.vimrc" "$HOME/.vimrc"

# 6. Create symlink for .zshrc
create_symlink "$HOME/env/config/fedora/.zshrc" "$HOME/.zshrc"

# 7. Set up git configs
git config --global user.name "Benjamin Barreto"
git config --global user.email "benalexb@gmail.com"
git config --global core.editor "vim"
git config --global core.pager "delta"
git config --global init.defaultbranch "master"
git config --global interactive.difffilter "delta --color-only --features=interactive"
git config --global --add include.path "${HOME}/env/config/common/delta.gitconfig"
git config --global --add include.path "${HOME}/env/config/common/delta-themes.gitconfig"

# Ensure .zshrc is correctly sourcing Oh My Zsh
if [ -f "$HOME/.oh-my-zsh/oh-my-zsh.sh" ]; then
    source "$HOME/.oh-my-zsh/oh-my-zsh.sh"
else
    echo "Oh My Zsh is not installed correctly."
fi

# Start zsh
exec zsh
