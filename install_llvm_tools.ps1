# FileCheck is not included in bundle, this compile it manually
$cores = (Get-CimInstance -ClassName Win32_ComputerSystem).NumberOfLogicalProcessors
if ($cores -lt 1) { $cores = 1 }
git clone --config core.autocrlf=false --branch release/15.x https://github.com/llvm/llvm-project.git
Set-Location llvm-project
cmake -S llvm -B build
cmake --build build --config Release --parallel $cores --target `
  FileCheck `
  not `
  count `

Copy-Item clang\tools\clang-format\clang-format-diff.py "C:\Program Files\LLVM\bin"
Move-Item build\Release\bin\FileCheck.exe "C:\Program Files\LLVM\bin"
Move-Item build\Release\bin\not.exe "C:\Program Files\LLVM\bin"
Move-Item build\Release\bin\count.exe "C:\Program Files\LLVM\bin"
Set-Location ..
Remove-Item -Recurse -Force llvm-project # This fails with powershell, but OK with pwsh
