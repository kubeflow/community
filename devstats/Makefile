# Copyright 2017 The Kubernetes Authors.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Requirements:
#   https://github.com/mattrobenolt/jinja2-cli
#   pip install jinja2-clie
# Update the Airflow deployment

IMG = gcr.io/kubeflow-ci/devstats

TAG := $(shell date +v%Y%m%d)-$(shell git describe --tags --always --dirty)-$(shell git diff | sha256sum | cut -c -6)
DIR := ${CURDIR}

update: push
	kubectl apply -f ghdb_postgres.yaml

push: build
	gcloud docker -- push $(IMG):latest
	gcloud docker -- push $(IMG):$(TAG)

# To build without the cache set the environment variable
# export DOCKER_BUILD_OPTS=--no-cache
build:
	docker build ${DOCKER_BUILD_OPTS} -f Dockerfile.devstats -t $(IMG):$(TAG) .
	docker tag $(IMG):$(TAG) $(IMG):latest
	@echo Built $(IMG):$(TAG) and tagged with latest

# Start the postgre container locally for debugging
# 
# TODO(jlewi): Not sure this is all that useful. Ideally we should just make
# this a ksonnet app and run locally on minikube.
run_postgre:
	-docker rm -f postgres
	docker run -d --name=postgres -p 5432:5432 -e POSTGRES_USER=gha_admin -e POSTGRES_PASSWORD=password -e POSTGRES_DB=gha  postgres:10.1-alpine
