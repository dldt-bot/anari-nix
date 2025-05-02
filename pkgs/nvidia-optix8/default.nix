{
  lib,
  stdenv,
  fetchFromGitHub,
}:
let
  version = "v8.1.0";
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "optix-dev";
    rev = version;
    hash = "sha256-qNhN1N0hIPoihrFVzolo2047FomLtqyHFUQh5qW3O5o=";
  };

in
stdenv.mkDerivation {
  inherit src version;
  pname = "nvidia-optix8";

  installPhase = ''
    mkdir -p "$out/include"
    cp -r include/* "$out/include"
  '';

  meta = with lib; {
    description = "An application framework for achieving optimal ray tracing performance on the GPU.";
    homepage = "https://developer.nvidia.com/rtx/ray-tracing/optix";
    license = licenses.unfreeRedistributable;
    platforms = platforms.linux;
  };
}
