# dotfiles

Personal dotfiles for macOS and Fedora Linux: shell, git, fonts, and iTerm2, etc.

## Prerequisites

- macOS with Xcode Command Line Tools and [Homebrew](https://brew.sh/), **or**
- Fedora Linux (uses `dnf`)
- Clone this repo to `~/dotfiles`

```bash
git clone <repo-url> ~/dotfiles
```

## Setup

1. Create your local environment file:

```bash
cp ~/dotfiles/.env.example ~/dotfiles/.env
```

Edit `~/dotfiles/.env` with your name, email, and any secrets (e.g. `GITHUB_TOKEN`).

The install script symlinks `~/.env` to `~/dotfiles/.env`. To create the symlink manually:

```bash
ln -sf ~/dotfiles/.env ~/.env
```

2. Run the install script for your platform:

```bash
# macOS
~/dotfiles/install-osx.sh

# Fedora
~/dotfiles/install-fedora.sh
```

Install options:

- `--skip-fonts` — skip font installation
- `--skip-omz` — skip oh-my-zsh and plugin setup

## What gets installed

1. [oh-my-zsh](https://ohmyz.sh/)
2. [powerlevel10k](https://github.com/romkatv/powerlevel10k)
3. [zsh-syntax-highlighting](https://github.com/zsh-users/zsh-syntax-highlighting)
4. [zsh-autosuggestions](https://github.com/zsh-users/zsh-autosuggestions)
5. [git-delta](https://dandavison.github.io/delta/introduction.html) (via Homebrew on macOS, `dnf` on Fedora)
6. JetBrains Mono Nerd Font Mono variants
7. Personal aliases (common + platform-specific), vim config, and git delta config
8. Symlinks for `.env`, `.zshrc`, `.zprofile`, `.aliases`, `.aliases.platform`, `.p10k.zsh`, and `.vimrc`

On Fedora, the script also installs packages via `dnf` (zsh, git-delta, vim, curl, git) and sets zsh as the default shell via `chsh`. Fonts are installed to `~/.local/share/fonts` and indexed with `fc-cache`.

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
- Local secrets: `~/dotfiles/.env` (gitignored), symlinked to `~/.env` for shell loading
- Loaded by `.zshrc` and the install scripts via `~/.env`
- Never commit real tokens or credentials

If tokens were ever committed, revoke them on GitHub and scrub git history before pushing.

## Directory layout

```
dotfiles/
├── .env.example
├── Brewfile
├── install-osx.sh
├── install-fedora.sh
├── config/
│   ├── common/          # shared config (aliases, p10k, vim, git delta, iTerm2)
│   ├── osx/             # macOS shell config (.zshrc, .zprofile, .aliases)
│   └── fedora/          # Fedora shell config (.zshrc, .zprofile, .aliases)
└── fonts/
    └── JetBrainsMono/   # JetBrainsMonoNerdFontMono variants only
```
