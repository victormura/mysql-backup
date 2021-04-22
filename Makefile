DOCKER_REPOSITORY = victormura
IMAGE_NAME = mysql-backup

VERSION = $(shell cat VERSION)
RELEASE_TYPE ?= patch

build:
	@docker build -t ${IMAGE_NAME}:latest .
	@docker tag ${IMAGE_NAME}:latest $(DOCKER_REPOSITORY)/$(IMAGE_NAME):$(VERSION)
	@docker tag $(IMAGE_NAME):latest $(DOCKER_REPOSITORY)/$(IMAGE_NAME):latest

git_version:
	@cat VERSION | ( IFS=".-" ; read a b c d && \
      if [ "$(RELEASE_TYPE)" = "patch" ]; then echo "$$a.$$b.$$((c + 1))" > VERSION; \
      elif [ "$(RELEASE_TYPE)" = "minor" ]; then echo "$$a.$$((b + 1)).0" > VERSION; \
      elif [ "$(RELEASE_TYPE)" = "major" ]; then echo "$$((a + 1)).0.0" > VERSION; fi)
	@git commit VERSION -m "$$(cat VERSION)"
	@git tag "$$(cat VERSION)"

publish: build
	@docker login
	@docker push $(DOCKER_REPOSITORY)/$(IMAGE_NAME):$(VERSION)
	@docker push $(DOCKER_REPOSITORY)/$(IMAGE_NAME):latest

release: git_version publish
	@git push --tags origin master