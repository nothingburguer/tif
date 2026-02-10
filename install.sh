#!/bin/sh
set -e

PROJECT="tif"
LUA_VERSION="5.4"

PREFIX="/usr/local"
BIN_DIR="$PREFIX/bin"
LIB_DIR="$PREFIX/lib/$PROJECT"

SRC_DIR="src"
BUILD_DIR="build"
BIN_NAME="tif"

echo "==> Installing $PROJECT"

if [ "$(id -u)" -ne 0 ]; then
    echo "error: please run as root (use sudo)"
    exit 1
fi

command -v gcc >/dev/null 2>&1 || {
    echo "error: gcc not found"
    exit 1
}

command -v lua >/dev/null 2>&1 || {
    echo "error: lua not found"
    exit 1
}

command -v luac >/dev/null 2>&1 || {
    echo "error: luac not found"
    exit 1
}

pkg-config --exists lua$LUA_VERSION || {
    echo "error: lua$LUA_VERSION development files not found"
    echo "hint: install liblua$LUA_VERSION-dev"
    exit 1
}

echo "==> Compiling Lua sources"

mkdir -p "$BUILD_DIR"

for file in "$SRC_DIR"/*.lua; do
    name=$(basename "$file" .lua)
    echo "   luac $name.lua"
    luac -o "$BUILD_DIR/$name.luac" "$file"
done

echo "==> Building executable"

mkdir -p bin

gcc clua_exec.c \
    -o bin/$BIN_NAME \
    $(pkg-config --cflags --libs lua$LUA_VERSION)

echo "==> Installing binary to $BIN_DIR"
install -Dm755 bin/$BIN_NAME "$BIN_DIR/$BIN_NAME"

echo "==> Installing bytecode to $LIB_DIR"
mkdir -p "$LIB_DIR"
install -Dm644 "$BUILD_DIR"/*.luac "$LIB_DIR/"

echo "==> Installation complete"
echo "   Run with: $BIN_NAME"

