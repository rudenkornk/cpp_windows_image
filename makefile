SHELL := pwsh.exe
.SHELLFLAGS := -Command

PROJECT_NAME := docker_cpp_windows
VCS_REF ?= $(shell git rev-parse HEAD)
VCS_REF := $(VCS_REF)
BUILD_DATE ?= $(shell Get-Date -Format "yyyy-MM-dd")
BUILD_DATE := $(BUILD_DATE)
BUILD_DIR ?= build
TESTS_DIR ?= tests
CI_BIND_MOUNT ?= $(shell (Get-Location).ToString())
CI_BIND_MOUNT := $(CI_BIND_MOUNT)
DOCKER_IMAGE_VERSION ?= 0.1.3
DOCKER_IMAGE_NAME := rudenkornk/$(PROJECT_NAME)
DOCKER_IMAGE_TAG := $(DOCKER_IMAGE_NAME):$(DOCKER_IMAGE_VERSION)
DOCKER_IMAGE := $(BUILD_DIR)/$(PROJECT_NAME)_image_$(DOCKER_IMAGE_VERSION)
DOCKER_CACHE_FROM ?=
DOCKER_ISOLATION ?= hyperv # process or hyperv
DOCKER_CONTAINER_NAME ?= $(PROJECT_NAME)_container
DOCKER_CONTAINER := $(BUILD_DIR)/$(DOCKER_CONTAINER_NAME)_$(DOCKER_IMAGE_VERSION)
DOCKER_TEST_CONTAINER_NAME := $(PROJECT_NAME)_test_container
DOCKER_TEST_CONTAINER := $(BUILD_DIR)/$(DOCKER_TEST_CONTAINER_NAME)_$(DOCKER_IMAGE_VERSION)

DOCKER_DEPS :=
DOCKER_DEPS += Dockerfile
DOCKER_DEPS += Profile.ps1
DOCKER_DEPS += install_pwsh.ps1
DOCKER_DEPS += install_vsbt.bat
DOCKER_DEPS += install_boost.ps1
DOCKER_DEPS += install_chocolatey.ps1
DOCKER_DEPS += install_llvm.ps1
DOCKER_DEPS += install_cmake.ps1
DOCKER_DEPS += install_python.ps1
DOCKER_DEPS += install_llvm_tools.ps1
DOCKER_DEPS += config_system.ps1

HELLO_WORLD_DEPS :=
HELLO_WORLD_DEPS += $(TESTS_DIR)/hello_world.cpp
HELLO_WORLD_DEPS += $(TESTS_DIR)/CMakeLists.txt

.PHONY: $(DOCKER_IMAGE_NAME)
$(DOCKER_IMAGE_NAME): $(DOCKER_IMAGE)

.PHONY: docker_image_name
docker_image_name:
	$(info $(DOCKER_IMAGE_NAME))

.PHONY: docker_image_tag
docker_image_tag:
	$(info $(DOCKER_IMAGE_TAG))

.PHONY: docker_image_version
docker_image_version:
	$(info $(DOCKER_IMAGE_VERSION))

DOCKERD_UP := $(shell try{Set-Variable -Name ErrorActionPreference -Value stop -Scope Private; if((Get-Command docker) -and (Get-Process dockerd)){return $$true}}Catch{return $$false})
DOCKER_IMAGE_ID := $(shell if($$$(DOCKERD_UP)){return (docker images --quiet $(DOCKER_IMAGE_TAG))})
DOCKER_IMAGE_CREATE_STATUS := $(shell if(!"$(DOCKER_IMAGE_ID)"){return "$(DOCKER_IMAGE)_not_created"})
DOCKER_CACHE_FROM_COMMAND := $(shell if("$(DOCKER_CACHE_FROM)"){return "--cache-from $(DOCKER_CACHE_FROM)"})
.PHONY: $(DOCKER_IMAGE)_not_created
$(DOCKER_IMAGE): $(DOCKER_DEPS) $(DOCKER_IMAGE_CREATE_STATUS)
	docker build <# \
		#> $(DOCKER_CACHE_FROM_COMMAND) <#\
		#> --build-arg IMAGE_NAME="$(DOCKER_IMAGE_NAME)" <#\
		#> --build-arg VERSION="$(DOCKER_IMAGE_VERSION)" <#\
		#> --build-arg VCS_REF="$(VCS_REF)" <#\
		#> --build-arg BUILD_DATE="$(BUILD_DATE)" <#\
		#> --isolation=$(DOCKER_ISOLATION) <#\
		#> --memory 2G <#\
		#> --tag $(DOCKER_IMAGE_TAG) .
	New-Item -Force -Name "$@" -ItemType File

.PHONY: $(DOCKER_CONTAINER_NAME)
$(DOCKER_CONTAINER_NAME): $(DOCKER_CONTAINER)

DOCKER_CONTAINER_ID := $(shell if($$$(DOCKERD_UP)){return (docker container ls --quiet --all --filter name="^/$(DOCKER_CONTAINER_NAME)$$")})
DOCKER_CONTAINER_STATE := $(shell if($$$(DOCKERD_UP)){return (docker container ls --format "{{.State}}" --all --filter name="^/$(DOCKER_CONTAINER_NAME)$$")})
DOCKER_CONTAINER_RUN_STATUS := $(shell if("$(DOCKER_CONTAINER_STATE)" -ne "running"){return "$(DOCKER_CONTAINER)_not_running"})
.PHONY: $(DOCKER_CONTAINER)_not_running
$(DOCKER_CONTAINER): $(DOCKER_IMAGE) $(DOCKER_CONTAINER_RUN_STATUS)
ifneq ($(DOCKER_CONTAINER_ID),)
	docker container rename $(DOCKER_CONTAINER_NAME) $(DOCKER_CONTAINER_NAME)_$(DOCKER_CONTAINER_ID)
endif
	docker run --interactive --tty --detach <#\
		#> --name $(DOCKER_CONTAINER_NAME) <#\
		#> --mount type=bind,source="$(CI_BIND_MOUNT)",target=C:\repo <#\
		#> --isolation=$(DOCKER_ISOLATION) <#\
		#> --memory 8G <#\
		#> $(DOCKER_IMAGE_TAG)
	Start-Sleep -Seconds 1
	New-Item -Force -Name "$@" -ItemType File

.PHONY: $(DOCKER_TEST_CONTAINER_NAME)
$(DOCKER_TEST_CONTAINER_NAME): $(DOCKER_TEST_CONTAINER)

DOCKER_TEST_CONTAINER_ID := $(shell if($$$(DOCKERD_UP)){return (docker container ls --quiet --all --filter name="^/$(DOCKER_TEST_CONTAINER_NAME)$$")})
DOCKER_TEST_CONTAINER_STATE := $(shell if($$$(DOCKERD_UP)){return (docker container ls --format "{{.State}}" --all --filter name="^/$(DOCKER_TEST_CONTAINER_NAME)$$")})
DOCKER_TEST_CONTAINER_RUN_STATUS := $(shell if("$(DOCKER_TEST_CONTAINER_STATE)" -ne "running"){return "$(DOCKER_TEST_CONTAINER)_not_running"})
.PHONY: $(DOCKER_TEST_CONTAINER)_not_running
$(DOCKER_TEST_CONTAINER): $(DOCKER_IMAGE) $(DOCKER_TEST_CONTAINER_RUN_STATUS)
ifneq ($(DOCKER_TEST_CONTAINER_ID),)
	docker container rename $(DOCKER_TEST_CONTAINER_NAME) $(DOCKER_TEST_CONTAINER_NAME)_$(DOCKER_TEST_CONTAINER_ID)
endif
	docker run --interactive --tty --detach <#\
		#> --name $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> --mount type=bind,source="$$(Get-Location)",target=C:\repo <#\
		#> --isolation=$(DOCKER_ISOLATION) <#\
		#> --memory 8G <#\
		#> $(DOCKER_IMAGE_TAG)
	Start-Sleep -Seconds 1
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_DIR)/msvc/hello_world: $(DOCKER_TEST_CONTAINER) $(HELLO_WORLD_DEPS)
	docker exec $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> pwsh -Command "<#\
		#>   cmake -B $(BUILD_DIR)\msvc -S $(TESTS_DIR) && <#\
		#>   cmake --build $(BUILD_DIR)\msvc --config Debug && <#\
		#>   .\$(BUILD_DIR)\msvc\Debug\hello_world.exe <#\
		#> " | Select-String "Hello world!" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "hello_world failed!"}
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_DIR)/llvm/hello_world: $(DOCKER_TEST_CONTAINER) $(HELLO_WORLD_DEPS)
	docker exec $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> pwsh -Command "clang --version" | Select-String "14\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "LLVM version check failed!"}
	docker exec $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> pwsh -Command "clang++ --version" | Select-String "14\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "LLVM version check failed!"}
	docker exec $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> pwsh -Command "<#\
		#>   cmake -B $(BUILD_DIR)\llvm -S $(TESTS_DIR) -T ClangCL && <#\
		#>   cmake --build $(BUILD_DIR)\llvm --config Debug && <#\
		#>   .\$(BUILD_DIR)\llvm\Debug\hello_world.exe <#\
		#> " | Select-String "Hello world!" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "hello_world failed!"}
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_DIR)/clang_format_test: $(DOCKER_TEST_CONTAINER)
	docker exec $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> pwsh -Command "clang-format --version" | Select-String "14\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "clang-format version check failed!"}
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_DIR)/lit_test: $(DOCKER_TEST_CONTAINER)
	docker exec $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> pwsh -Command "lit --version" | Select-String "14\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "llvm-lit version check failed!"}
	New-Item -Force -Name "$@" -ItemType File

$(BUILD_DIR)/filecheck_test: $(DOCKER_TEST_CONTAINER)
	docker exec $(DOCKER_TEST_CONTAINER_NAME) <#\
		#> pwsh -Command "FileCheck --version" | Select-String "14\.\d+\.\d+" -Raw -OutVariable ret; <#\
		#> if(!$$ret){throw "llvm-lit version check failed!"}
	New-Item -Force -Name "$@" -ItemType File

.PHONY: check
check: \
	$(BUILD_DIR)/msvc/hello_world \
	$(BUILD_DIR)/llvm/hello_world \
	$(BUILD_DIR)/clang_format_test \
	$(BUILD_DIR)/lit_test \
	$(BUILD_DIR)/filecheck_test \


.PHONY: clean
clean:
	docker container ls --quiet --filter name=$(DOCKER_TEST_CONTAINER_NAME)_ | %{ docker stop $$_ }
	docker container ls --quiet --filter name=$(DOCKER_TEST_CONTAINER_NAME)_ --all | %{ docker rm $$_ }

