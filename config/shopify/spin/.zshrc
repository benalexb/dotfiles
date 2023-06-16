export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="powerlevel10k/powerlevel10k"

plugins=(gitfast git last-working-dir common-aliases sublime history-substring-search zsh-autosuggestions zsh-syntax-highlighting)
source $ZSH/oh-my-zsh.sh

# Store your own aliases in the ~/.aliases file and load it
[[ -f "$HOME/.aliases" ]] && source "$HOME/.aliases"

# Set editors
export BUNDLER_EDITOR=code
export EDITOR="vim"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# On spin, nix-env is not in scope when dotfiles service kicks in... :/
# So we check for spin and install delta here.
# nix-env -iA nixpkgs.delta
if [ "$SPIN" ] && ( ! command -v -- "delta" > /dev/null; ) && ( command -v -- "nix-env" > /dev/null; ); then
  nix-env -iA nixpkgs.delta
fi
