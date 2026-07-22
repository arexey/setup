
# Load posh-git
#Import-Module posh-git

#Install-Module -Name MSTerminalSettings
function global:score() {
	set-location c:\Projects\SettleTheScore\
}

function global:proj($project) {
	if (Test-Path c:\git\$project) {
		set-location c:\git\$project
		return
	}
	if (Test-Path d:\git\$project) {
		set-location d:\git\$project
		return
	}
	if (Test-Path f:\git\$project) {
		set-location f:\git\$project
		return
	}
}

function global:gitsyncall() {
	foreach ($dir in (dir .)) {
		Write-Host $dir.FullName -ForegroundColor Cyan; cd $dir.FullName ; git fm ; cd ..
	}
}

function global:vsenv() {
	InvokeScript (${env:ProgramFiles(x86)} + '\Microsoft Visual Studio 14.0\Common7\Tools\VsMSBuildCmd.bat')
}

function InvokeScript ([string] $script, [string] $parameters) {

	$tempFile = [IO.Path]::GetTempFileName()

	## Store the output of cmd.exe. We also ask cmd.exe to output
	## the environment table after the batch file completes
	& "$ENV:Comspec" /c " `"$script`" $parameters && set > `"$tempfile`""

	## Go through the environment variables in the temp file.
	## For each of them, set the variable in our local environment.
	Get-Content $tempFile | Foreach-Object {
		if ($_ -match "^(.*?)=(.*)$") {
			Set-Content "env:\$($matches[1])" $matches[2]
		}
	}

	Remove-Item $tempFile
}

function global:isadmin() {
	$wid = [System.Security.Principal.WindowsIdentity]::GetCurrent()
	$prp = new-object System.Security.Principal.WindowsPrincipal($wid)
	$adm = [System.Security.Principal.WindowsBuiltInRole]::Administrator
	$IsAdmin = $prp.IsInRole($adm)

	if ($IsAdmin) {
		Write-Host "Elevated" -ForegroundColor Green
		return $true
	}
 else {
		Write-Host "Not Elevated" -ForegroundColor Red
		return $false
	}
}

function global:monitorRazzle() {
	while ($true) {
		clear; 
		write-host "updating..."; 
		if (-not (git pull | Out-String).StartsWith("Already up-to-date.")) {
			(Get-WmiObject Win32_Process | Where-Object { $_.Name -eq "node.exe" } | select @{Name = "Id"; Expression = { $_.ProcessId } } | Get-Process).Kill(); npm i
		} 
		else {
			write-host "up-to-date"
		}
		write-host "waiting..."; 
		sleep 120
	}
}

function Refresh-Path {
	$Env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + 
	[System.Environment]::GetEnvironmentVariable('Path', 'User')
}
function Add-Path($path, $type = 'machine') {
	$current = [System.Environment]::GetEnvironmentVariable('Path', $type);
	[System.Environment]::SetEnvironmentVariable('PATH', $current + ';' + $path, $type) 
}
function Get-Path($type) { [System.Environment]::GetEnvironmentVariable('Path', $type) }

function global:dockerIps() {
	foreach ($container in (docker ps -q)) {
		$info = (docker inspect --format='{{.Name}} {{.Config.Hostname}} {{.NetworkSettings.Networks.nat.IPAddress}}' $container);
		Write-Output $info
	}
}
function global:dockerCleanUp() {
	foreach ($c in (docker container ls -a -q)) { 
		docker rm $c 
	}
}

function global:loopCommand($command, $timeout = 5) {
	while ($true) { $result = ($command.invoke()); Clear-Host; Write-Host $result; Start-Sleep $timeout }
}

function global:updateHostsEntry($dns, $ip) {
	Write-Host "updateHostsEntry $dns, $ip"
	$entry = "`t" + $ip + "`t`t" + $dns
	Write-Host "new entry: '$entry'"
	$hosts = Get-Content "$env:SystemRoot\system32\drivers\etc\hosts"
	Write-Output "read in hosts:"
	#Write-Output $hosts
	$replaced = $false
	for ($line = 0; $line -lt $hosts.Count; $line++) {
		if ($hosts[$line].Contains("`t$dns")) {
			Write-Output "replacing '$hosts[$line]' with '$entry'"
			$hosts[$line] = $entry;
			$replaced = $true
		}
	}
	if (-not $replaced) {
		Write-Output "adding '$entry'"
		$hosts += $entry
	}
	Write-Output "writing to hosts:"
	#Write-Output $hosts
	Set-Content "$env:SystemRoot\system32\drivers\etc\hosts" $hosts -Force
}

function global:linuxOff() {
	wsl --shutdown
}

# $folder = (Find-MSTerminalFolder)
# if (-not (Test-Path $folder)) {
# 	New-Item -ItemType Directory $folder
# }

# $filter = "*.json"
# $Watcher = New-Object IO.FileSystemWatcher $folder, $filter -Property @{ 
#     IncludeSubdirectories = $false
#     NotifyFilter = [IO.NotifyFilters]'FileName, LastWrite'
# }
# $onCreated = Register-ObjectEvent $Watcher Created -SourceIdentifier FileCreated -Action {
#    $path = $Event.SourceEventArgs.FullPath
#    $name = $Event.SourceEventArgs.Name
#    $changeType = $Event.SourceEventArgs.ChangeType
#    $timeStamp = $Event.TimeGenerated
#    Write-Host "The file '$name' was $changeType at $timeStamp"
#    Write-Host $path
#    #Move-Item $path -Destination $destination -Force -Verbose
# }
$happyBg = "http://i.imgur.com/Po8pR3A.gif"
$happyBg = "https://66.media.tumblr.com/db2917bb82134ccb4ad456284b07932b/tumblr_osxlak6ok21qeyvpto1_500.gif"
$unhappyBg = "https://2.bp.blogspot.com/-CPO_z4zNSnc/WsY667p0JgI/AAAAAAAAYRs/ubTMJD5ToyImbR-o4EiK18gBypYXd0RiwCLcBGAs/s1600/Mercenary%2BGarage%2BError%2BGIF.gif"
function prompt {
	$bg = if ($?) { $happyBg } else { $unhappyBg };
	Get-MSTerminalProfile -Name "Windows PowerShell" | Set-MSTerminalProfile -BackgroundImage $bg; 
	Invoke-Command  $global:GitPromptScriptBlock
} 

function global:Install-Iterm2Theme($theme, $use = $true) {
	$themeUrl = "https://raw.githubusercontent.com/mbadolato/iTerm2-Color-Schemes/master/schemes/$theme.itermcolors"
	Write-Host "Downloading theme '$theme' from '$themeUrl' to '$PSScriptRoot\$theme.itermcolors'"
	Invoke-RestMethod -Uri $themeUrl -OutFile "$PSScriptRoot\themes\$theme.itermcolors"
	Import-Iterm2ColorScheme -Name $theme $PSScriptRoot\themes\$theme.itermcolors
	if ($use) {
		Get-MSTerminalProfile -Name "Windows PowerShell" | Set-MSTerminalProfile -ColorScheme $theme
	}
}

function global:omp-refresh {
	$config = Join-Path (Split-Path -Parent $PSScriptRoot) 'prompt.omp.json'
	oh-my-posh init pwsh --config $config | Invoke-Expression
}

Import-Module -Name Terminal-Icons
omp-refresh

Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
Set-PSReadLineOption -PredictionSource History
