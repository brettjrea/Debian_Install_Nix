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
