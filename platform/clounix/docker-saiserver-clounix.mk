# docker image for clounix saiserver

DOCKER_SAISERVER_CLOUNIX_STEM = docker-saiserver-clounix
DOCKER_SAISERVER_CLOUNIX = $(DOCKER_SAISERVER_CLOUNIX_STEM).gz
$(DOCKER_SAISERVER_CLOUNIX)_PATH = $(PLATFORM_PATH)/docker-saiserver-clounix
$(DOCKER_SAISERVER_CLOUNIX)_DEPENDS += $(SAISERVER) $(CLOUNIX_SAI_DEV)
$(DOCKER_SAISERVER_CLOUNIX)_FILES += $(DSSERVE)
$(DOCKER_SAISERVER_CLOUNIX)_LOAD_DOCKERS += $(DOCKER_CONFIG_ENGINE_BUSTER)
$(DOCKER_SAISERVER_CLOUNIX)_DBG_IMAGE_PACKAGES = $($(DOCKER_CONFIG_ENGINE_BUSTER)_DBG_IMAGE_PACKAGES)


SONIC_DOCKER_IMAGES += $(DOCKER_SAISERVER_CLOUNIX)
DOCKER_SAISERVER_CLOUNIX_DBG = $(DOCKER_SAISERVER_CLOUNIX_STEM)-$(DBG_IMAGE_MARK).gz
SONIC_DOCKER_DBG_IMAGES += $(DOCKER_SAISERVER_CLOUNIX_DBG)

$(DOCKER_SAISERVER_CLOUNIX)_CONTAINER_NAME = saiserver
$(DOCKER_SAISERVER_CLOUNIX)_BASE_IMAGE_FILES += clx_ipython:/usr/bin/clx_ipython
$(DOCKER_SAISERVER_CLOUNIX)_RUN_OPT += --net=host --privileged -t
$(DOCKER_SAISERVER_CLOUNIX)_RUN_OPT += -v /host/machine.conf:/etc/machine.conf
$(DOCKER_SAISERVER_CLOUNIX)_RUN_OPT += -v /var/run/docker-saiserver:/var/run/sswsyncd
$(DOCKER_SAISERVER_CLOUNIX)_RUN_OPT += -v /etc/sonic:/etc/sonic:ro
$(DOCKER_SAISERVER_CLOUNIX)_RUN_OPT += -v /host/warmboot:/var/warmboot