# Nix: 10 команд на каждый день

Мини-шпаргалка без лишнего.

1. Перейти в конфиг:
   - `cd ~/dotfiles/nix-darwin`

2. Проверить конфиг:
   - `nix flake check`

3. Обновить входы (`flake.lock`):
   - `nix flake update`

1. Применить изменения:
   - `sudo -H /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis`
   - sudo -H nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis

5. Применить без шумных warning:
   - `./switch-no-warnings.sh`

6. Посмотреть поколения:
   - `darwin-rebuild --list-generations`

7. Откатиться назад:
   - `darwin-rebuild switch --rollback`

8. Найти пакет в nixpkgs:
   - `nix search nixpkgs <name>`

9. Обновить и сразу применить:
   - `nix flake update && sudo -H /nix/var/nix/profiles/default/bin/nix run nix-darwin -- switch --flake .#MacBook-Pro-Denis`

10. Проверить, что пакет доступен: `command -v <tool>`

---

## Куда добавлять пакеты

- Nix системно: `hosts/darwin/default.nix` → `environment.systemPackages`
- Nix для пользователя: `home/default.nix` → `home.packages`
- Brew CLI: `hosts/darwin/default.nix` → `homebrew.brews`
- Brew GUI: `hosts/darwin/default.nix` → `homebrew.casks`
