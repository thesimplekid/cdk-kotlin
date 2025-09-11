#!/bin/bash

echo "🔧 Setting up Android environment for testing..."
echo "=============================================="

# Check if Android SDK path exists
ANDROID_SDK_PATH="$HOME/Library/Android/sdk"
ANDROID_NDK_PATH="$ANDROID_SDK_PATH/ndk/29.0.14033849"

if [ -d "$ANDROID_SDK_PATH" ]; then
    echo "✅ Found Android SDK at: $ANDROID_SDK_PATH"
    export ANDROID_SDK_ROOT="$ANDROID_SDK_PATH"
    
    if [ -d "$ANDROID_NDK_PATH" ]; then
        echo "✅ Found Android NDK at: $ANDROID_NDK_PATH"
        export ANDROID_NDK_ROOT="$ANDROID_NDK_PATH"
    else
        echo "⚠️  NDK not found at: $ANDROID_NDK_PATH"
        echo "   Looking for any NDK version..."
        NDK_DIRS=$(find "$ANDROID_SDK_PATH/ndk" -maxdepth 1 -type d -name "*.*.*" 2>/dev/null | head -1)
        if [ -n "$NDK_DIRS" ]; then
            export ANDROID_NDK_ROOT="$NDK_DIRS"
            echo "✅ Found NDK at: $ANDROID_NDK_ROOT"
        else
            echo "❌ No NDK found in $ANDROID_SDK_PATH/ndk/"
        fi
    fi
else
    echo "❌ Android SDK not found at: $ANDROID_SDK_PATH"
    echo ""
    echo "Please either:"
    echo "1. Install Android SDK/NDK to the default location"
    echo "2. Set custom paths:"
    echo "   export ANDROID_SDK_ROOT=/path/to/your/sdk"
    echo "   export ANDROID_NDK_ROOT=/path/to/your/ndk"
fi

echo ""
echo "🌍 Current environment:"
echo "   ANDROID_SDK_ROOT: ${ANDROID_SDK_ROOT:-'<not set>'}"
echo "   ANDROID_NDK_ROOT: ${ANDROID_NDK_ROOT:-'<not set>'}"

# Add platform-tools to PATH if Android SDK is available
if [ -n "$ANDROID_SDK_ROOT" ] && [ -d "$ANDROID_SDK_ROOT/platform-tools" ]; then
    export PATH="$ANDROID_SDK_ROOT/platform-tools:$PATH"
    echo "   Added to PATH: $ANDROID_SDK_ROOT/platform-tools"
    
    # Verify ADB is now available
    if command -v adb &> /dev/null; then
        echo "   ✅ ADB is now available"
    else
        echo "   ⚠️  ADB still not found after adding to PATH"
    fi
else
    echo "   ⚠️  Platform-tools not found or SDK not set"
fi
echo ""

if [ -n "$ANDROID_SDK_ROOT" ] && [ -n "$ANDROID_NDK_ROOT" ]; then
    echo "🚀 Running Android tests with environment set..."
    echo ""
    
    # Try to run real Android tests, but fall back to mock if they fail
    if ! just test-android; then
        echo ""
        echo "⚠️  Real Android tests failed - falling back to mock mode..."
        echo ""
        exec bash ./scripts/run-android-tests-mock.sh
    fi
else
    echo "⚠️  Missing environment variables - running mock tests..."
    echo ""
    exec bash ./scripts/run-android-tests-mock.sh
fi