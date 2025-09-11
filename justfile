[group("Repo")]
[doc("Default command; list all available commands.")]
@list:
    just --list --unsorted

[group("Repo")]
[doc("Open CDK repo on GitHub in your default browser.")]
repo:
    open https://github.com/cashubtc/cdk

[group("Repo")]
[doc("Build the API docs.")]
docs:
    ./gradlew :lib:dokkaGeneratePublicationHtml

[group("Repo")]
[doc("Publish the library to your local Maven repository.")]
publish-local:
    ./gradlew publishToMavenLocal -P localBuild

[group("Build")]
[doc("Build the library for given ARCH.")]
build ARCH="macos-aarch64":
    bash ./scripts/build-{{ARCH}}.sh

[group("Build")]
[doc("Build the library for all Android architectures.")]
build-android:
    bash ./scripts/build-android.sh

[group("Build")]
[doc("List available architectures for the build command.")]
@list-architectures:
    echo "Available architectures:"
    echo " - android (all Android architectures)"
    echo " - linux-x86_64"
    echo " - macos-aarch64"
    echo " - macos-x86_64"
    echo " - windows-x86_64"

[group("Build")]
[doc("Remove all caches and previous build directories to start from scratch.")]
clean:
    rm -rf ../cdk/crates/cdk-ffi/target/
    rm -rf ./build/
    rm -rf ./lib/build/
    rm -rf ./lib/src/main/jniLibs/
    rm -rf ./lib/src/main/kotlin/uniffi/

[group("Build")]
[doc("Install required dependencies (cargo-ndk).")]
install-deps:
    ./scripts/install-cargo-ndk.sh

[group("Build")]
[doc("Set up local.properties file from ANDROID_SDK_ROOT environment variable.")]
setup:
    ./scripts/setup-local-properties.sh

[group("Test")]
[doc("Run comprehensive test suite (all test types).")]
test:
    bash ./scripts/run-all-tests.sh

[group("Test")]
[doc("Quick test (mock Android tests, fast validation).")]
test-quick:
    bash ./scripts/run-android-tests-mock.sh

[group("Test")]
[doc("Basic binding validation (compilation and structure).")]
test-basic:
    bash ./scripts/run-tests.sh

[group("Test")]
[doc("Auto-detect Android SDK and run safe tests.")]
test-with-env:
    bash ./scripts/test-with-env-safe.sh

[group("Test")]
[doc("Real Android instrumentation tests (requires device/emulator).")]
test-android:
    bash ./scripts/run-android-tests.sh

[group("Test")]
[doc("Alias for test-android (Real Android device tests).")]
android-test:
    just test-android

[group("Test")]
[doc("Compile all tests without running them.")]
test-compile:
    ./gradlew compileDebugAndroidTestKotlin compileDebugUnitTestKotlin