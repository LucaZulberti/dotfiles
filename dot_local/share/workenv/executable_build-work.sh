#!/usr/bin/env bash

# Detect the operating system
if [[ "$(uname)" == "Darwin" ]]; then
    # macOS detected
    TARGET_OS=macos
    echo "Building on macOS"
    echo " - User: $(id -u -n)"
    echo " - Group: $(id -g -n)"
    echo ""
else
    # Non-macOS (e.g., Linux)
    TARGET_OS=linux
    echo "Building on Linux"
    echo " - User: $(id -u) ($(id -u))"
    echo " - Group: $(id -g) ($(id -g))"
    echo ""
fi

docker build \
    --build-arg TARGET_OS=$TARGET_OS \
    --build-arg HOST_UID=$(id -u) \
    --build-arg HOST_GID=$(id -g) \
    --build-arg HOST_USER=$(id -u -n) \
    --build-arg HOST_GROUP=$(id -g -n) \
    -t workenv:$USER \
    -f Dockerfile.work \
    .

