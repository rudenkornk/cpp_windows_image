choco install llvm --version 14.0.0

Write-Output -InputObject "
<Project>
  <PropertyGroup>
    <LLVMInstallDir>C:\Program Files\LLVM</LLVMInstallDir>
    <LLVMToolsVersion>14.0.0</LLVMToolsVersion>
  </PropertyGroup>
</Project>
" | Out-File "C:\Directory.build.props"

