GIT_VERSION:=$(shell git describe --dirty --always)

PROJECT:=kf-infra-gitops

IMAGE:=gcr.io/$(PROJECT)/calendar-sync:$(GIT_VERSION)

# Echo commands
SHELL = sh -xv

LATESTIMAGES=latest_image.yaml

build-submit:
	gcloud --project=$(PROJECT) builds submit --tag=$(IMAGE) ./

build-output:
	yq w -i latest_image.yaml $(PROJECT).calendar.image \
	  $(IMAGE)@$(shell gcloud container images describe $(IMAGE) | yq r - image_summary.digest)

set-image:
	cd  manifests && kustomize edit set image calendar=$(shell yq r $(LATESTIMAGES) $(PROJECT).calendar.image)

update-image: build-submit build-output set-image


deploy:
	kustomize build manifests | kubectl --context=$(CONTEXT) apply -f -

# Build the image using GCB
# We can't use skaffold due to: https://github.com/GoogleContainerTools/skaffold/issues/3468
build: build-submit build-output
