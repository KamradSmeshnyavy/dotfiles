**English** · [Русский](FAQ-ru)

# FAQ and troubleshooting

**I edited a plugin's QML and nothing changed.** Cloned / third-party plugins don't hot-reload: `omarchy restart shell`.

**A plugin doesn't show up after `git clone` into `~/.config/omarchy/plugins`.** Run `omarchy-shell shell rescanPlugins`,
then `omarchy plugin enable <id>`. `omarchy plugin add <url>` does all of it.

**How do I go back to stock?** `omarchy plugin enable omarchy.<bar|lock|menu|osd|notifications|background|image-picker>`;
`omarchy plugin remove kamradsmeshnyavy.<name>` removes mine. Presets → "Restore the previous setup" undoes a style or
preset.

**`hyprctl keyword …` / `hyprctl dispatch …` does nothing.** The Hyprland config is Lua: use `hyprctl eval 'hl.…'`.

**A key does two things after an Omarchy update.** Omarchy 4.5 took some keys (Super+Shift+T, Super+M, `` Super+` ``…).
Bind with `o.rebind` instead of `o.bind`.

**The theme / wallpaper picker is slow.** Customizer → Pickers → cache thumbnails and clean up unused ones
([Wallpapers and pickers](Wallpapers-and-Pickers)).

**Locked out after a lock-design experiment.** Ctrl+Alt+F3 → log in → `omarchy plugin enable omarchy.lock` or
`loginctl unlock-session`. A design without a password field never replaces the stock screen anyway.

**DOT-MATRIX looks like plain text.** Install the fonts: the Customizer's `install.sh` links them, or
`omarchy-font-profile` builds the DotMatrix ones; check with `fc-list | grep -i dot`.

**Switching fonts leaves git changes in my dotfiles.** Not any more: terminal fonts live in gitignored `fonts.conf`,
VS Code keys go through a clean filter (`just link` sets it up).

**Where do settings live?** Mostly `~/.config/omarchy/*.json` (`bar-skin.json`, `lock-design.json`, `widgets.json`,
`osd.json`, `notify-style.json`, `customizer.json`, `style.json`, `fonts.json`) and `~/.config/omarchy/customizer/`.

Something else? [Open an issue](https://github.com/KamradSmeshnyavy/dotfiles/issues) on the dotfiles or the plugin repo.
