{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  anari-sdk,
  pkg-config,
  cudaPackages,
  nvidia-optix,
  nvidia-mdl,
  python3,
}:
stdenv.mkDerivation {
  pname = "visrtx";
  version = "v0.11.0-100-g35a4d81";

  # Main source.
  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "VisRTX";
    rev = "35a4d81df80f04ce1c91ce229a87b8dccfb5b46e";
    hash = "sha256-5BcieOIu22iP2puNf30hIaONAP+5AvatmkvB7BSykbw=";
  };

  cmakeFlags = [
    "-DFETCHCONTENT_FULLY_DISCONNECTED=ON"
    "-DOptiX_ROOT_DIR=${nvidia-optix}"
    "-DVISRTX_BUILD_GL_DEVICE=OFF"
    "-DVISRTX_ENABLE_MDL_SUPPORT=ON"
    "-DVISRTX_PRECOMPILE_SHADERS=OFF"
  ];

  patches = [
    ./disable-optix-headers-fetch.patch
  ];

  postFixup = ''
    patchelf --add-rpath ${nvidia-mdl}/lib/ $out/lib/libanari_library_visrtx.so
  '';

  nativeBuildInputs = [
    cudaPackages.cuda_nvcc

    cmake
    pkg-config
    python3
  ];

  buildInputs = [
    anari-sdk

    # CUDA and OptiX
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cccl
    cudaPackages.libcurand
    nvidia-optix

    # MDL
    nvidia-mdl
  ];

  meta = with lib; {
    description = "VisRTX is an experimental, scientific visualization-focused implementation of the Khronos ANARI standard.";
    homepage = "https://github.com/NVIDIA/VisRTX";
    license = licenses.bsd3;
    platforms = platforms.linux;
  };
}
