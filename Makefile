BUILD_VERSION ?= "0.1"
BUILD_DATE ?= "$(shell date -u +"%Y-%m-%d")"
# Local image by default
IMAGE ?= docker.io/newrelic/s3-pit-restore
.PHONY:
build:
	docker build -t newrelic/s3-pit-restore \
	--build-arg VERSION=$(BUILD_VERSION) \
	--build-arg BUILD_DATE=$(BUILD_DATE) \
	--build-arg VCS_REF="$(shell git rev-parse HEAD)" \
	.

.PHONY:
restore: restore-in-folder replace-original
	@echo "Restored $(BUCKET)/$(PREFIX) for date $(TIME)"
	@echo "Backup created at $(BUCKET)/$(PREFIX).original"

AWS_FOLDER ?= "$(HOME)/.aws"
.PHONY:
restore-in-folder: validate-input validate-no-previous-restored
	@echo "Restoring original folder at $(TIME) into '.restored' copy..."
	docker run -ti --rm --name=s3-pit-restore \
	-e AWS_PROFILE \
	-v $(AWS_FOLDER):/root/.aws \
	$(IMAGE) \
	-b $(BUCKET) -p $(PREFIX) -B $(BUCKET) -P $(PREFIX).restored -t "$(TIME)"

.PHONY:
replace-original: validate-input validate-no-previous-original
	@echo "Replacing original folder with restored one..."
	aws s3 mv --recursive s3://$(BUCKET)/$(PREFIX) s3://$(BUCKET)/$(PREFIX).original
	aws s3 mv --recursive s3://$(BUCKET)/$(PREFIX).restored/$(PREFIX) s3://$(BUCKET)/$(PREFIX)

.PHONY:
validate-no-previous-restored: validate-input
	@echo "Validating there's no previous restored folder copy..."
	$(shell aws s3 ls s3://$(BUCKET)/$(PREFIX).restored && \
	(echo "error: $(BUCKET)/$(PREFIX).restored exists! delete or rename it first"; exit 2))

.PHONY:
validate-no-previous-original: validate-input
	@echo "Validating there's no previous original folder copy..."
	$(shell aws s3 ls s3://$(BUCKET)/$(PREFIX).original && \
  	(echo "error: $(BUCKET)/$(PREFIX).original exists! delete or rename it first"; exit 2))

.PHONY:
validate-input:
ifndef TIME
	$(error TIME is undefined expected format "01-25-2018 10:59:50 +2")
endif
ifndef BUCKET
	$(error BUCKET is undefined)
endif
ifndef PREFIX
	$(error PREFIX is undefined)
endif
ifndef AWS_PROFILE
	$(error AWS_PROFILE is undefined)
endif
