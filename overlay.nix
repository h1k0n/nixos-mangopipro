final: prev:

rec {
  buildUB = prev.callPackage ./uboot-default.nix {
    stdenv = final.gcc14Stdenv;
  };
  linux_nezha = prev.callPackage ./linux.nix {
    stdenv = final.gcc14Stdenv;
  };
  linuxPackages_nezha = prev.linuxPackagesFor linux_nezha;

}
