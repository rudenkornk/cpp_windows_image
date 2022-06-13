choco install make
choco install vim

# Support bash -C
$current_path = [Environment]::GetEnvironmentVariable("PATH", "Machine");
$new_path = "C:\Program Files\Git\bin;$current_path"
[Environment]::SetEnvironmentVariable("PATH", $new_path, "Machine")
