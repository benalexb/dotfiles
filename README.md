# dotfiles

## Usage
Checkout this repo to your (OSX or Linux) home directory. **IMPORTANT** The script assumes this repository has been checked out to `~/dotfiles`.
```
sh ./install.sh
```

The following will be installed and set up

1. [oh-my-zsh](https://ohmyz.sh/)
2. [powerlevel10k](https://github.com/romkatv/powerlevel10k)
3. [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
4. [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
5. [git-delta](https://dandavison.github.io/delta/introduction.html)
6. Personal aliases
7. Git configs

### Pre-reqs
* nodejs >= v16

## Development
It is not necessary to install any dependencies for development, but if you would like a linter and some dev ergonomics while working on this repository, run
```
npm install
```
