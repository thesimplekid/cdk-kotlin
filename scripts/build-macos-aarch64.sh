#!/bin/bash
set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
ANDROID_MAIN="${SCRIPT_DIR}/../lib/src/main"

# Find CDK FFI directory - check multiple possible locations
if [ -d "${SCRIPT_DIR}/../../cdk/crates/cdk-ffi" ]; then
    CDK_FFI_DIR="${SCRIPT_DIR}/../../cdk/crates/cdk-ffi"
elif [ -d "${SCRIPT_DIR}/../../cdk.git/crates/cdk-ffi" ]; then
    CDK_FFI_DIR="${SCRIPT_DIR}/../../cdk.git/crates/cdk-ffi"
else
    echo "❌ Error: cdk-ffi crate not found"
    echo "   Please ensure the CDK repository is cloned at ../cdk or ../cdk.git"
    exit 1
fi

# Create directories if they don't exist
mkdir -p "${ANDROID_MAIN}/kotlin"

cd "$CDK_FFI_DIR"

# Build for macOS (for testing/development)
echo "Building for macOS aarch64..."
cargo build --profile release-smaller

# Generate Kotlin bindings
echo "Generating Kotlin bindings..."
cargo run --bin uniffi-bindgen generate \
    --language kotlin \
    --out-dir "${ANDROID_MAIN}/kotlin" \
    --library "${CDK_FFI_DIR}/../../target/release-smaller/libcdk_ffi.dylib" \
    --no-format

echo "Build complete!"
echo "Note: This build is for local development/testing only."
echo "For Android deployment, use 'just build-android' instead."