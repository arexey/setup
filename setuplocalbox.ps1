#Requires -Version 5.1
# Windows dev-environment setup. Idempotent — safe to re-run.
# Run from a PowerShell prompt (as Administrator recommended for winget installs).

$ErrorActionPreference = 'Stop'
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

# --- 1. Install baseline PowerShell modules ------------------------------------
if ($IsWindows -and -not (Get-Module -Name MSTerminalSettings -ListAvailable)) {
    Write-Host "Installing MSTerminalSettings module..."
    Install-Module -Name MSTerminalSettings -Force -Scope CurrentUser
}
if (-not (Get-Command oh-my-posh -ErrorAction SilentlyContinue)) {
    Write-Host "Installing OhMyPosh..."
    Set-ExecutionPolicy Bypass -Scope Process -Force
    Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
}
if ($IsWindows -and -not (Get-ChildItem "$env:SystemRoot\Fonts\Meslo*Nerd*.ttf" -ErrorAction SilentlyContinue)) {
    Write-Host "Installing Meslo Nerd Font..."
    oh-my-posh font install Meslo
}
if ($IsWindows -and -not (Get-Module -Name Terminal-Icons -ListAvailable)) {
    Write-Host "Installing Terminal-Icons..."
    Install-Module -Name Terminal-Icons -Repository PSGallery -Force -Scope CurrentUser
}

# --- 2. Nerd Fonts (broader set) ----------------------------------------------
if ($IsWindows -and -not (Test-Path (Join-Path $ScriptDir 'nerd-fonts'))) {
    git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git (Join-Path $ScriptDir 'nerd-fonts')
    & (Join-Path $ScriptDir 'nerd-fonts\install.ps1')
}

# --- 3. Optional tools via winget ---------------------------------------------
# Everything here used to be bundled in the repo. Now installed on demand.
if ($IsWindows -and (Get-Command winget -ErrorAction SilentlyContinue)) {
    $wingetPackages = @(
        'Cmder-Mini.Cmder-Mini',                 # terminal
        'NirSoft.ProcessExplorer',               # sysinternals
        'Microsoft.Sysinternals.ProcessMonitor', # sysinternals
        'REALiX.HWiNFO',                         # hardware info
        'NickeManarin.ScreenToGif',              # screen capture -> gif
        'VideoLAN.VLC',                          # media player
        'GIMP.GIMP',                             # image editor
        'dotPDN.PaintDotNet',                    # image editor
        'WinDirStat.WinDirStat',                 # disk usage
        'WinMerge.WinMerge'                      # diff/merge
    )
    foreach ($pkg in $wingetPackages) {
        Write-Host "winget install $pkg ..."
        winget install --id $pkg --silent --accept-source-agreements --accept-package-agreements -e 2>&1 |
            Where-Object { $_ -notmatch 'already installed' } | Out-Host
    }
}

# --- 4. Wire the PowerShell profile -------------------------------------------
$profilePath = Join-Path $ScriptDir 'Powershell\Microsoft.PowerShell_profile.ps1'
$scriptCommand = ". '$profilePath'"

if (-not (Test-Path $PROFILE)) {
    $parent = Split-Path -Parent $PROFILE
    if (-not (Test-Path $parent)) { New-Item -Path $parent -ItemType Directory -Force | Out-Null }
    New-Item -Path $PROFILE -ItemType File -Force | Out-Null
}
$existing = Get-Content $PROFILE -Raw -ErrorAction SilentlyContinue
if ($existing -notmatch [regex]::Escape($scriptCommand)) {
    Add-Content -Path $PROFILE -Value $scriptCommand
}

# --- 5. Windows Terminal font -------------------------------------------------
if ($IsWindows) {
    $settingsFile = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json'
    if (-not (Test-Path $settingsFile)) {
        $settingsFile = Join-Path $env:LOCALAPPDATA 'Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json'
    }
    if (Test-Path $settingsFile) {
        $settings = Get-Content $settingsFile -Raw | ConvertFrom-Json
        if ($null -eq $settings.profiles.defaults) {
            Add-Member -InputObject $settings.profiles -Name 'defaults' -Value @{} -MemberType NoteProperty -Force
        }
        if ($null -eq $settings.profiles.defaults.font) {
            Add-Member -InputObject $settings.profiles.defaults -Name 'font' -Value @{} -MemberType NoteProperty -Force
        }
        $settings.profiles.defaults.font.face = 'MesloLGM NF'
        Set-Content -Path $settingsFile -Value (ConvertTo-Json $settings -Depth 32)
    }
}

. $PROFILE
