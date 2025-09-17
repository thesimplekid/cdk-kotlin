# CDK Kotlin

Kotlin/Android bindings for the Cashu Development Kit (CDK).

## Requirements

- Android SDK with Build-Tools for API level 24 or higher
- Android NDK (for building from source)
- Rust toolchain with `cargo` (for building from source)

## Environment Setup

Before building, set up the following environment variables:

```bash
export ANDROID_SDK_ROOT=~/Library/Android/sdk
export ANDROID_NDK_ROOT=$ANDROID_SDK_ROOT/ndk/<your-ndk-version>
```

Replace `<your-ndk-version>` with your installed NDK version.

## Installation

### From Maven Repository

Add the dependency to your app's `build.gradle.kts`:

```kotlin
dependencies {
    implementation("org.cashudevkit:cdk-kotlin:0.1.0")
}
```

### Building from Source

1. Set up environment variables (see Environment Setup section above)
2. Set up and build:
   ```bash
   just setup
   just install-deps
   just build-android
   just publish-local
   ```

## Usage

```kotlin
import org.cashudevkit.*

// Example usage - see androidTest for complete examples
```

## Architecture Support

The library includes native binaries for the following Android architectures:
- arm64-v8a (64-bit ARM)
- armeabi-v7a (32-bit ARM)
- x86 (32-bit Intel/AMD)
- x86_64 (64-bit Intel/AMD)

## Available Commands

Use `just --list` to see all available commands. Key commands:
- `just setup` - Set up local.properties from environment variables
- `just build-android` - Build for all Android architectures
- `just test` - Run comprehensive test suite
- `just publish-local` - Publish to local Maven repository

## Development

Run tests:
```bash
just test
```

## License

This project is licensed under the MIT License.