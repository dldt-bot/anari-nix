_final: prev: {
  # Mesa's libgallium links libLLVM.so.21; OSL defaults to LLVM 19. Both end up in
  # a viewer process, their global symbols interpose and the OSL JIT aborts with
  # "Attribute list does not match Module context". Build OSL against the same LLVM.
  openshadinglanguage = prev.openshadinglanguage.override {
    llvmPackages_19 = prev.llvmPackages_21;
  };

  embree-ispc = prev.embree.overrideAttrs (old: {
    cmakeFlags = old.cmakeFlags ++ [
      "-DEMBREE_ISPC_SUPPORT=ON"
    ];
  });

  sse2neon = prev.sse2neon.overrideAttrs (_old: {
    src = prev.fetchFromGitHub {
      owner = "DLTcollab";
      repo = "sse2neon";
      rev = "31532745b49d7dd7ff58c56df68f1fc3949e4db5";
      hash = "sha256-AU52k6Of761ewHXD68ZNT9HbenE5xBT2kMdenFbaSxE=";
    };
    doCheck = false;
  });
}
