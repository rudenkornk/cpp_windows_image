choco install cmake --version 3.23.2

# Support "docker exec"
$current_path = [Environment]::GetEnvironmentVariable("PATH", "Machine");
$new_path = "C:\Program Files\CMake\bin;$current_path"
[Environment]::SetEnvironmentVariable("PATH", $new_path, "Machine")

