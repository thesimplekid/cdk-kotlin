#!/bin/bash
# Quick test script to verify Android test handling

export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_NDK_ROOT=~/Library/Android/sdk/ndk/29.0.14033849

echo "📱 Quick Android Test Check"
echo "=========================="
echo "ANDROID_SDK_ROOT: $ANDROID_SDK_ROOT"
echo "ANDROID_NDK_ROOT: $ANDROID_NDK_ROOT"
echo ""

# Check if Android build is already done
if [ -f "lib/src/main/jniLibs/arm64-v8a/libcdk_ffi.so" ]; then
    echo "✅ Android native libraries already built"
else
    echo "ℹ️  Android native libraries not built (run 'just build-android' to build)"
fi

# Check for ADB
if command -v adb &> /dev/null; then
    echo "✅ ADB is available"
    
    # Check for devices
    devices=$(adb devices | grep -v "List of devices attached" | grep -v "^$" | wc -l | tr -d ' ')
    if [ "$devices" -gt "0" ]; then
        echo "✅ Found $devices Android device(s)"
        echo ""
        echo "Ready to run: just test-android"
    else
        echo "⚠️  No Android devices connected"
        echo ""
        echo "Options:"
        echo "  1. Connect an Android device with USB debugging"
        echo "  2. Start an Android emulator"
        echo "  3. Run 'just test' for device-independent tests"
    fi
else
    echo "⚠️  ADB not found in PATH"
    echo "   Add \$ANDROID_SDK_ROOT/platform-tools to PATH"
fi

# Check test compilation
echo ""
echo "🔨 Checking test compilation..."
if ./gradlew compileDebugAndroidTestKotlin > /dev/null 2>&1; then
    echo "✅ Android tests compile successfully"
else
    echo "❌ Android test compilation failed"
fi