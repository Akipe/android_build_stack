.PHONY: build run start stop shell build-abootimg build-simg2img help
.DEFAULT_GOAL= help

init: git-install-submodule build-docker-image
	mkdir ./bin

update: docker-image-rm docker-image-update #git-update-submodule

build: docker-image-build

init-start: docker-container-init-start

start: docker-container-start

shell: docker-container-shell

stop: docker-container-stop

rm: docker-container-rm


docker-container-init-start:
	docker run \
		--name docker_android_builder_${OS}_${RELEASE} \
		-v ${BUILD_PATH}:/android \
		-d docker_android_builder_${OS}_${RELEASE}

docker-container-start:
	docker start docker_android_builder_${OS}_${RELEASE}

docker-container-shell:
	docker exec -it docker_android_builder_${OS}_${RELEASE} bash

docker-container-stop:
	docker container stop docker_android_builder_${OS}_${RELEASE}

docker-container-rm:
	docker container rm -f docker_android_builder_${OS}_${RELEASE}

docker-image-update: docker-container-rm docker-image-build

docker-image-rm:
	docker image rm docker_android_builder_${OS}_${RELEASE}

docker-image-build:
	docker build \
		-t docker_android_builder_${OS}_${RELEASE} \
		-f ./docker/${OS}/${RELEASE}/Dockerfile .


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
