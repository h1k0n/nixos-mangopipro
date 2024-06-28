final: prev:

rec {
  ubootLicheeRV = prev.callPackage ./uboot.nix { };
  linux_nezha = prev.callPackage ./linux.nix { };
  linuxPackages_nezha = packagesFor linux_nezha;

  packagesFor = kernel:
    let origin = prev.linuxPackagesFor kernel; in
    origin // {
      rtl8723ds = origin.callPackage ./rtl8723ds.nix { };
    };
}

