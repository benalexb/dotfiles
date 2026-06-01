# dotfiles

Personal macOS dotfiles for shell, git, fonts, and iTerm2. (maybe also linux in the future)

## Prerequisites

- macOS with Xcode Command Line Tools
- [Homebrew](https://brew.sh/)
- Clone this repo to `~/dotfiles`

```bash
git clone <repo-url> ~/dotfiles
```

## Setup

1. Create your local environment file:

```bash
cp ~/dotfiles/.env.example ~/.env
```

Edit `~/.env` with your name, email, and any secrets (e.g. `GITHUB_TOKEN`).

2. Run the install script:

```bash
~/dotfiles/install-osx.sh
```

Install options:

- `--skip-fonts` — skip font installation
- `--skip-omz` — skip oh-my-zsh and plugin setup

## What gets installed

1. [oh-my-zsh](https://ohmyz.sh/)
2. [powerlevel10k](https://github.com/romkatv/powerlevel10k)
3. [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
4. [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
5. [git-delta](https://dandavison.github.io/delta/introduction.html) (via Homebrew)
6. JetBrains Mono Nerd Font Mono variants
7. Personal aliases, vim config, and git delta config
8. Symlinks for `.zshrc`, `.zprofile`, `.aliases`, `.p10k.zsh`, and `.vimrc`

## iTerm2

Import the profile and color schemes from:

- `config/common/iTerm2/Ben.json`
- `config/common/iTerm2/apple-dark.itermcolors`
- `config/common/iTerm2/apple-light.itermcolors`

In iTerm2: **Settings → Profiles → Other Actions → Import JSON Profiles**

## Cursor

Editor settings are managed with Cursor's built-in Settings Sync, not this repo.

## Secrets

- Tracked template: `.env.example`
- Local secrets: `~/.env` (gitignored, loaded by `.zshrc` and `install-osx.sh`)
- Never commit real tokens or credentials

If tokens were ever committed, revoke them on GitHub and scrub git history before pushing.

## Directory layout

```
dotfiles/
├── .env.example
├── Brewfile
├── install-osx.sh
├── config/
│   ├── common/          # shared config (aliases, p10k, vim, git delta, iTerm2)
│   └── osx/             # macOS shell config (.zshrc, .zprofile)
└── fonts/
    └── JetBrainsMono/   # JetBrainsMonoNerdFontMono variants only
```
