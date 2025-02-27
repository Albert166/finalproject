DOCKER_USERNAME = albertasm
APPLICATION_NAME = shopping_list
VERSION = $(shell git tag --sort=-v:refname | head -n 1)
DOCKER_IMAGE_NAME = $(DOCKER_USERNAME)/$(APPLICATION_NAME)
DOCKER_CONTAINER_NAME = $(APPLICATION_NAME)


# Build Docker image from Dockerfile with version tag
build:
	docker build -t $(DOCKER_IMAGE_NAME):$(VERSION) -t $(DOCKER_IMAGE_NAME):latest .

# Push Docker image to DockerHub with version tag
push:
	docker push $(DOCKER_IMAGE_NAME):$(VERSION)
	docker push $(DOCKER_IMAGE_NAME):latest

# Build and push in one command
deploy: build push
