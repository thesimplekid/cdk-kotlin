#!/bin/bash
set -e

echo "Installing cargo-ndk..."

# Check if cargo-ndk is already installed
if command -v cargo-ndk &> /dev/null; then
    echo "cargo-ndk is already installed"
    cargo ndk --version
else
    echo "Installing cargo-ndk..."
    cargo install cargo-ndk
fi

echo "cargo-ndk installation complete!"