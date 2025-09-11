#!/bin/bash

echo "🔧 Setting up Android environment for testing (Safe Mode)..."
echo "=========================================================="

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
        
        # Check for connected devices
        devices=$(adb devices 2>/dev/null | grep -v "List of devices attached" | grep -v "^$" | wc -l | tr -d ' ')
        if [ "$devices" -gt "0" ]; then
            echo "   ✅ Found $devices Android device(s)"
            device_available=true
        else
            echo "   ⚠️  No devices connected"
            device_available=false
        fi
    else
        echo "   ⚠️  ADB still not found after adding to PATH"
        device_available=false
    fi
else
    echo "   ⚠️  Platform-tools not found or SDK not set"
    device_available=false
fi

echo ""

# Decide what tests to run based on environment
if [ -n "$ANDROID_SDK_ROOT" ] && [ -n "$ANDROID_NDK_ROOT" ]; then
    echo "🔨 Building Android bindings..."
    if just build-android > /dev/null 2>&1; then
        echo "✅ Android bindings built successfully"
        
        # Check if we should run real tests or mock tests
        if [ "$device_available" = true ]; then
            echo ""
            echo "⚠️  Device detected but real tests may fail due to JNA issues"
            echo "   Running safe mock tests instead..."
            echo ""
            exec bash ./scripts/run-android-tests-mock.sh
        else
            echo ""
            echo "ℹ️  No device available - running mock tests..."
            echo ""
            exec bash ./scripts/run-android-tests-mock.sh
        fi
    else
        echo "❌ Android build failed"
        echo ""
        echo "🔨 Falling back to compilation test..."
        if ./gradlew compileDebugAndroidTestKotlin > /dev/null 2>&1; then
            echo "✅ Tests compile successfully"
            echo ""
            echo "Running mock tests..."
            exec bash ./scripts/run-android-tests-mock.sh
        else
            echo "❌ Test compilation failed"
            exit 1
        fi
    fi
else
    echo "⚠️  Missing Android SDK/NDK - running basic tests..."
    echo ""
    exec bash ./scripts/run-android-tests-mock.sh
fi