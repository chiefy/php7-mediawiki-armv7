include .env

DOCKER_IMAGE=php7-mediawiki-armv7
MW_VERSION=1.32.1

.PHONY: build
build:
	@docker build -t $(DOCKER_IMAGE):$(MW_VERSION) .


./etc/nginx/.htpasswd:
	@echo "$(MW_SITE_BASIC_AUTH_USER):$(shell echo $(MW_SITE_BASIC_AUTH_PASS) | openssl passwd -stdin -noverify)" > $@