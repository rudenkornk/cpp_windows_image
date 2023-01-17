curl -SL --output vs_buildtools.exe https://aka.ms/vs/17/release/vs_buildtools.exe

:: Install Build Tools, excluding workloads and components with known issues.
:: See https://docs.microsoft.com/en-us/visualstudio/install/workload-component-id-vs-build-tools?view=vs-2022&preserve-view=true#desktop-development-with-c
start /w vs_buildtools.exe --quiet --wait --norestart --nocache ^
    --installPath "%ProgramFiles(x86)%\Microsoft Visual Studio\2022\BuildTools" ^
    --add Microsoft.VisualStudio.Workload.VCTools --includeRecommended ^
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10240 ^
    --remove Microsoft.VisualStudio.Component.Windows10SDK.10586 ^
    --remove Microsoft.VisualStudio.Component.Windows10SDK.14393 ^
    --remove Microsoft.VisualStudio.Component.Windows81SDK

mkdir "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\IDE\CommonExtensions\Microsoft\TeamFoundation\Team Explorer"

:: Cleanup
del /q vs_buildtools.exe
