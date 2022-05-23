Invoke-WebRequest -Uri https://github.com/PowerShell/PowerShell/releases/download/v7.2.4/PowerShell-7.2.4-win-x64.zip  -UseBasicParsing -OutFile PowerShell-7.2.4-win-x64.zip
Expand-Archive PowerShell-7.2.4-win-x64.zip
Remove-Item PowerShell-7.2.4-win-x64.zip

New-Item -Path "C:\Program Files" -Name "PowerShell" -ItemType "directory"
Move-Item PowerShell-7.2.4-win-x64 "C:\Program Files\PowerShell\7"

$current_path = [Environment]::GetEnvironmentVariable("PATH", "Machine");
$new_path = "$current_path;C:\Program Files\powershell\7\"
[Environment]::SetEnvironmentVariable("PATH", $new_path, "Machine")

