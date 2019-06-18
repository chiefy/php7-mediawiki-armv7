include .env

DOCKER_IMAGE=php7-mediawiki-armv7
MW_VERSION=1.32.1
PROJECT_NAME=mediawiki

.PHONY: build
build:
	@docker build -t $(DOCKER_IMAGE):$(MW_VERSION) .

.PHONY: up
up: ./etc/nginx/.htpasswd .env
	@docker-compose -p $(PROJECT_NAME) up -d

.PHONY: stop
stop:
	@docker-compose -p $(PROJECT_NAME) stop; docker-compose -p $(PROJECT_NAME) rm -fv

./etc/nginx/.htpasswd:
	@echo "$(MW_SITE_BASIC_AUTH_USER):$(shell echo $(MW_SITE_BASIC_AUTH_PASS) | openssl passwd -stdin -noverify)" > $@
