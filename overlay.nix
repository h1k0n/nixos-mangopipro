final: prev:

rec {
  buildUB = prev.callPackage ./uboot-default.nix {
    stdenv = prev.gcc14Stdenv;
  };
  ubootLicheeRV = prev.callPackage ./uboot.nix {
    buildUBoot = final.buildUB.buildUBoot;
  };
  linux_nezha = prev.callPackage ./linux.nix {
    stdenv = prev.gcc14Stdenv;
    ubootTools = final.buildUB.ubootTools;
  };
  linuxPackages_nezha = packagesFor linux_nezha;

  packagesFor = kernel:
    let origin = prev.linuxPackagesFor kernel; in
    origin // {
      rtl8723ds = origin.callPackage ./rtl8723ds.nix { };
    };
}

