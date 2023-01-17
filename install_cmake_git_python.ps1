choco install cmake --version 3.25.1

# Support "docker exec"
$current_path = [Environment]::GetEnvironmentVariable("PATH", "Machine");
$new_path = "C:\Program Files\CMake\bin;$current_path"
[Environment]::SetEnvironmentVariable("PATH", $new_path, "Machine")


choco install git

choco install python --version=3.11.0

$env:path = "$env:path;C:\Python311;C:\Python310\Scripts"
New-Item -Path "C:\Python311\python3.exe" -ItemType SymbolicLink -Value "C:\Python311\python.exe"
