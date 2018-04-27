ifeq ($(TARGET), rhel)
    DOCKERFILE := Dockerfile.rhel
else
    DOCKERFILE := Dockerfile
endif

REGISTRY?=registry.devshift.net
REPOSITORY?=fabric8-analytics/f8a-worker-base
DEFAULT_TAG=latest

.PHONY: all docker-build fast-docker-build test get-image-name get-image-repository

all: fast-docker-build

docker-build:
	docker build --no-cache -t $(REGISTRY)/$(REPOSITORY):$(DEFAULT_TAG) -f $(DOCKERFILE) .

fast-docker-build:
	docker build -t $(REGISTRY)/$(REPOSITORY):$(DEFAULT_TAG) -f $(DOCKERFILE) .

test: fast-docker-build
	./tests/run_integration_tests.sh

get-image-name:
	@echo $(REGISTRY)/$(REPOSITORY):$(DEFAULT_TAG)

get-image-repository:
	@echo $(REPOSITORY)
