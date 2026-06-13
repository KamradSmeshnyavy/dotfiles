$RepoUrl = "git@github.com:KamradSmeshnyavy/dotfiles.git"
$DotfilesDir = "$HOME\dotfiles"

Write-Host "=== Initializing Dotfiles for Windows ===" -ForegroundColor Cyan

# 1. Check for Git
if (-Not (Get-Command "git" -ErrorAction SilentlyContinue)) {
    Write-Host "Git is not installed. Please install Git for Windows." -ForegroundColor Red
    exit 1
}

# 2. Clone or update repository
if (-Not (Test-Path $DotfilesDir)) {
    Write-Host "Cloning repository to $DotfilesDir..." -ForegroundColor Yellow
    git clone $RepoUrl $DotfilesDir
} else {
    Write-Host "Directory $DotfilesDir already exists. Running git pull..." -ForegroundColor Yellow
    Set-Location $DotfilesDir
    git pull
    Set-Location $HOME
}

# 3. Path Mappings
$Mappings = [ordered]@{
    "tui\nvim"                     = "$env:LOCALAPPDATA\nvim"
    "tui\helix"                    = "$env:APPDATA\helix"
    "apps\vscode\settings.json"    = "$env:APPDATA\Code\User\settings.json"
    "apps\vscode\keybindings.json" = "$env:APPDATA\Code\User\keybindings.json"
    "apps\vscode\snippets"         = "$env:APPDATA\Code\User\snippets"
    "apps\wezterm"                 = "$HOME\.config\wezterm"
    "shells\nushell"               = "$env:APPDATA\nushell"
    "shells\starship.toml"         = "$HOME\.config\starship.toml"
    "shells\ohmyposh"              = "$HOME\.config\ohmyposh"
    "tui\yazi"                     = "$env:APPDATA\yazi\config"
    "tui\bat"                      = "$env:APPDATA\bat"
    "tui\btop4win"                 = "$HOME\.config\btop"
    "tui\fastfetch"                = "$HOME\.config\fastfetch"
    "tui\lazygit"                  = "$env:LOCALAPPDATA\lazygit"
    "tui\git\config"               = "$HOME\.gitconfig"
    "cli\ssh\ssh-config"           = "$HOME\.ssh\config"
}

Write-Host "`n=== Creating Symlinks ===" -ForegroundColor Cyan

foreach ($Item in $Mappings.GetEnumerator()) {
    $RelativeSource = $Item.Name.Replace("/", "\")
    $SourcePath = Join-Path $DotfilesDir $RelativeSource
    $TargetPath = $Item.Value

    if (Test-Path $SourcePath) {
        $TargetParent = Split-Path $TargetPath -Parent
        if (-Not (Test-Path $TargetParent)) {
            New-Item -ItemType Directory -Path $TargetParent -Force | Out-Null
        }

        if (Test-Path $TargetPath) {
            $CurrentTarget = (Get-Item $TargetPath).Target
            if ($CurrentTarget -eq $SourcePath) {
                Write-Host "[SKIP] Link already exists: $TargetPath" -ForegroundColor DarkGray
                continue
            }

            $BackupPath = "$TargetPath.backup"
            if (Test-Path $BackupPath) { Remove-Item -Path $BackupPath -Recurse -Force }
            Rename-Item -Path $TargetPath -NewName (Split-Path $BackupPath -Leaf) -Force
            Write-Host "[BACKUP] Old config saved as .backup: $TargetPath" -ForegroundColor Magenta
        }

        try {
            New-Item -ItemType SymbolicLink -Path $TargetPath -Target $SourcePath -Force | Out-Null
            Write-Host "[OK] $SourcePath -> $TargetPath" -ForegroundColor Green
        } catch {
            Write-Host "[ERROR] Failed to create link $TargetPath. Run PowerShell as Administrator." -ForegroundColor Red
        }
    } else {
        Write-Host "[NOT FOUND] Source path $SourcePath does not exist." -ForegroundColor Yellow
    }
}

Write-Host "`n=== Setup Complete! ===" -ForegroundColor Cyan
