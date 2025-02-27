VERSION = $(shell git tag --sort=-v:refname | head -n 1)


# Build Docker image from Dockerfile with version tag
build:
	docker build -t albertasm/shopping_list:$(VERSION) -t albertasm/shopping_list:latest .

# Push Docker image to DockerHub with version tag
push:
	docker push albertasm/shopping_list:$(VERSION)
	docker push albertasm/shopping_list:latest

# Build and push in one command
deploy: build push
