{
  description = "CDK Kotlin Bindings Flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    rust-overlay = {
      url = "github:oxalica/rust-overlay";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    flake-utils.url = "github:numtide/flake-utils";

    android-nixpkgs = {
      url = "github:tadfisher/android-nixpkgs";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { self
    , nixpkgs
    , rust-overlay
    , flake-utils
    , android-nixpkgs
    , ...
    }@inputs:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        lib = pkgs.lib;
        stdenv = pkgs.stdenv;
        isDarwin = stdenv.isDarwin;
        libsDarwin =
          with pkgs;
          lib.optionals isDarwin [
            darwin.apple_sdk.frameworks.Security
            darwin.apple_sdk.frameworks.SystemConfiguration
          ];

        # Dependencies
        pkgs = import nixpkgs {
          inherit system overlays;
          config = {
            android_sdk.accept_license = true;
            allowUnfree = true;
          };
        };

        # Android SDK/NDK Configuration
        androidSdk = android-nixpkgs.sdk.${system} (sdkPkgs: with sdkPkgs; [
          cmdline-tools-latest
          build-tools-34-0-0
          build-tools-35-0-0
          platform-tools
          platforms-android-35
          ndk-25-2-9519653
        ]);

        # Toolchains
        # Stable toolchain with Android targets
        stable_toolchain = pkgs.rust-bin.stable."1.85.0".default.override {
          targets = [
            "aarch64-linux-android"
            "armv7-linux-androideabi"
            "i686-linux-android"
            "x86_64-linux-android"
          ];
          extensions = [
            "rustfmt"
            "clippy"
            "rust-analyzer"
          ];
        };


        # Common environment variables
        envVars = {
          NIX_PATH = "nixpkgs=${inputs.nixpkgs}";
          ANDROID_SDK_ROOT = "${androidSdk}/share/android-sdk";
          ANDROID_NDK_ROOT = "${androidSdk}/share/android-sdk/ndk/25.2.9519653";
          JAVA_HOME = "${pkgs.jdk17}";
          GRADLE_OPTS = "-Dorg.gradle.daemon=false";
          PKG_CONFIG_PATH = "${pkgs.openssl.dev}/lib/pkgconfig";
          OPENSSL_DIR = "${pkgs.openssl.dev}";
          OPENSSL_LIB_DIR = "${pkgs.openssl.out}/lib";
          OPENSSL_INCLUDE_DIR = "${pkgs.openssl.dev}/include";
        };

        # Common build inputs
        buildInputs =
          with pkgs;
          [
            git
            pkg-config
            curl
            just
            nixpkgs-fmt
            typos

            # Java/Kotlin/Android
            jdk17
            gradle
            androidSdk

            # Rust tools for Android
            cargo-ndk

            # Needed for CI
            libz

            # OpenSSL for native dependencies
            openssl
            openssl.dev

            # Perl needed for vendored OpenSSL builds
            perl
          ]
          ++ libsDarwin;

        nativeBuildInputs = [
          # Additional native build inputs
        ]
        ++ lib.optionals isDarwin [
          # Additional darwin specific native inputs
        ];
      in
      {
        devShells =
          let
            # Base development shell
            stable = pkgs.mkShell (
              {
                shellHook = ''
                  echo "CDK Kotlin Development Environment"
                  echo ""
                  echo "Rust toolchain: stable (1.85.0)"
                  echo "Java: ${pkgs.jdk17.version}"
                  echo "Android SDK: $ANDROID_SDK_ROOT"
                  echo "Android NDK: $ANDROID_NDK_ROOT"
                  echo ""

                  # Configure Gradle for Nix environment
                  if [ ! -f local.properties ]; then
                    echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
                    echo "✓ Created local.properties"
                  fi

                  if ! grep -q "android.builder.sdkDownload=false" gradle.properties 2>/dev/null; then
                    echo "android.builder.sdkDownload=false" >> gradle.properties
                    echo "✓ Configured gradle.properties to prevent SDK downloads"
                  fi

                  echo ""
                  echo "Available commands:"
                  echo "  just --list    # Show all available tasks"
                  echo "  just generate  # Generate Kotlin bindings"
                  echo "  just build     # Build for current platform"
                  echo ""

                  # Needed for CI/Linux
                  export LD_LIBRARY_PATH=${
                    pkgs.lib.makeLibraryPath [
                      pkgs.zlib
                    ]
                  }:$LD_LIBRARY_PATH
                '';
                buildInputs = buildInputs ++ [ stable_toolchain ];
                inherit nativeBuildInputs;
              }
              // envVars
            );

            # CI shell - minimal setup for automated builds
            ci = pkgs.mkShell (
              {
                shellHook = ''
                  # Configure Gradle for Nix environment
                  if [ ! -f local.properties ]; then
                    echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties
                  fi

                  if ! grep -q "android.builder.sdkDownload=false" gradle.properties 2>/dev/null; then
                    echo "android.builder.sdkDownload=false" >> gradle.properties
                  fi

                  # Minimal output for CI
                  export LD_LIBRARY_PATH=${
                    pkgs.lib.makeLibraryPath [
                      pkgs.zlib
                    ]
                  }:$LD_LIBRARY_PATH
                '';
                buildInputs = buildInputs ++ [ stable_toolchain ];
                inherit nativeBuildInputs;
              }
              // envVars
            );

          in
          {
            inherit
              stable
              ci
              ;
            default = stable;
          };

        # Formatter for nix files
        formatter = pkgs.nixpkgs-fmt;
      }
    );
}
