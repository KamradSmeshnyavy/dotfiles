flake_dir := "~/dotfiles/macos/nix-darwin"
hostname  := "MacBook-Pro-Denis"

# Список рецептов для текущей ОС
default:
    @just --list

# ── macOS (nix-darwin) ─────────────────────────────────────────

# Применить изменения конфигурации (switch)
[macos]
switch:
    sudo darwin-rebuild switch --flake {{flake_dir}}#{{hostname}}

[macos]
switch-lix:
    sudo -H nix run nix-darwin -- switch --flake {{flake_dir}}#{{hostname}}

# Собрать и проверить конфигурацию без применения (check)
[macos]
build:
    sudo darwin-rebuild build --flake {{flake_dir}}#{{hostname}}

# Обновить flake.lock и применить изменения
[macos]
update:
    sudo nix flake update --flake {{flake_dir}}
    sudo darwin-rebuild switch --flake {{flake_dir}}#{{hostname}}

# Очистка старых поколений и мусора
[macos]
gc:
    sudo nix-collect-garbage -d
    sudo nix-store --optimise

# ── Linux (Omarchy) ────────────────────────────────────────────

# Разложить ссылки конфигов (install/install.conf.yaml) и поставить AI-скиллы
[linux]
link:
    python3 {{justfile_directory()}}/install/install.py
    git -C {{justfile_directory()}} config core.hooksPath .githooks
    @just install-skill

# Применить тему Omarchy (без имени — показать список)
[linux]
theme name="":
    @if [ -z "{{name}}" ]; then omarchy theme list; else omarchy theme set "{{name}}"; fi

# Перенаправить слоты тем приложений на текущую тему (без смены темы)
[linux]
app-themes:
    {{justfile_directory()}}/omarchy-themes/scripts/omarchy-app-themes

# Что поменялось в стоковом Bar.qml относительно клона kamradsmeshnyavy.bar (правки скинов помечены `// skin:`)
[linux]
bar-upstream-diff:
    diff -u "${OMARCHY_PATH:-$HOME/.local/share/omarchy}/shell/plugins/bar/Bar.qml" {{justfile_directory()}}/apps/omarchy-shell/plugins/kamradsmeshnyavy.bar/Bar.qml || true

# Пересобрать шейдер переходов обоев (kamradsmeshnyavy.background) после правки transition.frag
[linux]
shaders-wallpaper:
    /usr/lib/qt6/bin/qsb --glsl "100 es,120,150" --hlsl 50 --msl 12 -O \
      -o {{justfile_directory()}}/apps/omarchy-shell/plugins/kamradsmeshnyavy.background/shaders/transition.frag.qsb \
      {{justfile_directory()}}/apps/omarchy-shell/plugins/kamradsmeshnyavy.background/shaders/transition.frag

# Ссылки на dotfiles, которых нет в install/install.conf.yaml (сделаны вручную)
[linux]
check-links:
    {{justfile_directory()}}/scripts/check-links

# Плагины yazi из tui/yazi/package.toml
[linux]
yazi-plugins:
    ya pkg install

# ── Общее ──────────────────────────────────────────────────────

# AI-скиллы из skills/ (карта по ОС: skills/*_install_map.json); --copy — копировать, --dry-run — показать
install-skill *args:
    @nu {{justfile_directory()}}/scripts/install-skill.nu {{args}}
