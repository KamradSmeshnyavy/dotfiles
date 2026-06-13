# Укажи URL своего репозитория (или оставь, как есть, если папка уже склонирована)
$RepoUrl = "git@github.com:KamradSmeshnyavy/dotfiles.git"
$DotfilesDir = "$HOME\dotfiles"

Write-Host "=== Инициализация Dotfiles для Windows ===" -ForegroundColor Cyan

# 1. Проверка наличия Git
if (-Not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "Git не установлен. Пожалуйста, установите Git." -ForegroundColor Red
    exit 1
}

# 2. Клонирование или обновление репозитория
if (-Not (Test-Path $DotfilesDir)) {
    Write-Host "Клонирование репозитория в $DotfilesDir..." -ForegroundColor Yellow
    git clone $RepoUrl $DotfilesDir
} else {
    Write-Host "Директория $DotfilesDir уже существует. Выполняем git pull..." -ForegroundColor Yellow
    Set-Location $DotfilesDir
    git pull
    Set-Location $HOME
}

# 3. Карта путей под твое дерево: "Путь внутри репозитория" = "Целевой путь в Windows"
$Mappings = [ordered]@{
    # === Редакторы ===
    "tui\nvim"                     = "$env:LOCALAPPDATA\nvim"
    "tui\helix"                    = "$env:APPDATA\helix"
    
    # === VS Code ===
    "apps\vscode\settings.json"    = "$env:APPDATA\Code\User\settings.json"
    "apps\vscode\keybindings.json" = "$env:APPDATA\Code\User\keybindings.json"
    "apps\vscode\snippets"         = "$env:APPDATA\Code\User\snippets"

    # === Терминал и Оболочки ===
    "apps\wezterm"                 = "$HOME\.config\wezterm"
    "shells\nushell"               = "$env:APPDATA\nushell"
    "shells\starship.toml"         = "$HOME\.config\starship.toml"
    "shells\ohmyposh"              = "$HOME\.config\ohmyposh"

    # === TUI Утилиты ===
    "tui\yazi"                     = "$env:APPDATA\yazi\config"
    "tui\bat"                      = "$env:APPDATA\bat"
    "tui\btop4win"                 = "$HOME\.config\btop"
    "tui\fastfetch"                = "$HOME\.config\fastfetch"
    "tui\lazygit"                  = "$env:LOCALAPPDATA\lazygit"
    
    # === Git & SSH ===
    "tui\git\config"               = "$HOME\.gitconfig"
    "cli\ssh\ssh-config"           = "$HOME\.ssh\config"
}

Write-Host "`n=== Создание символических ссылок ===" -ForegroundColor Cyan

foreach ($Item in $Mappings.GetEnumerator()) {
    # Нормализация путей для Windows (заменяем слэши на бэкслэши, на всякий случай)
    $RelativeSource = $Item.Name.Replace("/", "\")
    $SourcePath = Join-Path $DotfilesDir $RelativeSource
    $TargetPath = $Item.Value

    if (Test-Path $SourcePath) {
        # Создаем родительскую папку назначения (например, AppData\Roaming\yazi), если ее нет
        $TargetParent = Split-Path $TargetPath -Parent
        if (-Not (Test-Path $TargetParent)) {
            New-Item -ItemType Directory -Path $TargetParent -Force | Out-Null
        }

        # Если по целевому пути уже что-то есть, и это не симлинк на наш же файл
        if (Test-Path $TargetPath) {
            # Проверяем, не является ли это уже правильным симлинком
            $CurrentTarget = (Get-Item $TargetPath).Target
            if ($CurrentTarget -eq $SourcePath) {
                Write-Host "[ПРОПУСК] Ссылка уже существует: $TargetPath" -ForegroundColor DarkGray
                continue
            }

            # Иначе делаем бэкап
            $BackupPath = "$TargetPath.backup"
            if (Test-Path $BackupPath) { Remove-Item -Path $BackupPath -Recurse -Force }
            Rename-Item -Path $TargetPath -NewName (Split-Path $BackupPath -Leaf) -Force
            Write-Host "[БЭКАП] Старый конфиг сохранен как .backup: $TargetPath" -ForegroundColor Magenta
        }

        # Создание симлинка
        try {
            New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath -Force | Out-Null
            Write-Host "[OK] $SourcePath -> $TargetPath" -ForegroundColor Green
        } catch {
            Write-Host "[ОШИБКА] Не удалось создать ссылку $TargetPath. Запустите PowerShell от имени Администратора или включите 'Режим разработчика'." -ForegroundColor Red
        }
    } else {
        Write-Host "[НЕ НАЙДЕНО] Исходный путь $SourcePath не существует." -ForegroundColor Yellow
    }
}

Write-Host "`n=== Настройка завершена! ===" -ForegroundColor Cyan
