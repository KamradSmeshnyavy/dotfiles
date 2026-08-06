# Installation Guide

## Clone the repository

Run the following command to clone the repository and enter the directory:

```bash
git clone git@github.com:KamradSmeshnyavy/dotfiles.git
cd dotfiles
```

## Setup Options

The repository includes an interactive installation script that can handle package installation and dotfile linking. 

Run the bootstrap script:

```bash
./install/bootstrap.sh
```

You will be prompted with three options:

1. **Install packages**: Installs required packages based on your OS.
   - On **macOS**, it installs packages via Homebrew (from `install/packages/brew.txt` and `brew-cask.txt`).
   - On **Arch-based Linux (Omarchy)**, it uses `pacman` and `yay` (from `install/packages/pacman.txt` and `yay.txt`).
2. **Apply dotfiles**: Uses Dotbot (`install.py` / `install.conf.yaml`) to symlink configuration files into your system (usually `~/.config/`).
3. **Install packages then apply dotfiles**: Performs both steps sequentially.

> [!WARNING]
> Before applying dotfiles, ensure you don't have conflicting configurations, or let Dotbot overwrite them if you are sure. 

## Alternative Installation Methods

### macOS (Nix-Darwin)
For macOS users who prefer Nix, the repository includes a `justfile` and a Nix-Darwin configuration:

```bash
just switch   # Switch to the new configuration
just build    # Build configuration without applying
just update   # Update flake.lock and apply
```

### GNU Stow
If you prefer managing symlinks with `stow` instead of Dotbot, you can use the provided setup script:

```bash
./install/setup.sh
```
This relies on `.stowrc` to link the base directories appropriately.

## Configurations Overview

Detailed documentation on each tool's configuration, including custom features and paths, can be found in the following directories:

- [Apps](./apps/)
- [CLI Tools](./cli/)
- [Shells](./shells/)
- [TUI Tools](./tui/)
