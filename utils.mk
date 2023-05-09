
define init_module 
    $(eval mkfile_path := $(abspath $(filter %/utils.mk,$(MAKEFILE_LIST))))
    $(eval mkfile_dir := $(dir $(mkfile_path)))
    $(shell cat ${mkfile_dir}/make_module.mk > .${project}.mk 2> /dev/null || true)
endef

define load_environment 
    $(eval include .env)
    $(eval export sed 's/=.*//' .env)
endef

define include_submodules
  $(foreach submodule,$(1), \
    $(eval include $(2)/$(submodule)/include.mk) \
  )
endef

define call_targets
  @for submodule in $(submodules); do \
    cd "${submodules_path}/$${submodule}" && $(MAKE) $(target); \
  done
endef

define init
    $(load_environment)
    $(init_module)
endef

define get_docker_submodule_tags 
    $(foreach submodule,$1,--build-arg $(submodule)_tag=${${submodule}_tag} )
endef
