# Container image for C++ builds on Windows

Container image for reproducible C++ builds targeting local and CI usage on Windows.  

[![GitHub Actions Status](https://github.com/rudenkornk/docker_cpp_windows/actions/workflows/workflow.yml/badge.svg)](https://github.com/rudenkornk/cpp_windows_image/actions)


## Using the image
```pwsh
docker run --interactive --tty --detach `
 --isolation=process <# process or hyperv #> `
 --memory 8G `
 --mount type=bind,source="$(Get-Location)",target="$(Get-Location)" `
 --workdir "$(Get-Location)" `
 --name cpp `
 --user ContainerAdministrator `
 ghcr.io/rudenkornk/cpp_windows:1.0.1

# Execute single command
docker exec cpp pwsh -Command 'your_command'

# Attach to container
docker exec --interactive cpp pwsh
```

## Build
**Requirements:** `docker >= 20.10.16`, `GNU Make >= 4.3`, `pwsh >= 7.2.8`   
```pwsh
make
```

## Test
```pwsh
make check
```

## Clean
```pwsh
make clean
```
