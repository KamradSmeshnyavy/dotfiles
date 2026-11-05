<h1 align="center">
  🌌 Omarchy dotfiles — customization as plugins
  <br>
  <img src="https://img.shields.io/github/commit-activity/y/KamradSmeshnyavy/dotfiles?style=for-the-badge&labelColor=%23222436&color=%235771AA" alt="Commit Frequency">
</h1>

<p align="center">
  <i>Arch Linux + <a href="https://omarchy.org">Omarchy</a> (Hyprland), reworked into <b>15 installable Omarchy plugins</b>
  and a <b>Customizer</b> that changes the whole desktop with a click — no config editing.</i>
  <br>
  🇬🇧 English · <a href="README.ru.md">🇷🇺 Русский</a> · <a href="https://github.com/KamradSmeshnyavy/dotfiles/wiki">📖 Wiki</a>
</p>

<p align="center">
  <img src="assets/demo-preview.webp" alt="Demo: tiling, compact bar, music, browser, workspace switching, launcher skins, Customizer, wallpaper transition" width="100%">
  <br>
  <sub>🎬 Full video with sound (89 s, 🎵 Lane 8 — Little by Little): tiling, compact bar, workspaces, launcher skins, Customizer — <a href="assets/demo.mp4">assets/demo.mp4</a></sub>
</p>

<!-- The video plays inline only when the user-attachments link stands alone on its line, without <>.
     rumdl (MD034) would wrap it in <> — hence the comment below.
     After updating assets/demo.mp4, drag it into the README editor on GitHub and replace the link. -->
<!-- rumdl-disable-next-line MD034 -->
https://github.com/user-attachments/assets/b56f581c-844a-47e7-b27d-a467b0e2e1aa

---

## ✨ Why this repo is different

Most dotfiles are a pile of configs you copy and then edit by hand. Here the look of the desktop is built as
**separate Omarchy shell plugins**, each in its own repo, each installable with one command — with or without
the rest of these dotfiles:

- **One overlay for everything.** The [Customizer](https://github.com/KamradSmeshnyavy/omarchy-customizer)
  (`Super+Shift+T`) switches themes, wallpapers, bar skins, lock designs, launcher skins, animations, blur,
  transparency, screen shaders, fonts and whole *styles* — with a live preview, and every choice survives a reload.
- **Styles, not just colours.** A theme decides the palette; a **style** decides the shape: Flat, Glass, Fluent,
  Paper, Neon, Neumorph, Brutal, Retro and **DOT-MATRIX** (Nothing-OS-like dot type, LED meters, hardware cards).
  Any style on any theme.
- **Everything follows the theme.** Terminals, every TUI app, VS Code, GTK/Qt, Firefox and Helium (Dark Reader,
  Stylus, the Firefox UI), even the boot screen — one theme switch recolours all of it.
- **Font profiles.** One command (or one click in the Customizer) changes the type of the whole system: stock
  Maple Mono, Nothing-style Geist + dot titles, pixel terminals, handwritten Paper, dots everywhere…
- **Safe to try.** Every plugin replaces a stock one and goes back with `omarchy plugin enable omarchy.<name>`.

---

## 🧩 Omarchy plugins

Install any of them on a stock Omarchy 4 — no dotfiles needed. They are submitted to the official marketplace,
[plugins.omarchy.org](https://plugins.omarchy.org).

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-customizer --enable
```

| Plugin | What you get |
| :--- | :--- |
| [**Customizer**](https://github.com/KamradSmeshnyavy/omarchy-customizer) | the control centre: presets & styles, themes, wallpapers, recolor (lutgen), Dotify, 19 animation presets, transparency, blur, CRT/TFT shaders, sounds, Glyph lighting — and the settings of every plugin below |
| [Bar Skins](https://github.com/KamradSmeshnyavy/omarchy-bar-skins) | the top bar with 24 skins, 10 layouts, a compact mode that expands on hover, LED & glyph workspace styles |
| [Lock Designs](https://github.com/KamradSmeshnyavy/omarchy-lock-designs) | 23 lock screen designs plus style-matched ones, on top of the stock PAM flow |
| [Launcher Skins](https://github.com/KamradSmeshnyavy/omarchy-launcher-skins) | full-screen launcher skins: star map, CRT terminal, orrery, aquarium, tarot, metro… |
| [Wallpaper FX](https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx) | 24 wallpaper transitions on a single shader |
| [Image Picker Styles](https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles) | six styles for the theme / wallpaper picker |
| [Desktop Widgets](https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets) | clock, now playing, cava, system dials, todo, quotes, photo frame, a dashboard, power menu and workspace overview |
| [Edge OSD](https://github.com/KamradSmeshnyavy/omarchy-edge-osd) | volume / brightness sliding out of the screen edge (or a DOT-MATRIX LED meter) |
| [Drawer Notifications](https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications) | notifications as a drawer or DOT-MATRIX hardware toasts |
| DOT-MATRIX panels: [Tray](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-tray) · [Wi-Fi](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-network) · [Bluetooth](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-bluetooth) · [Sound](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-audio) · [Display](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-monitor) · [Agents](https://github.com/KamradSmeshnyavy/omarchy-dotmatrix-agents) | the stock bar panels redrawn in the DOT-MATRIX style |

The Customizer finds the other plugins on its own. Everything at once — its
[install.sh](https://github.com/KamradSmeshnyavy/omarchy-customizer#install) with `--all`.

---

## 📸 Gallery

| Desktop (Hyprland + custom bar) | Terminal (Kitty + Nushell + fastfetch) |
| :---: | :---: |
| ![Desktop](assets/desktop-hyprland.webp) | ![Terminal](assets/kitty-terminal.webp) |
| **Customizer** (Super+Shift+T) | **Launcher** (terminal skin, Super+Alt+Space) |
| ![Customizer](assets/customizer.webp) | ![Launcher](assets/launcher.webp) |
| **Neovim** | **Yazi** |
| ![Neovim](assets/neovim-editor.webp) | ![Yazi](assets/yazi-filemanager.webp) |
| **Music** (Spotifast + cava) | **Browser** (Firefox, themed via Dark Reader / Stylus) |
| ![Music](assets/music.webp) | ![Browser](assets/browser.webp) |

---

## 🚀 What's inside the dotfiles

| Category | What's used |
| :--- | :--- |
| 🪟 **WM** | **Hyprland** with a Lua config (`apps/hyprland/`), applied via `hyprctl eval`. macOS (secondary) — yabai / AeroSpace / skhd / SketchyBar. |
| 🎨 **Themes** | Hand-made Omarchy themes in `omarchy-themes/` (Nothing, DOT-MATRIX, Rose Pine Hacker, Pastel Hacker, Catppuccin Mocha, Nord, Black Arch, …) plus a theme from any wallpaper (matugen). TUI apps follow the theme through slots ([APP-THEMING](omarchy-themes/APP-THEMING.en.md)), browsers through Dark Reader, Stylus and Surfingkeys ([BROWSER-THEMING](omarchy-themes/BROWSER-THEMING.md)), Limine and Plymouth too. |
| 🔤 **Fonts** | `omarchy-font-profile` — 21 system-wide font profiles (terminals, GTK, VS Code, browsers, shell), own DotMatrix fonts built from OFL sources. |
| 🖥️ **Terminals** | **Kitty** (main), Ghostty (shaders and cursors are submodules). |
| 🐚 **Shells** | **Nushell** (main), Zsh, Fish; prompt — **Starship**. |
| 📝 **Editors** | **Neovim** (Lua), Helix, **VS Code** with custom CSS. |
| 🗃️ **Multiplexers** | **tmux**, Zellij. |
| 🛠️ **CLI / TUI** | yazi, lazygit / gitui / delta, bat, eza / lla, btop / procs, fzf / television, zoxide, atuin, glow, rmpc / cava, fastfetch. |
| 🌐 **Browsers** | Firefox and Helium: theme-synced extensions, generated `userChrome.css`, 3-way bookmark sync between them (`bookmarks-sync`). |
| ⌨️ **Input** | kanata, mouseless, wl-kbptr; on macOS — Karabiner and Hammerspoon. |

### 🧰 Tools

Every TUI tool picks up the colours of the current Omarchy theme (`just app-themes`).

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

## 🛠️ Install the whole setup

```sh
# 1. Clone with submodules
git clone --recursive https://github.com/KamradSmeshnyavy/dotfiles.git ~/dotfiles
cd ~/dotfiles

# 2. Packages + symlinks (interactive menu: packages only / dotfiles only / both)
./install/bootstrap.sh

# Symlinks only (Dotbot) + git hooks + git filters + AI skills, when the packages are already there
just link
just check-links      # manual symlinks that are missing from install/install.conf.yaml
just app-themes       # point app theme slots at the current theme
```

Dry run: `python3 install/install.py --dry-run`. Every command is listed by `just` with no arguments.
Step by step — [docs/INSTALL.md](docs/INSTALL.md) and the [wiki](https://github.com/KamradSmeshnyavy/dotfiles/wiki).

Requires `git`, `python3`, `just`, `base-devel` and a Nerd Font (**Maple Mono NF CN** by default).

---

## 📁 Layout

```text
dotfiles/
├── justfile           # every command (recipes split into Linux / macOS)
├── install/           # bootstrap.sh, install.py, install.conf.yaml (Dotbot), packages/
├── apps/              # GUI and desktop: hyprland, omarchy-shell (plugins = submodules), kitty, ghostty, vscode, …
├── tui/               # terminal tools: nvim, helix, git, lazygit, yazi, tmux, …
├── shells/            # nushell, zshrc, fish, starship.toml
├── cli/               # ssh, p10k, todo
├── omarchy-themes/    # Omarchy themes, hooks and theme sync scripts
├── scripts/           # bin/ → ~/.local/bin, git filters, check-links, install-skill.nu
├── skills/            # AI skills for coding agents
├── macos/             # nix-darwin flake
├── docs/              # one page per config: docs/{apps,tui,shells,cli}/<name>.md (English, + .ru.md)
└── assets/            # screenshots and the demo
```

📖 Guides — [wiki](https://github.com/KamradSmeshnyavy/dotfiles/wiki). Notes for AI agents (Claude Code, Codex, …) —
[AGENTS.md](AGENTS.md).

## License

MIT — see [LICENSE](LICENSE). Plugins carry their own licenses (MIT; the Customizer is GPL-3.0).
