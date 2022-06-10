Invoke-WebRequest -Uri https://boostorg.jfrog.io/artifactory/main/release/1.79.0/source/boost_1_79_0.zip -UseBasicParsing -OutFile boost_1_79_0.zip
Expand-Archive boost_1_79_0.zip
Remove-Item boost_1_79_0.zip

New-Item -Path "C:\Program Files" -Name "boost" -ItemType "directory"
Move-Item boost_1_79_0\boost_1_79_0 "C:\Program Files\boost\"

$loc = Get-Location
Set-Location "C:\Program Files\boost\boost_1_79_0"
./bootstrap.bat
./b2.exe install --prefix="C:\Program Files\boost\boost_1_79_0\" --build-dir="tmp"
Remove-Item -Force -Recurse "tmp"
Set-Location $loc

$current_include = [Environment]::GetEnvironmentVariable("INCLUDE", "Machine");
$new_include = "$current_include;C:\Program Files\boost\boost_1_79_0\"
[Environment]::SetEnvironmentVariable("INCLUDE", $new_include, "Machine")

$current_lib = [Environment]::GetEnvironmentVariable("LIB", "Machine");
$new_lib = "$current_lib;C:\Program Files\boost\boost_1_79_0\lib"
[Environment]::SetEnvironmentVariable("LIB", $new_lib, "Machine")

