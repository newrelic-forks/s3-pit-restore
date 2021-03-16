BUILD_VERSION ?= "0.1"
BUILD_DATE ?= "$(shell date -u +"%Y-%m-%d")"
.PHONY:
docker-build:
	docker build -t newrelic/s3-pit-restore \
	--build-arg VERSION=$(BUILD_VERSION) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VCS_REF="$(shell git rev-parse HEAD)" \
	.

AWS_FOLDER ?= "$(HOME)/.aws"
AWS_REGION ?= "us-east-1"
AWS_S3_BUCKET_NAME ?= "nr-downloads-ohai-testing"
.PHONY:
docker-run: clean validate-input
	docker run -ti --rm --name=s3-pit-restore \
	-e AWS_PROFILE \
	-v $(AWS_FOLDER):/root/.aws \
	docker.io/newrelic/s3-pit-restore \
	-b $(BUCKET) -p $(PREFIX) -B $(BUCKET) -P $(DEST_PREFIX) -t "$(TIME)"

.PHONY:
clean:
	rm -rf restore/*

.PHONY:
validate-input:
# restore inputs
ifndef TIME
	$(error TIME is undefined expected format "01-25-2018 10:59:50 +2")
endif
ifndef BUCKET
	$(error BUCKET is undefined)
endif
ifndef PREFIX
	$(error PREFIX is undefined)
endif
ifndef DEST_PREFIX
	$(error DEST_PREFIX is undefined)
endif
ifndef AWS_PROFILE
	$(error AWS_PROFILE is undefined)
endif
