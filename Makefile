### repo name
REPO_PATH := "github.com/abyss414/house"

### go path
GOPATHVAR=${GOPATH}

### bash
SHELL=/usr/bin/env bash
%.c: %.y
%.c: %.l

### version,branch,commit,date,changes,
VERSION := ""

PACK_SRV := ""


VERSIONCMD = "`git describe --exact-match --tags $(git log -n1 --pretty='%h')`"
VERSION := $(shell echo $(VERSIONCMD))
ifeq ($(strip $(VERSION)),)
  BRANCHCMD := "`git describe --contains --all HEAD`-`git rev-parse HEAD`"
  VERSION = $(shell echo $(BRANCHCMD))
else
  TAGCMD := "`git describe --exact-match --tags $(git log -n1 --pretty='%h')`-`git rev-parse HEAD`"
  VERSION =  $(shell echo $(TAGCMD))
endif
VERSION ?= $(VERSION)

BRANCHCMD := "`git describe --contains --all HEAD`"
BRANCH := $(shell echo $(BRANCHCMD))
BRANCH  ?= $(BRANCH)
COMMITCMD = "`git rev-parse HEAD`"
COMMIT := $(shell echo $(COMMITCMD))
DATE := $(shell echo `date +%FT%T%z`)
CHANGES := $(shell echo `git status --porcelain | wc -l`)
ifneq ($(strip $(CHANGES)), 0)
       VERSION := dirty-build-$(VERSION)
       COMMIT := dirty-build-$(COMMIT)
endif

REMOVESYMBOL := -w -s
ifeq (true, $(DEBUG))
       REMOVESYMBOL =
       GCFLAGS=-gcflags=all="-N -l "
endif

### CLDFLAGS,LDFLAG define
ifdef IS_LINUX
       CLDFLAGS += -L/usr/local/yay/lib
else ifdef IS_MAC_OS_X
       CLDFLAGS += -L /usr/local/lib/gcc/4.9 -L/usr/local/lib
endif


### build dir
BUILD_DIR := $(CURDIR)/build
PACKAGE_DIR := $(CURDIR)/package
BUILD := $(BUILD_DIR)/built
PROJECT_DIR = $(CURDIR)
BUILD_TAGS += gm no_development

export GOBIN := $(BUILD_DIR)/bin

### build step
default: all

pre-build:

clean: build-clean

build-clean:
	@echo NOTE: clean
	rm -rf $(BUILD_DIR) || true && \
	rm -rf $(PACKAGE_DIR) || true

vet:
	go vet ./...


all: clean test build

build-dirs:
	@for dir in $(BUILD_DIR)/{bin,lib,app}; do \
		 test -d $$dir || mkdir -p $$dir; \
	done

debug:
	@echo $(BINARY_NAME)
	@echo $(REPO_PATH)
	@echo $(GOPATHVAR)
	@echo $(VERSION)
	@echo $(BRANCH)
	@echo $(COMMIT)
	@echo $(DATE)
	@echo $(GCFLAGS)
	@echo $(BUILD_DIR)
	@echo $(PACK_SRV)
	@echo $(OS)

proto:
	protoc --proto_path=. --go_out=plugins=grpc:. proto/**/*.proto

.PHONY: all build clean test install pre-build dist  dist-tar build-dirs proto pack

build:
	@make pre-build
	@make build-dirs
	CGO_ENABLED=0 GOOS=linux go build -a -ldflags '-extldflags "-static"' -o $(BUILD_DIR)/bin/main  $(REPO_PATH)/cmd/$(PACK_SRV)
	touch $(BUILD)
	@echo -e "\033[32mbuild $(BINARY_NAME) successfully\033[0m"

pack:
	@make build
	@make pack-srv

pack-srv:
	@for dir in $(PACKAGE_DIR)/$(PACK_SRV)/{bin,config}; do \
	test -d $${dir} || mkdir -p $${dir}; \
	done

	command cp -rf $(BUILD_DIR)/bin/main $(PACKAGE_DIR)/$(PACK_SRV)/bin/
	command cp -r $(PROJECT_DIR)/install.sh $(PACKAGE_DIR)/
	command sed -i "s/{SRV_NAME}/$(PACK_SRV)/g" $(PACKAGE_DIR)/install.sh

	cd $(PACKAGE_DIR)/$(PACK_SRV) && \
	tar -czvf $(PACK_SRV).tar.gz * && \
	mv $(PACK_SRV).tar.gz ../

	@echo -e "\033[32mpack $(PACK_SRV) successfully\033[0m"


