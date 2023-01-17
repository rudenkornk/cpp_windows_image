choco install llvm --version 15.0.5

Write-Output -InputObject "
<Project>
  <PropertyGroup>
    <LLVMInstallDir>C:\Program Files\LLVM</LLVMInstallDir>
    <LLVMToolsVersion>15.0.5</LLVMToolsVersion>
  </PropertyGroup>
</Project>
" | Out-File "C:\Directory.build.props"

