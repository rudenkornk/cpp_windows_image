FROM mcr.microsoft.com/windows/servercore:ltsc2022

SHELL ["powershell", "-Command"]

COPY install_pwsh.ps1 ./
RUN ./install_pwsh.ps1

SHELL ["pwsh", "-Command"]

COPY install_vsbt.bat ./
RUN ./install_vsbt.bat

COPY install_chocolatey.ps1 ./
RUN ./install_chocolatey.ps1

COPY install_llvm.ps1 ./
RUN ./install_llvm.ps1

COPY install_cmake.ps1 ./
RUN ./install_cmake.ps1

COPY install_python.ps1 ./
RUN ./install_python.ps1

COPY install_llvm_tools.ps1 ./
RUN ./install_llvm_tools.ps1

COPY install_conan.ps1 ./
RUN ./install_conan.ps1

COPY conan C:\\Users\\ContainerAdministrator\\.conan
COPY --chown=ContainerUser conan C:\\Users\\ContainerUser\\.conan
COPY config_conan.ps1 ./
RUN ./config_conan.ps1
USER ContainerUser
RUN ./config_conan.ps1
USER ContainerAdministrator

COPY config_system.ps1 ./
RUN ./config_system.ps1

COPY Profile.ps1 C:\\Users\\ContainerAdministrator\\Documents\\PowerShell\\Profile.ps1
COPY Profile.ps1 C:\\Users\\ContainerUser\\Documents\\PowerShell\\Profile.ps1
COPY vs_exec.bat C:\\vs_exec.bat

WORKDIR C:\\repo

ENTRYPOINT ["C:\\Program Files (x86)\\Microsoft Visual Studio\\2022\\BuildTools\\Common7\\Tools\\VsDevCmd.bat", "&&", "pwsh.exe", "-NoLogo", "-ExecutionPolicy", "Bypass"]


# See https://github.com/opencontainers/image-spec/blob/main/annotations.md
LABEL org.opencontainers.image.authors="Nikita Rudenko"
LABEL org.opencontainers.image.vendor="Nikita Rudenko"
LABEL org.opencontainers.image.title="Docker image for C++ CI on Windows"
LABEL org.opencontainers.image.base.name="mcr.microsoft.com/windows/servercore:ltsc2022"

ARG IMAGE_NAME
LABEL org.opencontainers.image.ref.name="${IMAGE_NAME}"
LABEL org.opencontainers.image.url="https://hub.docker.com/repository/docker/${IMAGE_NAME}"
LABEL org.opencontainers.image.source="https://github.com/${IMAGE_NAME}"

ARG VERSION
LABEL org.opencontainers.image.version="${VERSION}"

ARG VCS_REF
LABEL org.opencontainers.image.revision="${VCS_REF}"

ARG BUILD_DATE
LABEL org.opencontainers.image.created="${BUILD_DATE}"

