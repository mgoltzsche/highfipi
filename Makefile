BIN_DIR := ./bin
PACKER = $(BIN_DIR)/packer
PACKER_VERSION = v1.7.4
PACKER_BUILDER_ARM_IMAGE = $(BIN_DIR)/packer-builder-arm-image
PACKER_BUILDER_ARM_IMAGE_VERSION = 920cc8d3c01eb3f3a3889ec63441924de963b858

IMAGES := $(shell ls images)
BUILD_TARGETS = $(addprefix build-,$(IMAGES))

build: $(BUILD_TARGETS)

$(BUILD_TARGETS): build-%: $(PACKER) $(PACKER_BUILDER_ARM_IMAGE)
	$(PACKER) build ./images/$*/packer.json

docker-build: $(addprefix docker-build-,$(IMAGES))

$(addprefix docker-build-,$(IMAGES)): docker-build-%:
	# This may fail every now and then due to asynchronously populated loopback devices within the container.
	# You have to retry in that case or use binaries on the host.
	docker run --rm --privileged \
		--mount type=bind,src=$(HOME)/.ssh/id_rsa.pub,dst=/root/.ssh/id_rsa.pub \
		-v $(PROJECT_DIR):/build:ro \
		-v $(PROJECT_DIR)/packer_cache:/build/packer_cache \
		-v $(PROJECT_DIR)/output-arm-image:/build/output-arm-image \
		quay.io/solo-io/packer-builder-arm-image:v0.1.6 build images/$*/packer.json

clean:
	rm -rf $(BIN_DIR)
	rm -rf ./output-arm-image

clean-all: clean
	rm -rf ./packer_cache

$(PACKER):
	$(call go-get-tool,$(PACKER),github.com/hashicorp/packer@$(PACKER_VERSION))

$(PACKER_BUILDER_ARM_IMAGE):
	$(call go-get-tool,$(PACKER_BUILDER_ARM_IMAGE),github.com/solo-io/packer-builder-arm-image@$(PACKER_BUILDER_ARM_IMAGE_VERSION))

# go-get-tool will 'go get' any package $2 and install it to $1.
PROJECT_DIR := $(shell dirname $(abspath $(lastword $(MAKEFILE_LIST))))
define go-get-tool
@[ -f $(1) ] || { \
set -e ;\
TMP_DIR=$$(mktemp -d) ;\
cd $$TMP_DIR ;\
go mod init tmp ;\
echo "Downloading $(2)" ;\
GOBIN=$(PROJECT_DIR)/$(BIN_DIR) go get $(2) ;\
rm -rf $$TMP_DIR ;\
}
endef
