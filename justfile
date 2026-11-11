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
    # settings.json VS Code: шрифт/тема с этой машины не попадают в git (см. .gitattributes)
    git -C {{justfile_directory()}} config filter.vscode-local.clean scripts/git-filters/vscode-local
    git -C {{justfile_directory()}} config filter.vscode-local.smudge cat
    git -C {{justfile_directory()}} config filter.vscode-local.required false
    # шрифты терминалов по сохранённому профилю — генерирует неотслеживаемые kitty/ghostty fonts.conf
    -{{justfile_directory()}}/scripts/bin/omarchy-font-profile apply
    @just install-skill

# Применить тему Omarchy (без имени — показать список)
[linux]
theme name="":
    @if [ -z "{{name}}" ]; then omarchy theme list; else omarchy theme set "{{name}}"; fi

# Перенаправить слоты тем приложений на текущую тему (без смены темы);
# `just app-themes telegram` / `telegram-android` — переслать тему Telegram (desktop / телефон)
[linux]
app-themes *args:
    {{justfile_directory()}}/omarchy-themes/scripts/omarchy-app-themes {{args}}

# Тема «dynamic» из обоев через matugen (без пути — текущие; --scheme vibrant, --mode light, --no-apply)
[linux]
theme-from-wallpaper *args:
    {{justfile_directory()}}/omarchy-themes/scripts/omarchy-wallpaper-theme {{args}}

# Limine и Plymouth в цветах текущей темы (нужен sudo; --dry-run — только показать изменения)
[linux]
boot-theme *args:
    {{justfile_directory()}}/omarchy-themes/scripts/omarchy-boot-theme {{args}}

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

# Переход outline: venv с BiRefNet для вырезки персонажей (NPU/GPU Intel — intel-npu-driver, intel-compute-runtime)
[linux]
wallpaper-fx-outline-install:
    {{justfile_directory()}}/apps/omarchy-shell/plugins/kamradsmeshnyavy.background/scripts/wallpaper-fx-outline install

# Переход outline: поставить обои в очередь на вырезку — один фоновый воркер (без аргументов — текущей темы)
[linux]
wallpaper-fx-outline-warm *dirs:
    {{justfile_directory()}}/apps/omarchy-shell/plugins/kamradsmeshnyavy.background/scripts/wallpaper-fx-outline warm {{dirs}}

# Собрать DotMatrix Mono (Geist Mono + лигатуры) и DotMatrix Pixel (Terminus: русские «в д и й», курсив, лигатуры)
[linux]
dotmatrix-fonts:
    {{justfile_directory()}}/scripts/bin/omarchy-font-profile build-fonts

# Ссылки на dotfiles, которых нет в install/install.conf.yaml (сделаны вручную)
[linux]
check-links:
    {{justfile_directory()}}/scripts/check-links

# Статус заявок плагинов в plugins.omarchy.org (проверка, одобрение, публикация)
[linux]
marketplace:
    {{justfile_directory()}}/scripts/marketplace-status

# Опубликовать wiki/ в GitHub Wiki (-n — только показать изменения)
[linux]
wiki-sync *args:
    {{justfile_directory()}}/scripts/wiki-sync {{args}}

# Обновить публичный omarchy-launcher-skins из лаунчера в dotfiles (без портированных скинов)
[linux]
publish-launcher path="~/src/omarchy-launcher-skins":
    {{justfile_directory()}}/scripts/publish-launcher {{path}}

# Синхронизировать закладки Firefox / Helium / Chromium (-n — только показать, -y — закрыть браузеры без вопроса)
[linux]
bookmarks-sync *args:
    {{justfile_directory()}}/scripts/bin/bookmarks-sync {{args}}

# Плагины yazi из tui/yazi/package.toml
[linux]
yazi-plugins:
    ya pkg install

# ── Общее ──────────────────────────────────────────────────────

# AI-скиллы из skills/ (карта по ОС: skills/*_install_map.json); --copy — копировать, --dry-run — показать
install-skill *args:
    @nu {{justfile_directory()}}/scripts/install-skill.nu {{args}}
