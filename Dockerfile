FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]
WORKDIR C:\\container

COPY install_vsbt.bat ./
RUN ./install_vsbt.bat

COPY install_chocolatey.ps1 ./
RUN ./install_chocolatey.ps1

COPY install_llvm.ps1 ./
RUN ./install_llvm.ps1

COPY install_cmake_git_python.ps1 ./
RUN ./install_cmake_git_python.ps1

COPY install_pwsh.ps1 ./
RUN ./install_pwsh.ps1

SHELL ["pwsh", "-Command"]

COPY install_llvm_tools.ps1 ./
RUN ./install_llvm_tools.ps1

COPY config_system.ps1 ./
RUN ./config_system.ps1

COPY vs_exec.bat C:\\vs_exec.bat

ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "pwsh.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]


# See https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors="Nikita Rudenko"
LABEL org.opencontainers.image.vendor="Nikita Rudenko"
LABEL org.opencontainers.image.title="Container image for C++ builds on Windows"
LABEL org.opencontainers.image.base.name="mcr.microsoft.com/windows/servercore:ltsc2022"
