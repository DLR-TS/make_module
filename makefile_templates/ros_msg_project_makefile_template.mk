
SHELL:=/bin/bash

.DEFAULT_GOAL := all

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

include include.mk

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

.PHONY: all
all: help 

.PHONY: set_env 
set_env:
	$(eval tag := ${${project}_tag})

.PHONY: build 
build: set_env root_check docker_group_check clean ## Build module 
	docker build --network host \
                 --tag ${project}:${tag} \
                 --build-arg project=${project} .
	docker cp $$(docker create --rm ${project}:${tag}):/tmp/${project}/${project}/build "${ROOT_DIR}/${project}"

.PHONY: build_submodules
build_submodules:
	$(call call_targets,submodules_path=${${project}_submodules_path},target=build,submodules=${submodules})

.PHONY: clean_submodules
clean_submodules:
	$(call call_targets,submodules_path=${${project}_submodules_path},target=clean,submodules=${submodules})

.PHONY: clean
clean: set_env root_check docker_group_check clean_submodules ## Clean module 
	rm -rf "${ROOT_DIR}/${project}/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${project}:${tag}") --force 2> /dev/null || true
	docker rmi $$(docker images -q ${project}:${tag}) --force 2> /dev/null || true


