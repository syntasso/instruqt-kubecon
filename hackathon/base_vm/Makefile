ts := $(shell /bin/date "+%s")
PROJECT ?= instruqt-kubecon
IMAGE_NAME ?= syntasso-instruqt-hackathon-base-v4
PACKER_LOG ?= "0" # Set to a number 0 to 4 for level of logging
PACKER_FILE ?= packer.json

OS := $(shell uname | tr '[:upper:]' '[:lower:]')
ARCH := $(shell uname -m | sed -e 's/x86_64/amd64/' -e 's/\(arm\)\(64\)\?.*/\1\2/' -e 's/aarch64$$/arm64/')

PACKER = $(shell pwd)/bin/packer
packer:
	@if [ ! -f bin/packer ]; then \
		mkdir -p bin; \
		curl -Lo bin/packer.zip https://releases.hashicorp.com/packer/$$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r .current_version)/packer_$$(curl -s https://checkpoint-api.hashicorp.com/v1/check/packer | jq -r .current_version)_${OS}_${ARCH}.zip; \
		unzip -o bin/packer.zip -d bin; \
		rm bin/packer.zip; \
		$(PACKER) plugins install github.com/hashicorp/googlecompute; \
	fi

build: packer # build base_vm image (if not already exist)
	@if [ -z "${GHCR_BACKSTAGE}" ]; then \
		echo "GHCR_BACKSTAGE is not set. See Readme for details."; \
		exit 1; \
	fi;
	@if ! git diff --quiet origin/main -- . && \
		git diff origin/main -- Makefile | grep -q 'IMAGE_NAME ?='; then \
			echo "Rebuilding a version results in down time."; \
			echo "If downtime for the image is OK, use 'make force-build'."; \
			echo "If not, bump the 'IMAGE_NAME' variable at the top of base_vm/Makefile."; \
			exit 99; \
	fi;
	PACKER_LOG=${PACKER_LOG} $(PACKER) build \
		-var 'project_id=${PROJECT}' \
		-var 'image_name=${IMAGE_NAME}' \
		${PACKER_FILE};

# this deletes before it adds the new image, therefore it could have user impact if the image is already in the wild
force-build: packer
	@if [ -z "${GHCR_BACKSTAGE}" ]; then \
		echo "GHCR_BACKSTAGE is not set. See Readme for details."; \
		exit 1; \
	fi;
	PACKER_LOG=${PACKER_LOG} $(PACKER) build -force \
		-var 'project_id=${PROJECT}' \
		-var 'image_name=${IMAGE_NAME}' \
		${PACKER_FILE};
