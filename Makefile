PROJECT := tif

BUILD_DIR := build
BIN_DIR   := bin

.PHONY: all clean

clean:
	@echo "==> Cleaning build artifacts"
	@rm -rf $(BUILD_DIR) $(BIN_DIR)
	@echo "==> Clean complete"
