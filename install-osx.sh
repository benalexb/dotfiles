#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"
CURRENT_STEP="initialization"

SKIP_FONTS=false
SKIP_OMZ=false

log() {
  local level=$1
  shift
  printf '[%s] %s: %s\n' "$(date +'%Y-%m-%dT%H:%M:%S%z')" "$level" "$*"
}

on_error() {
  log ERROR "Failed during step: ${CURRENT_STEP}"
}

trap on_error ERR

usage() {
  cat <<EOF
Usage: $(basename "$0") [options]

Options:
  --skip-fonts   Skip font installation
  --skip-omz     Skip oh-my-zsh and plugin setup
  -h, --help     Show this help message
EOF
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --skip-fonts) SKIP_FONTS=true ;;
      --skip-omz) SKIP_OMZ=true ;;
      -h|--help)
        usage
        exit 0
        ;;
      *)
        log ERROR "Unknown option: $1"
        usage
        exit 1
        ;;
    esac
    shift
  done
}

require_command() {
  local command_name=$1
  if ! command -v "$command_name" &>/dev/null; then
    log ERROR "Required command not found: ${command_name}"
    exit 1
  fi
}

ensure_env_file() {
  local env_file="$DOTFILES_DIR/.env"

  if [[ -f "$env_file" ]]; then
    return 0
  fi

  if [[ ! -f "$DOTFILES_DIR/.env.example" ]]; then
    log WARN "No .env file found at ${env_file}"
    return 1
  fi

  cp "$DOTFILES_DIR/.env.example" "$env_file"
  log WARN "Created ${env_file} from .env.example — edit it with your values"
}

link_env() {
  ensure_env_file || return 0
  create_symlink "$DOTFILES_DIR/.env" "$HOME/.env"
}

load_env() {
  CURRENT_STEP="load environment"
  link_env

  if [[ ! -f "$HOME/.env" ]]; then
    return 0
  fi

  set -a
  # shellcheck source=/dev/null
  source "$HOME/.env"
  set +a
}

create_symlink() {
  local source=$1
  local target=$2

  if [[ ! -e "$source" ]]; then
    log ERROR "Symlink source not found: $source"
    return 1
  fi

  if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
    return 0
  fi

  if [[ -e "$target" || -L "$target" ]]; then
    local backup="${target}_bkup_$(date +%Y%m%d%H%M%S)"
    log INFO "Backing up existing ${target} to ${backup}"
    mv "$target" "$backup"
  fi

  ln -sfn "$source" "$target"
}

clone_or_update_repo() {
  local repo=$1
  local target_dir=$2

  if [[ -d "$target_dir/.git" ]]; then
    git -C "$target_dir" pull --ff-only
    return
  fi

  git clone --depth=1 "$repo" "$target_dir"
}

install_fonts() {
  CURRENT_STEP="install fonts"
  local fonts_dir="$DOTFILES_DIR/fonts/JetBrainsMono"
  local target_fonts_dir="$HOME/Library/Fonts"
  local font_count=0

  if [[ ! -d "$fonts_dir" ]]; then
    log WARN "Font directory not found: $fonts_dir"
    return 0
  fi

  shopt -s nullglob
  for font in "$fonts_dir"/JetBrainsMonoNerdFontMono-*.ttf; do
    local target_font="$target_fonts_dir/$(basename "$font")"
    if [[ -e "$target_font" ]]; then
      log INFO "Skipping font: $(basename "$font") (already installed)"
      continue
    fi

    cp "$font" "$target_font"
    log INFO "Installed font: $(basename "$font")"
    ((font_count++)) || true
  done
  shopt -u nullglob

  log INFO "${font_count} fonts installed"
}

install_oh_my_zsh() {
  CURRENT_STEP="install oh-my-zsh"
  if [[ -d "$HOME/.oh-my-zsh" ]]; then
    log INFO "Oh My Zsh already installed"
    return 0
  fi

  RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
}

install_zsh_plugins_and_themes() {
  CURRENT_STEP="install zsh plugins and themes"
  mkdir -p "$ZSH_CUSTOM/themes" "$ZSH_CUSTOM/plugins"

  clone_or_update_repo "https://github.com/romkatv/powerlevel10k.git" "$ZSH_CUSTOM/themes/powerlevel10k"
  clone_or_update_repo "https://github.com/zsh-users/zsh-syntax-highlighting.git" "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  clone_or_update_repo "https://github.com/zsh-users/zsh-autosuggestions.git" "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
}

install_brew_packages() {
  CURRENT_STEP="install brew packages"
  if ! command -v brew &>/dev/null; then
    log WARN "Homebrew not found — skipping brew package installation"
    return 0
  fi

  if ! brew list git-delta &>/dev/null; then
    brew install git-delta
  else
    log INFO "git-delta already installed"
  fi

  if [[ -f "$DOTFILES_DIR/Brewfile" ]]; then
    brew bundle --file="$DOTFILES_DIR/Brewfile"
  fi
}

git_config_set_if_unset() {
  local key=$1
  local value=$2

  if [[ -z "$value" ]]; then
    log WARN "Skipping git config ${key} — value not set in ~/.env"
    return 0
  fi

  if git config --global --get "$key" &>/dev/null; then
    log INFO "Git config ${key} already set"
    return 0
  fi

  git config --global "$key" "$value"
}

git_config_add_include_if_missing() {
  local include_path=$1

  if git config --global --get-all include.path | grep -Fxq "$include_path"; then
    log INFO "Git include already configured: ${include_path}"
    return 0
  fi

  git config --global --add include.path "$include_path"
}

setup_git_config() {
  CURRENT_STEP="setup git config"
  git_config_set_if_unset user.name "${GIT_USER_NAME:-}"
  git_config_set_if_unset user.email "${GIT_USER_EMAIL:-}"
  git config --global core.editor "vim"
  git config --global core.pager "delta"
  git config --global init.defaultBranch "master"
  git config --global interactive.diffFilter "delta --color-only --features=interactive"
  git_config_add_include_if_missing "${DOTFILES_DIR}/config/common/delta.gitconfig"
  git_config_add_include_if_missing "${DOTFILES_DIR}/config/common/delta-themes.gitconfig"
}

link_dotfiles() {
  CURRENT_STEP="link dotfiles"
  link_env
  create_symlink "$DOTFILES_DIR/config/common/.aliases" "$HOME/.aliases"
  create_symlink "$DOTFILES_DIR/config/common/.p10k.zsh" "$HOME/.p10k.zsh"
  create_symlink "$DOTFILES_DIR/config/common/.vimrc" "$HOME/.vimrc"
  create_symlink "$DOTFILES_DIR/config/osx/.zprofile" "$HOME/.zprofile"
  create_symlink "$DOTFILES_DIR/config/osx/.zshrc" "$HOME/.zshrc"
}

main() {
  parse_args "$@"
  log INFO "Starting dotfiles setup from ${DOTFILES_DIR}"

  require_command git
  require_command curl

  load_env

  if [[ "$SKIP_OMZ" == false ]]; then
    install_oh_my_zsh
    install_zsh_plugins_and_themes
  fi

  if [[ "$SKIP_FONTS" == false ]]; then
    install_fonts
  fi

  link_dotfiles
  install_brew_packages
  setup_git_config

  log INFO "Setup completed"

  if [[ -t 1 ]]; then
    exec zsh -l
  fi
}

main "$@"
