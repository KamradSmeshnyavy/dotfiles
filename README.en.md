<h1 align="center">
  🌌 Omarchy Linux Dotfiles
  <br>
  <img src="https://img.shields.io/github/commit-activity/y/KamradSmeshnyavy/dotfiles?style=for-the-badge&labelColor=%23222436&color=%235771AA" alt="Commit Frequency">
</h1>

<p align="center">
  <i>Reproducible configs for Arch Linux + <a href="https://omarchy.org">Omarchy</a> (Hyprland) in my own <b>Rose Pine Hacker24</b> theme. macOS is a secondary platform.</i>
  <br>
  <a href="README.md">🇷🇺 Русский</a> · 🇬🇧 English
</p>

<p align="center">
  <img src="assets/demo-preview.webp" alt="Demo: tiling, compact bar, music, browser, workspace switching, launcher skins, Customizer, wallpaper transition" width="100%">
  <br>
  <sub>🎬 Full video with sound (89 s, 🎵 Lane 8 — Little by Little): tiling, compact bar, workspaces, launcher skins, Customizer — <a href="assets/demo.mp4">assets/demo.mp4</a></sub>
</p>

<!-- rumdl-disable-next-line MD034 -->
https://github.com/user-attachments/assets/b56f581c-844a-47e7-b27d-a467b0e2e1aa

---

## 📸 Gallery

| Desktop (Hyprland + custom bar) | Terminal (Kitty + Nushell + fastfetch) |
| :---: | :---: |
| ![Desktop](assets/desktop-hyprland.webp) | ![Terminal](assets/kitty-terminal.webp) |
| **Neovim** | **Yazi** |
| ![Neovim](assets/neovim-editor.webp) | ![Yazi](assets/yazi-filemanager.webp) |
| **Customizer** (Super+Shift+T) | **Launcher** (terminal skin, Super+Alt+Space) |
| ![Customizer](assets/customizer.webp) | ![Launcher](assets/launcher.webp) |
| **Music** (Spotifast + cava) | **Browser** (Firefox, themed via Dark Reader / Stylus) |
| ![Music](assets/music.webp) | ![Browser](assets/browser.webp) |

---

## 🧩 Omarchy shell plugins

The Omarchy shell itself is reworked with Quickshell plugins. Each one is a standalone repo you can install
with `omarchy plugin add <url> --enable`, without the rest of these dotfiles:

| Plugin | |
| :--- | :--- |
| [omarchy-bar-skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins) | top bar with 18 skins, 9 layouts, a compact mode that expands on hover, workspaces with 20+ label styles |
| [omarchy-launcher-skins](https://github.com/KamradSmeshnyavy/omarchy-launcher-skins) | full-screen launcher skins: star map, CRT terminal, orrery, aquarium, tarot, metro… |
| [omarchy-lock-designs](https://github.com/KamradSmeshnyavy/omarchy-lock-designs) | 21 lock screen designs on top of the stock PAM flow, with a safe fallback |
| [omarchy-wallpaper-fx](https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx) | 24 wallpaper transitions on a single custom shader |
| [omarchy-image-picker-styles](https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles) | six styles for the theme / wallpaper picker |
| [omarchy-customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer) | the **Customizer** overlay (`Super+Shift+T`): themes, wallpapers, recolor, Hyprland animations, transparency, blur, screen shaders — and all of the above when installed |

Everything at once: `curl -fsSL https://raw.githubusercontent.com/KamradSmeshnyavy/omarchy-customizer/main/install.sh | bash -s -- --all`.

---

## 🚀 Main components

| Category | What's used |
| :--- | :--- |
| 🪟 **WM** | **Hyprland** with a Lua config (`apps/hyprland/`), applied via `hyprctl eval`. On macOS — yabai / AeroSpace / skhd / SketchyBar. |
| 🎨 **Themes** | My own Omarchy themes in `omarchy-themes/` (Rose Pine Hacker24, Pastel Hacker, Catppuccin Mocha, Nord, …). TUI apps follow the theme through slots ([APP-THEMING](omarchy-themes/APP-THEMING.en.md)), browsers via Dark Reader and Stylus ([BROWSER-THEMING](omarchy-themes/BROWSER-THEMING.md)). |
| 🖥️ **Terminals** | **Kitty** (main), Ghostty (shaders and cursors are submodules), WezTerm. |
| 🐚 **Shells** | **Nushell** (main), Zsh, Fish; prompt — **Starship**. |
| 📝 **Editors** | **Neovim** (Lua), Helix, **VS Code** with custom CSS. |
| 🗃️ **Multiplexers** | **tmux**, Zellij. |
| 🛠️ **CLI / TUI** | yazi, lazygit / gitui / delta, bat, eza / lla, btop / procs, fzf / television, zoxide, atuin, glow, rmpc / cava, fastfetch. |
| ⌨️ **Input** | kanata, mouseless, wl-kbptr; on macOS — Karabiner and Hammerspoon. |

---

## 🧰 Tools

Every TUI tool picks up the colours of the current Omarchy theme through slots (`just app-themes`).

| Delta | LazyGit |
| :---: | :---: |
| [![delta](assets/delta.webp)](assets/delta.webp) | [![lazygit](assets/lazygit.webp)](assets/lazygit.webp) |
| **eza & lla** | **bat** |
| [![eza_lla](assets/eza_lla.webp)](assets/eza_lla.webp) | [![bat](assets/bat.webp)](assets/bat.webp) |
| **tmux** | **fzf** |
| [![tmux](assets/tmux.webp)](assets/tmux.webp) | [![fzf](assets/fzf.webp)](assets/fzf.webp) |
| **btop** | **procs** |
| [![btop](assets/btop.webp)](assets/btop.webp) | [![procs](assets/procs.webp)](assets/procs.webp) |
| **Television** | **Scooter** |
| [![television](assets/television.webp)](assets/television.webp) | [![scooter](assets/scooter.webp)](assets/scooter.webp) |

---

## 🛠️ Install

```sh
# 1. Clone with submodules
git clone --recursive https://github.com/KamradSmeshnyavy/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Packages + symlinks (interactive menu: packages only / dotfiles only / both)
./install/bootstrap.sh

# Symlinks only (Dotbot) + git hooks + AI skills, when the packages are already there
just link
just check-links      # manual symlinks that are missing from install/install.conf.yaml
just app-themes       # point app theme slots at the current theme
```

Dry run: `python3 install/install.py --dry-run`. Every command is listed by `just` with no arguments.
More in [docs/INSTALL.md](docs/INSTALL.md).

Requires `git`, `python3`, `just`, `base-devel` and a Nerd Font (**Maple Mono NF CN** is used everywhere).

---

## 📁 Layout

```text
dotfiles/
├── justfile           # every command (recipes split into Linux / macOS)
├── install/           # bootstrap.sh, install.py, install.conf.yaml (Dotbot), packages/
├── apps/              # GUI and desktop: hyprland, omarchy-shell, kitty, ghostty, vscode, …
├── tui/               # terminal tools: nvim, helix, git, lazygit, yazi, tmux, …
├── shells/            # nushell, zshrc, fish, starship.toml
├── cli/               # ssh, p10k, todo
├── omarchy-themes/    # Omarchy themes, hooks and theme sync scripts
├── scripts/           # bin/ → ~/.local/bin, check-links, install-skill.nu
├── skills/            # AI skills for coding agents
├── macos/             # nix-darwin flake
├── docs/              # one page per config: docs/{apps,tui,shells,cli}/<name>.md (Russian)
└── assets/            # screenshots and the demo
```

Notes for AI agents (Claude Code, Codex, …) — [AGENTS.md](AGENTS.md).

## License

MIT — see [LICENSE](LICENSE).
