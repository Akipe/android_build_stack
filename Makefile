.PHONY: build run stop shell build-abootimg build-simg2img help
.DEFAULT_GOAL= help

init: git-install-submodule build-docker-image
	mkdir ./bin

update: git-update-submodule build-docker-image

build: build-docker-image

run:
	sudo docker run --name docker_android_builder -v ${BUILD_PATH}:/android -d docker_android_builder

stop:
	sudo docker stop --name docker_android_builder

shell: 
	sudo docker exec -it docker_android_builder bash

git-install-submodule:
	git submodule update --init

git-update-submodule:
	git submodule update --remote

build-docker-image:
	sudo docker build -t docker_android_builder -f ./docker/archlinux/Dockerfile .

# build-abootimg: git-install-submodule
# 	cd utils/abootimg && $(MAKE)

help: ## Show all commands and informations about it
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)