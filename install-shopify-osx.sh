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

# 5. Create symlinks for .aliases and .p10k.zsh
create_symlink "$HOME/dotfiles/config/common/.aliases" "$HOME/.aliases"
create_symlink "$HOME/dotfiles/config/common/.p10k.zsh" "$HOME/.p10k.zsh"

# 6. Create symlink for .zshrc
create_symlink "$HOME/dotfiles/config/shopify/osx/.zshrc" "$HOME/.zshrc"

# 7. Set up git configs
git config --global user.name "Benjamin Barreto"
git config --global user.email "benjamin.barreto@shopify.com"
git config --global core.editor "code -w"
git config --global core.pager "delta"
git config --global init.defaultbranch "master"
git config --global interactive.difffilter "delta --color-only --features=interactive"
git config --global --add include.path "${HOME}/dotfiles/config/common/delta.gitconfig"
git config --global --add include.path "${HOME}/dotfiles/config/common/delta-themes.gitconfig"

exec zsh
