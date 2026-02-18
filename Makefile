SRC_DIR := src
TEST_DIR := test

LUA_DIRS := $(SRC_DIR) $(TEST_DIR)

LUALS_VERSION := 3.17.1
LUALS_DIR := bin/lua-language-server
LUALS := $(LUALS_DIR)/bin/lua-language-server
LUALS_URL := https://github.com/LuaLS/lua-language-server/releases/download/$(LUALS_VERSION)/lua-language-server-$(LUALS_VERSION)-linux-x64.tar.gz

.PHONY: help install-tools format format-check typecheck check

help:
	@echo "Usage: make <target>"
	@echo ""
	@echo "  install-tools  Install stylua (via cargo) and lua-language-server"
	@echo "  format         Format Lua files with stylua"
	@echo "  format-check   Check formatting without modifying files"
	@echo "  typecheck      Run lua-language-server type checking"
	@echo "  check          Run format-check and typecheck"

install-tools:
	ec
	@command -v cargo >/dev/null 2>&1 || { echo "cargo is required (install Rust: https://rustup.rs)"; exit 1; }
	cargo install stylua --features lua53
	mkdir -p $(LUALS_DIR)
	curl -fSL $(LUALS_URL) | tar xz -C $(LUALS_DIR)

format:
	stylua $(LUA_DIRS)

format-check:
	stylua --check $(LUA_DIRS)

typecheck:
	$(LUALS) --check .

check: format-check typecheck
