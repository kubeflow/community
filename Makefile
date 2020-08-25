IMAGE_NAME=golang:1.14
export GO111MODULE=on
export GOPROXY?=https://proxy.golang.org

default: \
	generate \

reset-docs:
	git checkout HEAD -- ./wgs/wgs.yaml ./wg-*/README.md

generate:
	go run ./generator/app.go

test:
	go test -v ./generator/...

.PHONY: default reset-docs generate verify test
