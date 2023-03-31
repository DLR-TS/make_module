# This Makefile contains useful targets that can be included in downstream projects.


$(eval include .env)
$(eval export sed 's/=.*//' .env)

$(error "${pwd}")

PROJECT:=$(shell echo ${project}| tr '[:lower:]' '[:upper:]')

ifeq ($(call if,$(wildcard ${PROJECT}),),)
${PROJECT}:

.EXPORT_ALL_VARIABLES:
MAKEFLAGS += --no-print-directory

${project}_project:=${project}

${project}_makefile_path:=$(shell realpath "$(shell dirname "$(lastword $(MAKEFILE_LIST))")")
ifeq ($(submodules_path),)
    ${project}_submodules_path:=$(shell realpath "${${project}_makefile_path}/..")
else
    ${project}_submodules_path:=$(shell realpath ${SUBMODULES_PATH})
endif

_submodules_path:=${${project}_submodules_path}

make_gadgets_path:=${${project}_submodules_path}/make_gadgets
ifeq ($(wildcard $(make_gadgets_path)/*),)
    $(info INFO: To clone submodules use: 'git submodules update --init --recursive')
    $(info INFO: To specify alternative path for submodules use: SUBMODULES_PATH="<path to submodules>" make build')
    $(info INFO: Default submodule path is: ${${project}_makefile_path}')
    $(error "ERROR: ${make_gadgets_path} does not exist. Did you clone the submodules?")
endif

REPO_DIRECTORY:=${${project}_makefile_path}
${project}_tag:=$(shell cd ${make_gadgets_path} && make get_sanitized_branch_name REPO_DIRECTORY=${REPO_DIRECTORY})
${project}_image:=${${project}_project}:${${project}_tag}

${project}_CMAKE_BUILD_PATH:="${${project}_project}/build"
${project}_CMAKE_INSTALL_PATH:="${${project}_CMAKE_BUILD_PATH}/install"

define project_RULE
	$(eval TARGET_PREFIX := clean) 
	$(eval TARGET := $@)
    project := $(shell echo ${TARGET} | sed 's|${TARGET_PREFIX}_||g')
endef

.PHONY: build_${project} 
build_${project}: ## Build ${project} 
	@$(eval $(project_RULE))
	cd "${${project}_makefile_path}" && make build

.PHONY: clean_${project}
clean_${project}: $(eval $(project_RULE))## Clean ${project} build artifacts
	@$(eval $(project_RULE))
	cd "${${project}_makefile_path}" && make clean

.PHONY: branch_${project}
branch_${project}: ## Returns the current docker safe/sanitized branch for ${project} 
	@$(eval $(project_RULE))
	@printf "%s\n" ${${project}_tag}

.PHONY: image_${project}
image_${project}: ## Returns the current docker image name for ${project}
	@$(eval $(project_RULE))
	@printf "%s\n" ${${project}_image}

include ${make_gadgets_path}/make_gadgets.mk
include ${make_gadgets_path}/docker/docker-tools.mk

endif
