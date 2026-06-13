#!/usr/bin/env pwsh
[CmdletBinding()]
param(
    [switch]$Force
)

$ErrorActionPreference = 'Stop'
Set-StrictMode -Version Latest

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$userProfile = [Environment]::GetFolderPath('UserProfile')
$appData = [Environment]::GetFolderPath('ApplicationData')

function New-Symlink {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Source,

        [Parameter(Mandatory = $true)]
        [string]$Target
    )

    $parentDir = Split-Path -Parent $Target
    if ($parentDir -and -not (Test-Path -LiteralPath $parentDir)) {
        New-Item -ItemType Directory -Path $parentDir -Force | Out-Null
    }

    if (Test-Path -LiteralPath $Target) {
        $sourceResolved = (Resolve-Path -LiteralPath $Source).Path
        $targetResolved = $null

        try {
            $targetResolved = (Resolve-Path -LiteralPath $Target).Path
        } catch {
            $targetResolved = $null
        }

        if ($targetResolved -eq $sourceResolved) {
            Write-Host "OK  $Target -> $Source"
            return
        }

        if (-not $Force) {
            throw "Target already exists: $Target. Re-run with -Force to replace it."
        }

        Remove-Item -LiteralPath $Target -Force -Recurse
    }

    try {
        New-Item -ItemType SymbolicLink -Path $Target -Target $Source | Out-Null
        Write-Host "LINK  $Target -> $Source"
    } catch {
        throw "Failed to create symlink '$Target' -> '$Source'. On Windows you may need Developer Mode or an elevated PowerShell session. $($_.Exception.Message)"
    }
}

$links = @(
    @{
        Source = Join-Path $repoRoot 'apps\vscode\settings.json'
        Target = Join-Path $appData 'Code\User\settings.json'
    },
    @{
        Source = Join-Path $repoRoot 'apps\vscode\keybindings.json'
        Target = Join-Path $appData 'Code\User\keybindings.json'
    },
    @{
        Source = Join-Path $repoRoot 'apps\vscode\snippets'
        Target = Join-Path $appData 'Code\User\snippets'
    }
)

Write-Host "Windows dotfiles symlink setup"
Write-Host "Repo root: $repoRoot"
Write-Host "User profile: $userProfile"
Write-Host "Application data: $appData"

foreach ($link in $links) {
    New-Symlink -Source $link.Source -Target $link.Target
}

Write-Host 'Done.'