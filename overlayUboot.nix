final: prev:
rec { 
  buildUB = prev.callPackage ./uboot-default.nix {
    stdenv = prev.gcc14Stdenv;
  };
  ubootLicheeRV = prev.callPackage ./uboot.nix {
    buildUBoot = final.buildUB.buildUBoot;   
  };
}
