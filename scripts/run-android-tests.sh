#!/bin/bash
set -e

echo "📱 Running CDK Kotlin Android Tests"
echo "===================================="

# Function to check if ADB is available
check_adb() {
    if ! command -v adb &> /dev/null; then
        echo "⚠️  ADB not found. Please ensure Android SDK is installed and in PATH."
        return 1
    fi
    return 0
}

# Function to check for connected devices
check_devices() {
    local devices=$(adb devices | grep -v "List of devices attached" | grep -v "^$" | wc -l | tr -d ' ')
    if [ "$devices" -eq "0" ]; then
        return 1
    fi
    return 0
}

# Function to start emulator if available
try_start_emulator() {
    if command -v emulator &> /dev/null; then
        echo "🔍 Checking for available emulators..."
        local avds=$(emulator -list-avds 2>/dev/null | head -n 1)
        if [ -n "$avds" ]; then
            echo "📱 Found emulator: $avds"
            echo "🚀 Attempting to start emulator (this may take a few minutes)..."
            
            # Start emulator in background
            emulator -avd "$avds" -no-window -no-audio -no-boot-anim &> /dev/null &
            local emulator_pid=$!
            
            # Wait for emulator to boot (max 60 seconds)
            local wait_time=0
            while [ $wait_time -lt 60 ]; do
                if adb wait-for-device 2>/dev/null && adb shell getprop sys.boot_completed 2>/dev/null | grep -q "1"; then
                    echo "✅ Emulator started successfully"
                    return 0
                fi
                sleep 2
                wait_time=$((wait_time + 2))
                echo -n "."
            done
            echo ""
            
            # Kill emulator if it didn't boot properly
            kill $emulator_pid 2>/dev/null || true
            echo "⚠️  Emulator failed to start within timeout"
            return 1
        else
            echo "ℹ️  No Android emulators found"
            return 1
        fi
    else
        echo "ℹ️  Emulator command not found"
        return 1
    fi
}

# Main test execution
# Check if Android SDK is configured
if [ -z "$ANDROID_SDK_ROOT" ] || [ -z "$ANDROID_NDK_ROOT" ]; then
    if [ -z "$ANDROID_SDK_ROOT" ]; then
        echo "⚠️  ANDROID_SDK_ROOT environment variable not set"
    fi
    if [ -z "$ANDROID_NDK_ROOT" ]; then
        echo "⚠️  ANDROID_NDK_ROOT environment variable not set"
    fi
    echo ""
    echo "📚 Setup Instructions:"
    echo "   1. Install Android SDK and NDK (via Android Studio or command line tools)"
    echo "   2. Set environment variables:"
    echo "      export ANDROID_SDK_ROOT=~/Library/Android/sdk"
    echo "      export ANDROID_NDK_ROOT=~/Library/Android/sdk/ndk/29.0.14033849"
    echo "   3. Add to your shell profile (~/.bashrc, ~/.zshrc, etc.)"
    echo ""
    echo "🔨 Attempting to compile tests with local build..."
    
    # Try to compile with local build instead
    if just build > /dev/null 2>&1; then
        echo "✅ Local build successful"
        echo ""
        echo "🔍 Verifying Android test compilation..."
        if ./gradlew compileDebugAndroidTestKotlin > /dev/null 2>&1; then
            echo "✅ Android tests compile successfully"
            echo ""
            echo "ℹ️  Tests are ready but cannot run without Android SDK"
            echo "   Configure ANDROID_SDK_ROOT and run 'just test-android' again"
            echo ""
            echo "💡 Run 'just test' for device-independent tests"
            exit 0
        else
            echo "❌ Android test compilation failed"
            exit 1
        fi
    else
        echo "❌ Build failed. Run 'just build' to see errors"
        exit 1
    fi
fi

echo "🔨 Building bindings for Android..."
just build-android > /dev/null 2>&1 || {
    echo "❌ Failed to build Android bindings"
    echo "   Run 'just build-android' to see detailed errors"
    exit 1
}
echo "✅ Android bindings built successfully"

echo ""
echo "🔍 Checking Android test environment..."

# Check if ADB is available
if ! check_adb; then
    echo "❌ Android SDK not properly configured"
    echo ""
    echo "📚 Setup Instructions:"
    echo "   1. Install Android SDK"
    echo "   2. Set ANDROID_SDK_ROOT environment variable"
    echo "   3. Add \$ANDROID_SDK_ROOT/platform-tools to PATH"
    echo ""
    echo "💡 Tip: Run 'just test' for device-independent tests"
    exit 1
fi

# Check for connected devices
if ! check_devices; then
    echo "⚠️  No Android devices connected"
    echo ""
    
    # Try to start an emulator
    echo "🤖 Attempting to start an Android emulator..."
    if ! try_start_emulator; then
        echo ""
        echo "📱 No devices or emulators available"
        echo ""
        echo "📚 Options to run Android tests:"
        echo "   1. Connect an Android device with USB debugging enabled"
        echo "   2. Start an Android emulator manually:"
        echo "      - Open Android Studio > Tools > AVD Manager"
        echo "      - Create and start an emulator"
        echo "   3. Use command line:"
        echo "      - Create AVD: avdmanager create avd -n test -k 'system-images;android-33;google_apis;x86_64'"
        echo "      - Start: emulator -avd test"
        echo ""
        echo "💡 Meanwhile, run 'just test' for device-independent tests"
        echo ""
        
        # Fall back to mock test mode
        echo "🤖 Running tests in mock mode..."
        echo ""
        exec bash ./scripts/run-android-tests-mock.sh
    fi
fi

# Device is available, run the tests
echo "✅ Android device/emulator detected"
echo ""
echo "🧪 Running Android instrumentation tests..."
echo "=========================================="

# Run the actual tests
./gradlew connectedAndroidTest || {
    echo ""
    echo "❌ Android tests failed"
    echo "   Check the test report at: lib/build/reports/androidTests/"
    exit 1
}

echo ""
echo "✅ All Android tests passed successfully!"
echo ""
echo "📊 Test Report:"
echo "=============="

# Parse and display test results if available
if [ -f "lib/build/outputs/androidTest-results/connected/TEST-*.xml" ]; then
    # Count test results from XML files
    total_tests=$(grep -h "tests=" lib/build/outputs/androidTest-results/connected/TEST-*.xml 2>/dev/null | sed 's/.*tests="\([0-9]*\)".*/\1/' | awk '{sum+=$1} END {print sum}')
    passed_tests=$(grep -h "failures=\"0\"" lib/build/outputs/androidTest-results/connected/TEST-*.xml 2>/dev/null | wc -l)
    
    if [ -n "$total_tests" ]; then
        echo "Total tests run: $total_tests"
        echo "Test files executed: $passed_tests"
    fi
fi

echo ""
echo "📁 Detailed reports available at:"
echo "   - HTML: lib/build/reports/androidTests/connected/index.html"
echo "   - XML: lib/build/outputs/androidTest-results/connected/"
echo ""
echo "🎉 CDK Kotlin Android tests completed successfully!"