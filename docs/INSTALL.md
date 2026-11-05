# Installation guide

[🇷🇺 Русский](INSTALL.ru.md)

There are two ways in: take only the **Omarchy plugins** (no dotfiles), or install the **whole setup**.

## Only the plugins

Every plugin is a separate repo that installs on a stock Omarchy 4:

```bash
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-customizer --enable
omarchy restart shell
```

The list is in the [README](../README.md#-omarchy-plugins); each plugin's README has its settings and how to uninstall
it. Everything at once — the Customizer's `install.sh --all`.

## The whole setup

### Clone the repository

```bash
git clone --recursive git@github.com:KamradSmeshnyavy/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

Forgot `--recursive`? Run `git submodule update --init --recursive` (Dotbot, the Ghostty shaders and cursors and the
plugins are submodules).

### Bootstrap

```bash
./install/bootstrap.sh
```

It offers three options:

1. **Install packages** for your OS:
   - **macOS** — Homebrew (`install/packages/brew.txt`, `brew-cask.txt`);
   - **Arch / Omarchy** — `pacman` and `yay` (`install/packages/pacman.txt`, `yay.txt`).
2. **Apply dotfiles** — Dotbot (`install/install.py` / `install.conf.yaml`) symlinks the configs into your system
   (mostly `~/.config/`).
3. **Both**, one after another.

> [!WARNING]
> Before applying the dotfiles, make sure you have no conflicting configs, or let Dotbot overwrite them if you are sure.

### Links, hooks and filters only

When the packages are already there:

```bash
just link            # Dotbot + git hooks (gitleaks) + git filters + AI skills + terminal fonts by profile
just check-links     # manual symlinks that are missing from install/install.conf.yaml
just app-themes      # point the app theme slots at the current theme
```

Dry run: `python3 install/install.py --dry-run`; flags go to Dotbot as is (`--only link`, …). `just` without
arguments lists every recipe.

### After installing

- `bat cache --build` runs automatically.
- Fonts: `omarchy-font-profile list` / `omarchy-font-profile <profile>`; DotMatrix fonts — `just dotmatrix-fonts`.
- Theme: `just theme <name>` (no name — the list).

## Alternative methods

### macOS (nix-darwin)

```bash
just switch   # switch to the new configuration
just build    # build without applying
just update   # update flake.lock and apply
```

### GNU Stow

```bash
./install/setup.sh
```

It relies on `.stowrc` to link the base directories.

## Configs

Every config has a page: [apps](./apps/), [cli](./cli/), [shells](./shells/), [tui](./tui/) — the index is
[docs/README.md](README.md). Guides are in the [wiki](https://github.com/KamradSmeshnyavy/dotfiles/wiki).
