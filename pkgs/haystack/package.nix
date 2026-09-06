{
  lib,
  stdenv,
  fetchFromGitHub,
  cmake,
  anari-sdk,
  libGL,
  qt6,
  tbb,
  libx11,
  nix-update-script,
}:
stdenv.mkDerivation {
  pname = "haystack";
  version = "0.9.0-unstable-2026-09-03";

  src = fetchFromGitHub {
    owner = "ingowald";
    repo = "HayStack";
    rev = "1c0726e49072b80358784961b34a03016775a7e6";
    fetchSubmodules = true;
    hash = "sha256-xCS9fAA9GImO7parGsw8LegsCLlvsnOrVMJq52RMFTc=";
  };

  cmakeFlags = [
    (lib.cmakeBool "HS_CUTEE" true)
  ];

  # Qt wrapping is only done on Linux; on Darwin the qtbase setup hook
  # still requires us to declare wrapping behavior explicitly.
  dontWrapQtApps = stdenv.hostPlatform.isDarwin;

  installPhase = ''
    runHook preInstall

    mkdir -p "''${out}/bin"
    cp ./hsOffline "''${out}/bin"
    cp ./miniSplitObjectSpace "''${out}/bin"
    cp ./miniSetMaterial "''${out}/bin"
    cp ./swcMakeBinaries "''${out}/bin"

    ${lib.optionalString stdenv.hostPlatform.isDarwin ''
      mkdir -p "''${out}/Applications"
      cp -r ./hsViewerQT.app "''${out}/Applications/"
    ''}
    ${lib.optionalString stdenv.hostPlatform.isLinux ''
      cp ./hsViewerQT "''${out}/bin"
    ''}

    runHook postInstall
  '';

  nativeBuildInputs = [
    cmake
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    anari-sdk
    qt6.qtbase
    tbb
  ]
  ++ lib.optionals stdenv.hostPlatform.isLinux [
    libGL
    libx11
  ];

  passthru.updateScript = nix-update-script {
    extraArgs = [
      "--flake"
      "--version=branch"
    ];
  };

  meta = with lib; {
    description = "ANARI-based viewer for scientific visualization data (meshes, volumes, AMR), with Qt UI.";
    homepage = "https://github.com/ingowald/HayStack";
    license = licenses.asl20;
    platforms = platforms.unix;
  };
}
