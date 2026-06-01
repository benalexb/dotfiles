# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ -f "$HOME/.env" ]] && set -a && source "$HOME/.env" && set +a

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(gitfast git last-working-dir common-aliases sublime history-substring-search zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

export EDITOR="vim"

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"

if command -v brew &>/dev/null; then
  go_prefix="$(brew --prefix go 2>/dev/null)"
  [[ -n "$go_prefix" && -d "$go_prefix/bin" ]] && export PATH="$go_prefix/bin:$PATH"
fi

export PNPM_HOME="$HOME/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

[ -s "$HOME/.bun/_bun" ] && source "$HOME/.bun/_bun"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

autoload -Uz add-zsh-hook
gpg_tty() {
  local tty_path
  tty_path=$(tty 2>/dev/null) || return
  [[ "$tty_path" == not\ a\ tty ]] && return
  export GPG_TTY="$tty_path"
}
add-zsh-hook precmd gpg_tty
gpg_tty
