{
  description = "A flake template for Webassembly, that includes custom wasmCloud binaries in the shell";

  # Flake inputs
  inputs.nixpkgs.url = "https://flakehub.com/f/NixOS/nixpkgs/0.1.*.tar.gz";


  # Flake outputs
  outputs = { self, nixpkgs }:
    let

      # Overlay
      goVersion = 22;
      overlays = [
        (final: prev: rec {
          nodejs = prev.nodejs_latest;
          pnpm = prev.nodePackages.pnpm;
          yarn = (prev.yarn.override { inherit nodejs; });
          go = prev."go_1_${toString goVersion}";
        })
      ];



      # The systems supported for this flake
      supportedSystems = [
        "x86_64-linux" # 64-bit Intel/AMD Linux
        "aarch64-linux" # 64-bit ARM Linux
        "x86_64-darwin" # 64-bit Intel macOS
        "aarch64-darwin" # 64-bit ARM macOS
      ];

      # Helper to provide system-specific attributes
      forEachSupportedSystem = f: nixpkgs.lib.genAttrs supportedSystems (system: f {
         pkgs = import nixpkgs { inherit system; overlays = overlays; };

      });

    in

    {
      devShells = forEachSupportedSystem ({ pkgs }: {
        default = pkgs.mkShell {
          # The Nix packages provided in the environment
          # Add any you need here
          packages = with pkgs; [

            # CI
              cachix
              direnv
              nix-direnv

            # System Utilities

              autoconf
              automake
              bash
              bison
              bzip2
              ccache
              cmake
              curl
              file
              flex
              gettext
              git
              gnupg
              intltool
              lsb-release
              om4
              gnumake
              meson
              mold
              nano
              openssh
              parallel
              gnupatch
              patchelf
              perl
              pkgconf
              libpkgconf
              python311Packages.pip
              ragel
              rsync
              sudo
              proot
              tzdata
              xz
              zip
              zstd
              jq
              openssl
              pkg-config


            # Pulumi Utilities

              # pulumi-watch
              # pulumi-analyzer-* utilities
              # pulumi-language-* utilities
              # pulumi-resource-* utilities
              # pulumi-bin

            # SDKs

              # Python SDK:
              python311

              # Go SDK:
              go_1_22

              # Node.js SDK:
              nodejs
              node2nix
              corepack_20

              # .NET SDK:
              dotnet-sdk_6
              dotnet-sdk_8

              # Java SDK:
              jdk
              maven

              # Rust SDK:
              rustc
              cargo
              rustup

              # Zig SDK:
              zig

              # Emscripten SDK:
              emscripten

              # Kubernetes

              kubectl

              # Miscellaneous Utilities

              jq

              # Python Tools

              # pip

              python311Packages.pip
              pipenv

              # PHP Tools

              php

              # Go Tools
              gotools

              # Go Lint
              golangci-lint

              #tinygo
              tinygo

              # Rust Tools

              cargo-deny
              cargo-edit
              cargo-wasi
              cargo-watch
              rust-analyzer

              # WebAssembly Tools

              # wasm-bindgen
              wasm-pack
              wasm-tools
              wabt
              wazero
              wasmedge
              wasmer
              wasmtime
              
              #Wasmcloud dependencies
              nats-server

          ];

          # Set any environment variables for your dev shell
          env = { };

          # Add any shell logic you want executed any time the environment is activated
          shellHook = ''
            export PATH=$PATH:/nix/store/02hzx0lagp1fwbkwf4f229jfgdp48f9v-wasmcloud-1.0.0/bin/
          '';
        };
      });
    };
}
