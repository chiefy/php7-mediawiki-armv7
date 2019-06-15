
DOCKER_IMAGE=php7-mediawiki-armv7
MW_VERSION=1.32.1

.PHONY: build
build:
	@docker build -t $(DOCKER_IMAGE):$(MW_VERSION) .
