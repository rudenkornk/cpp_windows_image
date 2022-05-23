# FileCheck is not included in bundle, this compile it manually
$cores = (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfLogicalProcessors
if ($cores -lt 1) { $cores = 1 }
git clone --config core.autocrlf=false --branch release/14.x https://github.com/llvm/llvm-project.git
Set-Location llvm-project
cmake -S llvm -B build
cmake --build build --config Release --parallel $cores --target FileCheck
Move-Item build\Release\bin\FileCheck.exe "C:\Program Files\LLVM\bin"
Set-Location ..
Remove-Item -Recurse -Force llvm-project


pip3 install lit==14.0.0
pip3 install psutil
