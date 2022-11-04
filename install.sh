# Check if NodeJS is installed
if ( command -v -- "node" > /dev/null; ) then
  echo "-----> NodeJS is already installed, awesome!"
else
  echo "-----> Missing NodeJS ☹️"
  exit 127 # command not found
fi

# Make sure we have ZX
if ( ! command -v -- "zx" > /dev/null; ) then
  echo "-----> Installing ZX"
  npm install -g --silent zx
fi

echo "-----> Executing setup.mjs"
zx ./setup.mjs

# symlink() {
#   file=$1
#   link=$2
#   if [ ! -e "$link" ]; then # link doesn't exist
#     echo "-----> Symlinking your new $link"
#     ln -fs $file $link
#   fi
# }

# backup() {
#   target=$1
#   if [ -e "$target" ]; then # file exists
#     if [ ! -L "$target" ]; then # file is not a symbolic link
#       mv "$target" "$target.backup"
#       echo "-----> Moved your old $target config file to $target.backup"
#     fi
#   fi
# }

# # Install Oh My Zsh
# if [ ! -d "$HOME/.oh-my-zsh" ]; then
#   echo "-----> Installing Oh My Zsh"
#   # TODO: can this be done via package manager?
#   sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
# fi

# # Install powerlevel10k theme
# if [ ! -d ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k ]; then
#   echo '-----> Installing powerlevel10k theme'
#   git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
# fi

# # Install oh-my-zsh plugins

# CURRENT_DIR=`pwd`
# ZSH_PLUGINS_DIR="$HOME/.oh-my-zsh/custom/plugins"

# mkdir -p "$ZSH_PLUGINS_DIR" && cd "$ZSH_PLUGINS_DIR"

# if [ ! -d "$ZSH_PLUGINS_DIR/zsh-syntax-highlighting" ]; then
#   echo "-----> Installing zsh-syntax-highlighting"
#   git clone https://github.com/zsh-users/zsh-syntax-highlighting
# fi

# if [ ! -d "$ZSH_PLUGINS_DIR/zsh-autosuggestions" ]; then
#   echo "-----> Installing zsh-autosuggestions"
#   git clone https://github.com/zsh-users/zsh-autosuggestions
# fi

# cd "$CURRENT_DIR"

# # Create symlinks for config files
# for name in zshrc aliases p10k.zsh; do
#   echo "-----> Symlinking $name"
#   if [ ! -d "$name" ]; then
#     target="$HOME/.$name"
#     backup $target
#     if [ "$SPIN" ]; then
#       symlink $HOME/dotfiles/$name $target
#     else
#       symlink $PWD/$name $target
#     fi
#   fi
# done

# # Install Rust and Cargo
# if ( ! command -v -- "cargo" > /dev/null; ); then
#   echo "-----> Installing Rust and Cargo"
#   # TODO: can this be done via package manager?
#   curl https://sh.rustup.rs -sSf | sh -s -- -y
# else
#   echo "-----> Skip install -> rust and cardo already installed"
# fi

# # Install git-delta
# if ( ! command -v -- "delta" > /dev/null; ); then
#   echo "-----> Installing git-delta"
#   cargo install git-delta
# else
#   echo "-----> Skip install -> git-delta already installed"
# fi

# # Git config
# echo "-----> Setting git config"
# git config --global user.name "Benjamin Barreto"
# git config --global user.email "benjamin.barreto@shopify.com"
# git config --global core.editor "code -w"
# git config --global core.pager "delta"
# git config --global init.defaultbranch "master"
# git config --global interactive.difffilter "delta --color-only --features=interactive"
# git config --global --add include.path "~/dotfiles/delta.gitconfig"
# git config --global --add include.path "~/dotfiles/delta-themes.gitconfig"
# git config --global --list

# exec zsh
