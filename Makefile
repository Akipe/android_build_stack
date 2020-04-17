.PHONY: build run start stop shell build-abootimg build-simg2img help
.DEFAULT_GOAL= help

init: git-install-submodule build-docker-image_ubuntu
	mkdir ./bin

update: git-update-submodule build-docker-image_ubuntu

build: docker-build-image_ubuntu

run:
	sudo docker run --name docker_android_builder_ubuntu -v ${BUILD_PATH}:/android -d docker_android_builder_ubuntu

start:
	sudo docker start docker_android_builder_ubuntu

stop: docker-stop docker-rm

shell: 
	sudo docker exec -it docker_android_builder_ubuntu bash

docker-stop:
	sudo docker container stop docker_android_builder_ubuntu

docker-rm:
	sudo docker container rm -f docker_android_builder_ubuntu

docker-build-image_archlinux:
	sudo docker build -t docker_android_builder -f ./docker/archlinux/Dockerfile .

docker-build-image_ubuntu:
	sudo docker build -t docker_android_builder_ubuntu -f ./docker/ubuntu/Dockerfile .


git-install-submodule:
	git submodule update --init

git-update-submodule:
	git submodule update --remote


# build-abootimg: git-install-submodule
# 	cd utils/abootimg && $(MAKE)

build-android_blob_utility:
	cd utils/android_blob_utility && $(MAKE)
	cd bin/ && ln -s -f ../utils/android_blob_utility/android-blob-utility ./

help: ## Show all commands and informations about it
	@awk 'BEGIN {FS = ":.*##"; printf "\nUsage:\n  make \033[36m<target>\033[0m\n\nTargets:\n"} /^[a-zA-Z_-]+:.*?##/ { printf "  \033[36m%-10s\033[0m %s\n", $$1, $$2 }' $(MAKEFILE_LIST)