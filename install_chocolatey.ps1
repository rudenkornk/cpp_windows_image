powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force;[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072;(iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1')))"

$env:path = "$env:path;C:\ProgramData\chocolatey\bin"

choco feature enable -n allowGlobalConfirmation

