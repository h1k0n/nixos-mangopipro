final: prev:

rec {
  ubootPackages = prev.callPackage ./uboot-default.nix {
    stdenv = final.gcc14Stdenv;
  };

  linux_nezha = prev.callPackage ./linux.nix {
    stdenv = final.gcc14Stdenv;
  };

  linuxPackages_nezha =
    let
      base = prev.linuxPackagesFor linux_nezha;
    in
    base // {
      rtl8723ds = base.callPackage ./rtl8723ds.nix { };
    };
}
