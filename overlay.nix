final: prev:

rec {
  buildUB = prev.callPackage ./uboot-default.nix {
    stdenv = final.gcc14Stdenv;
  };
  linux_nezha = prev.callPackage ./linux.nix {
    stdenv = final.gcc14Stdenv;
  };
  linuxPackages_nezha = packagesFor linux_nezha;

  packagesFor =
    kernel:
    let
      origin = prev.linuxPackagesFor kernel;
    in
    origin
    // {
      rtl8723ds = origin.callPackage ./rtl8723ds.nix { };
    };
}
