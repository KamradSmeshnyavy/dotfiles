flake_dir := "~/dotfiles/packages/nix-darwin"
hostname  := "MacBook-Pro-Denis"

# Применить изменения конфигурации (switch)
switch:
    sudo darwin-rebuild switch --flake {{flake_dir}}#{{hostname}}

switch-lix:
    sudo -H nix run nix-darwin -- switch --flake {{flake_dir}}#{{hostname}}

# Собрать и проверить конфигурацию без применения (check)
build:
    sudo darwin-rebuild build --flake {{flake_dir}}#{{hostname}}

# Обновить flake.lock и применить изменения
update:
    sudo nix flake update --flake {{flake_dir}}
    sudo darwin-rebuild switch --flake {{flake_dir}}#{{hostname}}

# Очистка старых поколений и мусора
gc:
    sudo nix-collect-garbage -d
    sudo nix-store --optimise

