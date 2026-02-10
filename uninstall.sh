#!/bin/sh
set -e

PROJECT="tif"
PREFIX="/usr/local"

BIN_PATH="$PREFIX/bin/$PROJECT"
LIB_PATH="$PREFIX/lib/$PROJECT"

echo "==> Uninstalling $PROJECT"

if [ "$(id -u)" -ne 0 ]; then
    echo "error: please run as root (use sudo)"
    exit 1
fi

if [ -f "$BIN_PATH" ]; then
    echo "==> Removing binary: $BIN_PATH"
    rm -f "$BIN_PATH"
else
    echo "==> Binary not found"
fi

if [ -d "$LIB_PATH" ]; then
    echo "==> Removing library directory: $LIB_PATH"
    rm -rf "$LIB_PATH"
else
    echo "==> Library directory not found"
fi

echo "==> $PROJECT successfully removed"
