# Developer entry points. CI runs these same targets.
CONFIGURATION ?= Debug
ARCH ?= $(shell uname -m)
DERIVED_DATA := .build/xcode
APP := $(DERIVED_DATA)/Build/Products/$(CONFIGURATION)/NotchWorkspace.app
SWIFT_SOURCES := App Sources Tests Package.swift
# The commit a build comes from, with "+" when the checkout has uncommitted changes (shown in the menu).
COMMIT := $(shell git rev-parse --short HEAD 2>/dev/null)$(shell git diff --quiet HEAD -- 2>/dev/null || echo +)
# Build ad hoc by default. Pass SIGNING_IDENTITY explicitly to use a development certificate.
SIGNING_IDENTITY ?=
# Manual style on every target, including SwiftPM's resource bundles, so none of them asks for a team.
SIGNING = $(if $(SIGNING_IDENTITY),CODE_SIGN_STYLE=Manual CODE_SIGN_IDENTITY='$(SIGNING_IDENTITY)')
# More build settings for xcodebuild, such as CI's ONLY_ACTIVE_ARCH=YES to compile one architecture.
XCODEBUILD_ARGS ?=

.PHONY: setup project build run test lint format licenses secrets check-isolation check clean

setup: ## Install developer tools (Brewfile)
	brew bundle

project: ## Generate NotchWorkspace.xcodeproj from project.yml
	xcodegen generate --quiet

build: project ## Build the app; CONFIGURATION=Debug|Release
	xcodebuild -project NotchWorkspace.xcodeproj -scheme NotchWorkspace -configuration $(CONFIGURATION) \
		-destination 'platform=macOS,arch=$(ARCH)' -derivedDataPath $(DERIVED_DATA) \
		NOTCH_WORKSPACE_COMMIT='$(COMMIT)' $(SIGNING) $(XCODEBUILD_ARGS) -quiet build

run: build ## Open the local build
	open "$(APP)"

test: ## Run unit and performance tests (warnings are errors in OpenNotch's own targets: Package.swift)
	swift test

lint: ## Fail on formatting drift (config: .swift-format)
	swift format lint --strict --recursive $(SWIFT_SOURCES)

format: ## Apply formatting in place
	swift format --in-place --recursive $(SWIFT_SOURCES)

licenses: ## SPDX headers and third-party notices
	scripts/check-licenses.sh

secrets: ## No keys, certificates, profiles, or credentials files in git
	scripts/check-secrets.sh

check-isolation: build ## Check the isolated app bundle
	scripts/check-isolation.sh "$(APP)"

check: secrets lint test licenses check-isolation

clean:
	rm -rf .build NotchWorkspace.xcodeproj
