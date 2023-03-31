
SHELL:=/bin/bash

.DEFAULT_GOAL := all

ROOT_DIR:=$(shell dirname "$(realpath $(firstword $(MAKEFILE_LIST)))")

include adore_if_ros_scheduling_msg.mk

MAKEFLAGS += --no-print-directory

.EXPORT_ALL_VARIABLES:
DOCKER_BUILDKIT?=1
DOCKER_CONFIG?=

.PHONY: all
all: help 

.PHONY: set_env 
set_env: 
	$(eval project := ${adore_if_ros_scheduling_msg_project}) 
	$(eval tag := ${adore_if_ros_scheduling_msg_tag})

.PHONY: build 
build: root_check docker_group_check clean set_env ## Build adore_if_ros_scheduling_msg 
	docker build --network host \
                 --tag ${project}:${tag} \
                 --build-arg PROJECT=${project} .
	docker cp $$(docker create --rm ${project}:${tag}):/tmp/${project}/${project}/build "${ROOT_DIR}/${project}"

.PHONY: clean
clean: root_check docker_group_check set_env ## Clean adore_if_ros_scheduling_msg build artifacts 
	rm -rf "${ROOT_DIR}/${project}/build"
	docker rm $$(docker ps -a -q --filter "ancestor=${project}:${tag}") --force 2> /dev/null || true
	docker rmi $$(docker images -q ${project}:${tag}) --force 2> /dev/null || true
