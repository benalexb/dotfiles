export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"
export ZSH_HIGHLIGHT_HIGHLIGHTERS_DIR=/opt/homebrew/share/zsh-syntax-highlighting/highlighters

plugins=(gitfast git last-working-dir common-aliases sublime history-substring-search zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Store your own aliases in the ~/.aliases file and load it
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Set editors
export BUNDLER_EDITOR=code
export EDITOR="vim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# OSX Speficic Aliases
alias chromedev='/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --incognito > /dev/null 2>&1 &'

# NVM
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# Go
export GOROOT=/usr/local/go
export PATH=$PATH:$GOROOT/bin

# Conda
source ~/miniconda3/etc/profile.d/conda.sh

# Python Symlinks
export PATH="/opt/homebrew/opt/python@3.12/libexec/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/ben/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

export GPG_TTY=$(tty)

export GITHUB_TOKEN=***REMOVED***

# Created by `pipx` on 2024-09-25 19:56:29
export PATH="$PATH:/Users/ben/.local/bin"

