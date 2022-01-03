# Auto generated binary variables helper managed by https://github.com/bwplotka/bingo v0.5.2. DO NOT EDIT.
# All tools are designed to be build inside $GOBIN.
BINGO_DIR := $(dir $(lastword $(MAKEFILE_LIST)))
GOPATH ?= $(shell go env GOPATH)
GOBIN  ?= $(firstword $(subst :, ,${GOPATH}))/bin
GO     ?= $(shell which go)

# Below generated variables ensure that every time a tool under each variable is invoked, the correct version
# will be used; reinstalling only if needed.
# For example for faillint variable:
#
# In your main Makefile (for non array binaries):
#
#include .bingo/Variables.mk # Assuming -dir was set to .bingo .
#
#command: $(FAILLINT)
#	@echo "Running faillint"
#	@$(FAILLINT) <flags/args..>
#
FAILLINT := $(GOBIN)/faillint-v1.7.0
$(FAILLINT): $(BINGO_DIR)/faillint.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/faillint-v1.7.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=faillint.mod -o=$(GOBIN)/faillint-v1.7.0 "github.com/fatih/faillint"

GOIMPORTS := $(GOBIN)/goimports-v0.1.7
$(GOIMPORTS): $(BINGO_DIR)/goimports.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/goimports-v0.1.7"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=goimports.mod -o=$(GOBIN)/goimports-v0.1.7 "golang.org/x/tools/cmd/goimports"

GOJSONTOYAML := $(GOBIN)/gojsontoyaml-v0.0.0-20200602132005-3697ded27e8c
$(GOJSONTOYAML): $(BINGO_DIR)/gojsontoyaml.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/gojsontoyaml-v0.0.0-20200602132005-3697ded27e8c"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=gojsontoyaml.mod -o=$(GOBIN)/gojsontoyaml-v0.0.0-20200602132005-3697ded27e8c "github.com/brancz/gojsontoyaml"

GOLANGCI_LINT := $(GOBIN)/golangci-lint-v1.42.1
$(GOLANGCI_LINT): $(BINGO_DIR)/golangci-lint.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/golangci-lint-v1.42.1"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=golangci-lint.mod -o=$(GOBIN)/golangci-lint-v1.42.1 "github.com/golangci/golangci-lint/cmd/golangci-lint"

JSONNET_LINT := $(GOBIN)/jsonnet-lint-v0.17.0
$(JSONNET_LINT): $(BINGO_DIR)/jsonnet-lint.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/jsonnet-lint-v0.17.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=jsonnet-lint.mod -o=$(GOBIN)/jsonnet-lint-v0.17.0 "github.com/google/go-jsonnet/cmd/jsonnet-lint"

JSONNET := $(GOBIN)/jsonnet-v0.17.0
$(JSONNET): $(BINGO_DIR)/jsonnet.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/jsonnet-v0.17.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=jsonnet.mod -o=$(GOBIN)/jsonnet-v0.17.0 "github.com/google/go-jsonnet/cmd/jsonnet"

JSONNETFMT := $(GOBIN)/jsonnetfmt-v0.17.0
$(JSONNETFMT): $(BINGO_DIR)/jsonnetfmt.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/jsonnetfmt-v0.17.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=jsonnetfmt.mod -o=$(GOBIN)/jsonnetfmt-v0.17.0 "github.com/google/go-jsonnet/cmd/jsonnetfmt"

MDOX := $(GOBIN)/mdox-v0.9.0
$(MDOX): $(BINGO_DIR)/mdox.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/mdox-v0.9.0"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=mdox.mod -o=$(GOBIN)/mdox-v0.9.0 "github.com/bwplotka/mdox"

MISSPELL := $(GOBIN)/misspell-v0.3.4
$(MISSPELL): $(BINGO_DIR)/misspell.mod
	@# Install binary/ries using Go 1.14+ build command. This is using bwplotka/bingo-controlled, separate go module with pinned dependencies.
	@echo "(re)installing $(GOBIN)/misspell-v0.3.4"
	@cd $(BINGO_DIR) && $(GO) build -mod=mod -modfile=misspell.mod -o=$(GOBIN)/misspell-v0.3.4 "github.com/client9/misspell/cmd/misspell"

