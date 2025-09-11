# CDK Kotlin

Kotlin/Android bindings for the Cashu Development Kit (CDK).

## Overview

This library provides Kotlin bindings for CDK, enabling Android applications to interact with Cashu protocol implementations.

## Requirements

- Android SDK with Build-Tools for API level 24 or higher  
- Kotlin 2.1.10 or later
- Android NDK 27.2.12479018 or above (for building from source)
- Rust toolchain with `cargo` (for building from source)

## Environment Setup

Before building, you must set up the following environment variables:

### macOS
```bash
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/27.2.12479018
```

### Linux  
```bash
export ANDROID_SDK_ROOT=/usr/local/lib/android/sdk
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/27.2.12479018
```

**Note:** Adjust the NDK version path according to your installed version. NDK version 27.2.12479018 or above is recommended.

## Installation

### From Maven Repository

Add the dependency to your app's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("org.cashudevkit:cdk-kotlin:0.1.0")
}
```

### Building from Source

1. **Set up environment variables** (see Environment Setup section above)

2. **Set up local properties:**
   ```bash
   just setup
   ```

3. **Install build dependencies:**
   ```bash
   just install-deps
   ```

4. **Build for your local architecture (for development/testing):**
   ```bash
   just build macos-aarch64  # or your platform
   ```

5. **Build for Android (all architectures):**
   ```bash
   just build-android
   ```

6. **Build the Android library:**
   ```bash
   ./gradlew :lib:assembleRelease
   ```

7. **Publish to local Maven repository:**
   ```bash
   just publish-local
   ```

## Usage

```kotlin
import org.cashudevkit.CdkWrapper

// Create a CDK instance
val cdk = CdkWrapper.create()

// Use the CDK functionality
// ... 

// Clean up when done
cdk.close()
```

## Architecture Support

The library includes native binaries for the following Android architectures:
- arm64-v8a (64-bit ARM)
- armeabi-v7a (32-bit ARM)
- x86 (32-bit Intel/AMD)
- x86_64 (64-bit Intel/AMD)

## Available Commands

Use `just` to see all available commands:

```bash
just --list
```

Common commands:
- `just setup` - Set up local.properties from environment variables  
- `just install-deps` - Install required dependencies (cargo-ndk)
- `just build-android` - Build for all Android architectures
- `just clean` - Clean all build artifacts
- `just publish-local` - Publish to local Maven repository
- `just test` - Run Android instrumentation tests

## Troubleshooting

### Environment Variable Issues
If you see errors about missing SDK or NDK, ensure your environment variables are set correctly:

```bash
echo $ANDROID_SDK_ROOT
echo $ANDROID_NDK_ROOT
```

### NDK Toolchain Issues  
If you encounter NDK toolchain errors, verify your NDK installation:

```bash
ls -la $ANDROID_NDK_ROOT/toolchains/llvm/prebuilt/
```

### Emulator Recommendations
- Use x86_64 emulators, not x86 (32-bit) emulators for better performance
- API level 24 or higher is recommended

## Development

### Project Structure

```
cdk-kotlin/
├── lib/                      # Android library module
│   ├── src/
│   │   ├── main/
│   │   │   ├── kotlin/       # Kotlin source code  
│   │   │   └── jniLibs/      # Native libraries (generated)
│   │   └── androidTest/      # Android instrumentation tests
│   └── build.gradle.kts
├── scripts/                  # Build scripts
│   ├── build-android.sh      # Android cross-compilation
│   ├── build-macos-aarch64.sh # Local development build
│   └── setup-local-properties.sh # Environment setup
└── gradle/                   # Gradle wrapper
```

### Running Tests

```bash
just test
# or directly:
./gradlew :lib:connectedAndroidTest
```

## License

This project is licensed under the MIT License.