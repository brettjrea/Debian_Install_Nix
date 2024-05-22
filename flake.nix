/* This Flake Fetch's a prebuilt Wasmcloud binary, auto */

{
  description = "wasmcloud";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs";
  };

  outputs = { self, nixpkgs }:
    {
      defaultPackage.x86_64-linux =
        with import nixpkgs { system = "x86_64-linux"; };
        stdenv.mkDerivation rec {
          name = "wasmcloud-${version}";
          version = "1.0.0";

          src = pkgs.fetchurl {
            url = "https://github.com/wasmCloud/wasmCloud/releases/download/v1.0.0/wasmcloud-x86_64-unknown-linux-musl";
            sha256 = "sha256:0a49pqvlsq5ldq95rmph0zrq0qlfb97f6k9kr8qxf6y11pgxmq30";
                                          
          };

           nativeBuildInputs = [
                  autoPatchelfHook
          ];

          sourceRoot = ".";

          installPhase = ''
            install -m755 -D wasmcloud $out/bin/wasmcloud
          '';

          meta = with lib; {
            homepage = "https://wasmcloud.org";
            description = "wasmcloud";
            platforms = platforms.linux;
          };
        };

      defaultPackage.aarch64-linux =
        with import nixpkgs { system = "aarch64-linux"; };
        stdenv.mkDerivation rec {
          name = "wasmcloud-${version}";
          version = "1.0.0";
          src = pkgs.fetchurl {
            url = "https://github.com/wasmCloud/wasmCloud/releases/download/v1.0.0/wasmcloud-aarch64-linux-android";
            sha256 = "sha256:0rm11chn0754w50nl50118h8ik6r59n9njsj25ark7nf26kklcrf";
          };

              nativeBuildInputs = [
                  autoPatchelfHook
          ];

          sourceRoot = ".";

          installPhase = ''
            install -m755 -D wasmcloud $out/bin/wasmcloud
          '';
          
          meta = with lib; {
            homepage = "https://wasmcloud.org";
            description = "wasmcloud";
            platforms = platforms.linux;
          };
        };
    };
}
