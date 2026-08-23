{
  lib,
  stdenv,
  fetchurl,
  fetchFromGitHub,
  config,
  cudaSupport ? config.cudaSupport,
  cmake,
  anari-sdk,
  libGL,
  lua54Packages,
  pkg-config,
  assimp,
  cudaPackages,
  glm,
  hdf5,
  opensubdiv,
  tbb,
  silo,
  sdl3,
  sol2,
  openusd,
  libx11,
  libxt,
  vtk,
  zlib,
  nix-update-script,
}:
let
  imgui-src = fetchurl {
    url = "https://github.com/ocornut/imgui/archive/refs/tags/v1.91.7-docking.zip";
    hash = "sha256-glnDJORdpGuZ8PQ4uBYfeOh0kmCzJmNnI9zHOnSwePQ=";
  };
  imnodes-src = fetchurl {
    url = "https://github.com/Nelarius/imnodes/archive/refs/tags/v0.5.zip";
    hash = "sha256-hRWz07KXmeLX00bSWHZ9izaqpBTEeeViOCkPySivNNk=";
  };
  imguizmo-src = fetchurl {
    url = "https://github.com/CedricGuillemet/ImGuizmo/archive/71f14292205c3317122b39627ed98efce137086a.zip";
    hash = "sha256-kOrhHDy5hMGAC95Q1CbfpPNh1D9LQBg48I5H/GGzjRw=";
  };
  openusdCore = openusd.override {
    # Vela only needs OpenUSD library support. Nixpkgs' top-level openusd enables
    # USDView/tools, which pulls PyQt6 -> QtWebEngine and breaks on aarch64-darwin.
    withUsdView = false;
    withTools = false;
  };
in
stdenv.mkDerivation {
  pname = "vela";
  version = "0-unstable-2026-08-25";

  src = fetchFromGitHub {
    owner = "NVIDIA";
    repo = "Vela";
    rev = "d3465bb1fd17bcec5192a704b5bc4e3b6ff0cbbe";
    hash = "sha256-aQalZvrS1nzAMvNSvcFBRV317lqlaTTh/ki5jM4T5Wc=";
  };

  # anari_sdk_fetch_project() downloads into `.anari_deps/<name>` under the
  # source root; seeding it there keeps the build offline.
  postUnpack = ''
    mkdir -p "''${sourceRoot}/.anari_deps/vela_ext_imgui_sdl/"
    cp "${imgui-src}" "''${sourceRoot}/.anari_deps/vela_ext_imgui_sdl/v1.91.7-docking.zip"
    mkdir -p "''${sourceRoot}/.anari_deps/vela_ext_imnodes/"
    cp "${imnodes-src}" "''${sourceRoot}/.anari_deps/vela_ext_imnodes/v0.5.zip"
    mkdir -p "''${sourceRoot}/.anari_deps/vela_ext_imguizmo/"
    cp "${imguizmo-src}" "''${sourceRoot}/.anari_deps/vela_ext_imguizmo/71f14292205c3317122b39627ed98efce137086a.zip"
  '';

  patches = [ ./0001-fix-io-build-against-OpenUSD-25.05.patch ];

  cmakeFlags = [
    (lib.cmakeBool "BUILD_TESTING" false)
    (lib.cmakeBool "VSR_USE_CUDA" cudaSupport)
    (lib.cmakeBool "VSR_USE_ASSIMP" true)
    (lib.cmakeBool "VSR_USE_HDF5" true)
    (lib.cmakeBool "VSR_USE_LUA" true)
    (lib.cmakeBool "VSR_USE_SDL3" true)
    (lib.cmakeBool "VSR_USE_SILO" true)
    (lib.cmakeBool "VSR_USE_TBB" true)
    (lib.cmakeBool "VSR_USE_USD" true)
    (lib.cmakeBool "VSR_USE_VTK" true)
  ];

  # Only the ANARI device and the USD file format plugin have install rules;
  # the applications are left in the build directory.
  postInstall = ''
    mkdir -p "''${out}/bin"
    for app in \
      scivisStudio \
      scivisStudioCLI \
      scivisStudioRenderShot \
      vsrDataTreeEditor \
      vsrLua \
      vsrMultiDeviceViewer \
      vsrOffline \
      vsrPrint \
      vsrRender \
      vsrViewer \
      vsrVolumeToNanoVDB
    do
      cp "./''${app}" "''${out}/bin"
    done
  '';

  nativeBuildInputs = [
    cmake
    pkg-config
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_nvcc
  ];

  buildInputs = [
    anari-sdk
    assimp
    sdl3
    glm
    libGL
    lua54Packages.lua
    hdf5
    opensubdiv
    openusdCore
    silo
    sol2
    tbb
    vtk
    zlib
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libx11
    libxt
  ]
  ++ lib.optionals cudaSupport [
    cudaPackages.cuda_cudart
    cudaPackages.cuda_cccl
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--version=branch"
      "--flake"
    ];
  };

  meta = with lib; {
    description = "Scene graph library and applications pairing a live, editable scene description with ANARI devices";
    homepage = "https://github.com/NVIDIA/Vela";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
