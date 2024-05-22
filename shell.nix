{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  buildInputs = [
    pkgs.02hzx0lagp1fwbkwf4f229jfgdp48f9v-wasmcloud-1.0.0/bin/wash
    pkgs.02hzx0lagp1fwbkwf4f229jfgdp48f9v-wasmcloud-1.0.0/bin/wasmcloud
  ];
}
