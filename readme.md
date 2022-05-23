# Docker image for C++ CI on Windows

Docker image for C++ CI on Windows.

[![GitHub Actions Status](https://github.com/rudenkornk/docker_cpp_windows/actions/workflows/workflow.yml/badge.svg)](https://github.com/rudenkornk/docker_cpp_windows/actions)


## Build
```pwsh
make rudenkornk/docker_cpp_windows
```

## Test
```pwsh
make check
```

## Run
```pwsh
$env:CI_BIND_MOUNT=(Get-Location).ToString(); make docker_cpp_windows_container

docker attach docker_cpp_windows_container
# OR
docker exec -it docker_cpp_container pwsh -Command "<command>"
# OR with VS environment
docker exec -it docker_cpp_container cmd /C "vs_exec.bat <pwsh_command>"
```

## Clean
```pwsh
make clean
# Optionally clean entire docker system and remove ALL containers
.\clean_all_docker.ps1
```

## Different use cases for this repository

### 1. Use image directly for local testing or CI

```pwsh
docker run --interactive --tty `
  --mount type=bind,source="$(Get-Location)",target=C:\repo `
  --memory 2G `
  rudenkornk/docker_cpp_windows:latest
```
Instead of `$(Get-Location)` use path to your C++ repo.
It is recommended to mount it into `/home/repo`.

