#!/usr/bin/env bash

set -e

INSTALL_DIR="/usr/local/tif"
BIN_DIR="/usr/local/bin"

echo "Installing tif language..."

sudo mkdir -p "$INSTALL_DIR"
sudo cp -r src "$INSTALL_DIR/"
sudo cp bin/tif "$BIN_DIR/"

sudo chmod +x "$BIN_DIR/tif"

echo "Installed!"
echo "Run with: tif yourfile.tifx"
