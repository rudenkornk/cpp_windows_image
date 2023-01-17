SHELL := pwsh.exe
.SHELLFLAGS := -Command

CACHE_FROM ?=
ISOLATION ?= process # process or hyperv

BASE_NAME := cpp_windows
IMAGE_TAG := 1.0.1

PROJECT := rudenkornk/cpp_windows_image
BUILD_DIR := __build__
BUILD_TESTS := $(BUILD_DIR)/tests
CONTAINER_NAME := cpp
IMAGE_NAME := rudenkornk/$(BASE_NAME)
IMAGE_NAMETAG := $(IMAGE_NAME):$(IMAGE_TAG)
TESTS_DIR := tests
VCS_REF != git rev-parse HEAD

USER := ContainerAdministrator
MEMORY := 8G

DEPS :=
DEPS += install_vsbt.bat
DEPS += install_chocolatey.ps1
DEPS += install_llvm.ps1
DEPS += install_cmake_git_python.ps1
DEPS += install_pwsh.ps1
DEPS += install_llvm_tools.ps1
DEPS += config_system.ps1
DEPS += vs_exec.bat
DEPS += Dockerfile

HELLO_WORLD_DEPS += $(shell Get-ChildItem -Recurse -File -Name $(TESTS_DIR) | %{"$(TESTS_DIR)\" + $$_} )

.PHONY: image
image: $(BUILD_DIR)/image

.PHONY: container
container: $(BUILD_DIR)/container

.PHONY: image_name
image_name:
	$(info $(IMAGE_NAME))

.PHONY: image_nametag
image_nametag:
	$(info $(IMAGE_NAMETAG))

.PHONY: image_tag
image_tag:
	$(info $(IMAGE_TAG))

.PHONY: $(BUILD_DIR)/not_ready

IMAGE_ID != docker images --quiet $(IMAGE_NAMETAG)
IMAGE_CREATE_STATUS != if(!"$(IMAGE_ID)"){return "$(BUILD_DIR)/not_ready"}
CACHE_FROM_OPTION != if("$(CACHE_FROM)"){return "--cache-from $(CACHE_FROM)"}
$(BUILD_DIR)/image: $(DEPS) $(IMAGE_CREATE_STATUS)
	docker build <# \
		#> $(CACHE_FROM_OPTION) <#\
		#> --label "org.opencontainers.image.ref.name=$(IMAGE_NAME)" <#\
		#> --label "org.opencontainers.image.revision=$(VCS_REF)" <#\
		#> --label "org.opencontainers.image.source=https://github.com/$(PROJECT)" <#\
		#> --label "org.opencontainers.image.version=$(IMAGE_TAG)" <#\
		#> --isolation=$(ISOLATION) <#\
		#> --memory $(MEMORY) <#\
		#> --tag $(IMAGE_NAMETAG) .
	New-Item -Force -Name "$@" -ItemType File

CONTAINER_ID != docker container ls --quiet --all --filter name="^/$(CONTAINER_NAME)$$"
CONTAINER_STATE != docker container ls --format "{{.State}}" --all --filter name="^/$(CONTAINER_NAME)$$"
CONTAINER_RUN_STATUS != if("$(CONTAINER_STATE)" -ne "running"){return "$(BUILD_DIR)/not_ready"}
CONTAINER_MOUNT != $$Letter=$$(Split-Path $$(Get-Location) -Qualifier); if("$$Letter" -eq "C:"){return "$$(Get-Location)"}else{return "$$Letter"}
$(BUILD_DIR)/container: $(BUILD_DIR)/image $(CONTAINER_RUN_STATUS)
ifneq ($(CONTAINER_ID),)
	docker container rename $(CONTAINER_NAME) $(CONTAINER_NAME)_$(CONTAINER_ID)
endif
	$$Letter=$$(Split-Path $$(Get-Location) -Qualifier); <#\
	#> if("$$Letter" -ne "C:") <#\
		#> { <#\
		#> echo "[WARNING] Looks like this project is not located under drive C:, but rather drive $$Letter."; <#\
		#> echo "[WARNING] Docker containers on Windows do not support mounting to subdirectories under non-C drives."; <#\
		#> echo "[WARNING] However, they can mount directory to the root of the non-C drive."; <#\
		#> echo "[WARNING] For this reason we will mount the whole drive $$Letter to the container."; <#\
		#> echo "[WARNING] See https://stackoverflow.com/a/73955240/8099151"; <#\
		#> }; <#\
	#> docker run --interactive --tty --detach <#\
		#> --isolation=$(ISOLATION) <#\
		#> --memory $(MEMORY) <#\
		#> --mount type=bind,source="$(CONTAINER_MOUNT)",target="$(CONTAINER_MOUNT)" <#\
		#> --workdir "$$(Get-Location)" <#\
		#> --name $(CONTAINER_NAME) <#\
		#> --user $(USER) <#\
		#> $(IMAGE_NAMETAG)
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_TESTS)/msvc/hello_world: $(BUILD_DIR)/container $(HELLO_WORLD_DEPS)
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command " <#\
		#> C:\vs_exec.bat <#\
		#> cmake <#\
		#> -S $(TESTS_DIR) <#\
		#> -B $(BUILD_TESTS)/msvc <#\
		#> -G Ninja <#\
		#> -D CMAKE_C_COMPILER:STRING='cl.exe' <#\
		#> -D CMAKE_CXX_COMPILER:STRING='cl.exe' <#\
		#> -D CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON <#\
	  #> "
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command "<#\
		#> C:\vs_exec.bat <#\
		#> cmake <#\
		#> --build $(BUILD_TESTS)/msvc <#\
		#> --verbose <#\
	  #> "
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command " <#\
		#> .\$(BUILD_TESTS)\msvc\hello_world.exe <#\
		#> " | Select-String "Hello world!" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "hello_world failed!"}
	Select-String -Path $(BUILD_TESTS)/msvc/compile_commands.json -Pattern "cl.exe" -Raw -OutVariable ret; <#\
	#> if(!$$ret){throw "Wrong compiler!"}
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_TESTS)/llvm/hello_world: $(BUILD_DIR)/container $(HELLO_WORLD_DEPS)
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command " <#\
		#> cmake <#\
		#> -S $(TESTS_DIR) <#\
		#> -B $(BUILD_TESTS)/llvm <#\
		#> -G Ninja <#\
		#> -D CMAKE_EXPORT_COMPILE_COMMANDS:BOOL=ON <#\
		#> -D CMAKE_C_COMPILER:STRING='clang.exe' <#\
		#> -D CMAKE_CXX_COMPILER:STRING='clang++.exe' <#\
	  #> "
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command "<#\
		#> cmake <#\
		#> --build $(BUILD_TESTS)/llvm <#\
		#> --verbose <#\
	  #> "
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command " <#\
		#> .\$(BUILD_TESTS)\llvm\hello_world.exe <#\
		#> " | Select-String "Hello world!" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "hello_world failed!"}
	Select-String -Path $(BUILD_TESTS)/llvm/compile_commands.json -Pattern "clang" -Raw -OutVariable ret; <#\
	#> if(!$$ret){throw "Wrong compiler!"}
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_TESTS)/versions: $(BUILD_DIR)/container
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command "cmake --version" | Select-String "3\.25\.1" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "LLVM version check failed!"}
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command "clang --version" | Select-String "15\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "LLVM version check failed!"}
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command "clang++ --version" | Select-String "15\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "LLVM version check failed!"}
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command "clang-format --version" | Select-String "15\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "clang-format version check failed!"}
	docker exec $(CONTAINER_NAME) <#\
		#> pwsh -Command "FileCheck --version" | Select-String "15\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "llvm-lit version check failed!"}
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_TESTS)/readme: readme.md
	Select-String -Path .\readme.md -Pattern "$(IMAGE_NAMETAG)" -Raw -OutVariable ret; <#\
	#> if(!$$ret){throw "readme.md have outdated image verion!"}
	New-Item -Force -Name "$@" -ItemType File


.PHONY: check
check: \
	$(BUILD_TESTS)/msvc/hello_world \
	$(BUILD_TESTS)/llvm/hello_world \
	$(BUILD_TESTS)/versions \
	$(BUILD_TESTS)/readme \


.PHONY: clean
clean:
	docker container ls --quiet --filter name=$(CONTAINER_NAME) | %{ docker stop $$_ }
	docker container ls --quiet --filter name=$(CONTAINER_NAME) --all | %{ docker rm $$_ }

