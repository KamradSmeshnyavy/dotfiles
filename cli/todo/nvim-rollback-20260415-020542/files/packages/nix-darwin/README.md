# Nix + Home Manager + Brew (для `dotfiles`)

Этот каталог переводит твои dotfiles на `nix-darwin` + `home-manager`, но сохраняет `homebrew` для пакетов/casks, когда это удобнее.

## Что уже сделано

- `nix-darwin/flake.nix` — точка входа во всю конфигурацию.
- `nix-darwin/hosts/darwin/default.nix` — системные настройки macOS + Homebrew + системные пакеты nixpkgs.
- `nix-darwin/home/default.nix` — пользовательские пакеты и переменные окружения.
- `nix-darwin/home/dotfiles-links.nix` — перенос текущих dotfiles в Home Manager через симлинки.

## Первый запуск

Из каталога `dotfiles/nix-darwin`:

1. `nix flake update`
2. `sudo nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis`

## Ежедневный workflow

После изменения `.nix` файлов:

- `sudo nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis`

## Где что настраивать

- Системные пакеты nixpkgs: `hosts/darwin/default.nix` → `environment.systemPackages`
- Пакеты Homebrew: `hosts/darwin/default.nix` → `homebrew.brews`, `homebrew.casks`
- Пакеты пользователя: `home/default.nix` → `home.packages`
- Симлинки dotfiles: `home/dotfiles-links.nix`
- Neovim (подробный гайд): `home/modules/neovim/README.md`

## Lix

Lix уже включён в:

- `hosts/darwin/default.nix` → `nix.package = pkgs.lixPackageSets.stable.lix;`

Если пакетный путь в текущем канале изменится, вернись временно на `nix.package = pkgs.nix;` и обнови `nixpkgs`.
