SHELL := /bin/bash
CURRENT_PATH = $(shell pwd)
APP_NAME = stackup-bundler

GOARCH := $(or $(GOARCH),$(shell go env GOARCH))
GOOS := $(or $(GOOS),$(shell go env GOOS))

# build with verison infos
BUILD_DATE = $(shell date +%FT%T)
GIT_COMMIT = $(shell git log --pretty=format:'%h' -n 1)
GIT_BRANCH = $(shell git rev-parse --abbrev-ref HEAD)
ifeq ($(version),)
	# not specify version: make install
	APP_VERSION = $(shell git describe --abbrev=0 --tag)
	ifeq ($(APP_VERSION),)
		APP_VERSION = dev
	endif
else
	# specify version: make install version=v0.6.1-dev
	APP_VERSION = $(version)
endif

install-dev:
	go install github.com/cosmtrek/air@v1.49.0
	go mod tidy

generate-environment:
	go run ./scripts/genenv

generate-entrypoint-pkg:
	abigen --abi=./abi/entrypoint.json --pkg=entrypoint --out=./pkg/entrypoint/bindings.go

fetch-wallet:
	go run ./scripts/fetchwallet

dev-private-mode:
	air -c .air.private-mode.toml

dev-searcher-mode:
	air -c .air.searcher-mode.toml

dev-reset-default-data-dir:
	rm -rf ./data

## make build: Go build the project
build:
	go build -o ${APP_NAME}
	go build ./scripts/fetchwallet
	go build ./scripts/genenv
	@printf "Build ${APP_NAME} successfully!\n"

package:build
	tar -czvf ./${APP_NAME}-${APP_VERSION}-${GOARCH}-${GOOS}.tar.gz ./${APP_NAME} ./fetchwallet ./genenv ./start.sh ./stop.sh
	rm ./${APP_NAME} ./fetchwallet ./genenv
