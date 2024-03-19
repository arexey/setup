# Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force
# Invoke-WebRequest https://chocolatey.org/install.ps1 -UseBasicParsing | iex
# choco install git poshgit -y
#Install-Module posh-git -Force
if ($IsWindows -and (Get-Module -Name MSTerminalSettings -ListAvailable).Length -eq 0) {
    Write-Host "Installing MSTermminalSettings module..."
    Install-Module -Name MSTerminalSettings
}
if ((Get-Command oh-my-posh).Length -eq 0) {
    Write-Host "Installing OhMyPosh..."
    Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://ohmyposh.dev/install.ps1'))
    # winget install JanDeDobbeleer.OhMyPosh -s winget
}
if ($IsWindows -and (gci "$env:SystemRoot\Fonts\Meslo LG M Bold Italic Nerd Font Complete Windows Compatible.ttf").Length -eq 0) {
    Write-Host "Installing Meslo Font..."
    oh-my-posh font install Meslo
}
if ($IsWindows -and (Get-Module -Name Terminal-Icons -ListAvailable).Length -eq 0) {
    Write-Host "Installing Terminal-Icons..."
    Install-Module -Name Terminal-Icons -Repository PSGallery
}

if($IsWindows) {
    git clone --depth 1 https://github.com/ryanoasis/nerd-fonts.git
    .\nerd-fonts\install.ps1
# }
# else {
#     .\nerd-fonts\install.sh
}

$ScriptDir = Split-Path $script:MyInvocation.MyCommand.Path
$profilepath = $ScriptDir + "\Powershell\Microsoft.PowerShell_profile.ps1"
$gitconfigpath = $ScriptDir + "\.gitconfig"

$scriptcommand = ".'$profilepath'"

$lines = "";
if (Test-Path $PROFILE) {
    $lines = [System.IO.File]::ReadAllLines($PROFILE)
}
else {
    $profilePath = "$env:USERPROFILE\Documents"
    if(-not $IsWindows) {
        $profilePath = "$env:HOME\.config\powershell"
    }
    New-Item -Path $profilePath -Name "WindowsPowerShell" -ItemType directory
    New-Item -Path $PROFILE -ItemType file
}

if (-not $lines.Contains($scriptCommand)) {
    $lines = $lines + $scriptcommand
    [System.IO.File]::WriteAllLines($PROFILE, $lines)
}

if ($IsWindows) {
    $settingsFile = "${Find-MSTerminalFolder}AppData\Local\Packages\Microsoft.WindowsTerminalPreview_8wekyb3d8bbwe\LocalState\settings.json"
    $settings = (gc $settingsFile | ConvertFrom-Json)
    if ($settings.profiles.defaults.font -eq $null) {
        if ($settings.profiles.defaults -eq $null) {
            $settings.profiles.defaults = @{}
        }
        else {
            $settings.profiles.defaults | fc
        }
        Add-Member -InputObject $settings.profiles.defaults -Name 'font' -Value @{} -MemberType NoteProperty
        # $settings.profiles.defaults.font = @{}
    }
    else {
        $settings.profiles.defaults.font | fc
    }
    $settings.profiles.defaults.font | fc
    $settings.profiles.defaults.font.face | fc
    $settings.profiles.defaults.font.face = "MesloLGM NF"
    $settings.profiles.defaults.font | fc
    set-content -Path $settingsFile -Value (ConvertTo-Json $settings)
}
    
copy $gitconfigpath $env:USERPROFILE
    
.$PROFILE
