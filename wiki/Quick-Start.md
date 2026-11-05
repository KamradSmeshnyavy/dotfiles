**English** · [Русский](Quick-Start-ru)

# Quick start

## Path A — only the plugins (recommended to try)

On a stock Omarchy 4 (Quattro):

```sh
# the control centre
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-customizer --enable
omarchy restart shell
```

Bind it in `~/.config/hypr/bindings.lua` and reload Hyprland:

```lua
o.bind("SUPER + SHIFT + T", "Omarchy Customizer", "omarchy-shell shell toggle kamradsmeshnyavy.customizer")
```

Add whatever else you like — the Customizer picks each one up and grows a new group for it:

```sh
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-bar-skins --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-lock-designs --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-launcher-skins --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-wallpaper-fx --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-image-picker-styles --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-desktop-widgets --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-edge-osd --enable
omarchy plugin add https://github.com/KamradSmeshnyavy/omarchy-drawer-notifications --enable
omarchy restart shell
```

Or everything at once: the Customizer ships an installer — after adding the Customizer, read it and run it:

```sh
less ~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/install.sh
bash ~/.config/omarchy/plugins/kamradsmeshnyavy.customizer/install.sh --all
```

**Try the DOT-MATRIX look:** Super+Shift+T → Presets → DOT-MATRIX → ⏎. Changed your mind? Presets → "Restore the
previous setup".

**Going back:** every plugin replaces a stock one — `omarchy plugin enable omarchy.bar` (lock, menu, osd, …) brings the
stock one back; `omarchy plugin remove <id>` removes mine.

Updates: `omarchy plugin update` (fast-forward pull, shows the diff).

## Path B — the whole setup

```sh
git clone --recursive https://github.com/KamradSmeshnyavy/dotfiles.git ~/dotfiles
cd ~/dotfiles
./install/bootstrap.sh      # packages, symlinks or both
```

Already have the packages? `just link` (Dotbot symlinks, git hooks, git filters, AI skills, terminal fonts). Then
`just app-themes` and pick a theme: `just theme` lists them.

> [!WARNING]
> Path B links my configs over yours (Hyprland, terminals, shells, editors). Try `python3 install/install.py --dry-run`
> first.

Next: [Customizer](Customizer).
