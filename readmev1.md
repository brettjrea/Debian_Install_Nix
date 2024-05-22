*First runs with anything nix can take a good while as it finds the cached packages and downloads them or builds from source! Subsequent runs will be faster as they are now loaded into your store and it just looks to add or remove any changes to an existing derivation. Nix uses Hashes to compare files and by default will try to find an existing binaries hash in the store before it rebuilds or downloads it.*

# Single User Installation

To explicitly select a single-user installation on your system:

```console
$ bash <(curl -L https://nixos.org/nix/install) --no-daemon
```

In a single-user installation, `/nix` is owned by the invoking user.
The script will invoke `sudo` to create `/nix` if it doesn’t already exist.
If you don’t have `sudo`, manually create `/nix` as `root`and run the bash script again. 

*swap alice for user*

```console
$ su root
# mkdir /nix
# chown alice /nix
```

---

Restart terminal or use the following to start using it right away.

```
. /home/userland/.nix-profile/etc/profile.d/nix.sh`
```

I thought below was for the flakes only, but its also for the nix-command error so I just run it.

*Might not be neccesary if you used determinate systems installer need to verify.*

```
mkdir -p ~/.config/nix && echo 'experimental-features = nix-command flakes
' >> ~/.config/nix/nix.conf
```

## Single User uninstall

To remove a single-user installation of Nix, run:

```console
$ rm -rf /nix ~/.nix-channels ~/.nix-defexpr ~/.nix-profile
```

You might also want to manually remove references to Nix from your `~/.profile`.

---

### The Fastest way I found to get a *prebuilt* binary into the store and executing.

#### Adds file to store.

`nix store prefetch-file https://github.com/wasmCloud/wasmCloud/releases/download/wash-cli-v0.27.0/wash-x86_64-unknown-linux-musl`

#### Fixes permissions.

`chmod 755 /nix/store/9an7c6l3fbidz67rd6naca4g2symxq4g-wash-x86_64-unknown-linux-musl`

#### Test that the binary is installed by running full path it's not installed into shell yet or symlinked.

`./nix/store/9an7c6l3fbidz67rd6naca4g2symxq4g-wash-x86_64-unknown-linux-musl`

---

## Using Flakes to build a project binary.

*The following was derived for Wasmcloud from the repo in an attempt to isolate some of the commands into a more scoped flake and get the latest version into my packages. I will try to get some more generalized examples in future but I think this excercise might help you reason how to do this on your own.*

*The 'nix-command flakes' is aliased already I just haven't tested all commands in different variations yet and am trying to stay true to what I have pulled from the Dockerfile.*

#### Clone Repo:

```
git clone https://github.com/wasmCloud/wasmCloud.git
```

#### Run the original flake.nix this builds the binaries to ./result

```
nix --accept-flake-config --extra-experimental-features 'nix-command flakes' build -L ".#wasmcloud${TARGET}"
```

I deleted the created files to test and I needed the `--rebuild` command to force a rebuild.

```
nix --accept-flake-config --extra-experimental-features 'nix-command flakes' build -L ".#wasmcloud${TARGET}" --rebuild
```

#### A workaround to get another flake to run.

Now I put the following in a different `default.nix` so that it will run when I run `nix build` without the experimental flake command.

*I am not sure how it worked since the command is aliased but it does I might need to recheck if it was truelly aliased or not for me* 

I need my `default.nix` to do these things from the Dockerfile.

```
install -Dp ./result/bin/wash /out/wash
install -Dp ./result/bin/wasmcloud /out/wasmcloud
```

```
--chmod=755 /out/wash /bin/wash
--chmod=755 /out/wasmcloud /bin/wasmcloud
```

This `default.nix` sets r/w attributes, puts it in the right folder and most importantly uses *autopatchelf* to patch the runtime for nix.

#### This is what it looks like in the file.

`cd into .result/`

add the following `default.nix`.

#### default.nix

```
{ stdenv, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "wasmcloud-binaries";
  version = "1.0";

  src = ./.; # Assuming the binaries are in the current directory

  nativeBuildInputs = [ autoPatchelfHook ];

  installPhase = ''
    install -D $src/out/wash $out/bin/wash
    install -D $src/out/wasmcloud $out/bin/wasmcloud
  '';

  meta = with stdenv.lib; {
    description = "wasmCloud Binaries";
    homepage = "https://wasmcloud.com";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
```

---
#### Gather Intel.

*You will need to gather the package name for the next nix file to call it.*

Lets quickly go check the /nix/store and confirm the packages are there gather any intel.

Run `cd /nix/store/` once in the folder search for package `find -name *wash*`.

---

### Now that the packages are either downloaded or built from source I want to use it in a custom shell. 

#### Now add the `shell.nix` remember to update package to match your unique packages name and run `nix shell` this will add packages to your current shell for use.

```
{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.02hzx0lagp1fwbkwf4f229jfgdp48f9v-wasmcloud-1.0.0/bin/wash
    pkgs.02hzx0lagp1fwbkwf4f229jfgdp48f9v-wasmcloud-1.0.0/bin/wasmcloud
  ];
}
```

---

### Putting it all together for a full and complete development environment in one flake.

#### After you have either built or downloaded the binaries and got them installed in the `nix/store`.

*You should have tested via manually invoking a path and getting a successful output by this point and have a clear idea of the binaries path as we are going to place it in the bottom of the file where we add this path to our shell.*

We can tie it into a `flake.nix` that will setup a fuller and more complete development environment.

```
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
```
