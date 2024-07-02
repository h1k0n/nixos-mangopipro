final: prev:

rec {
  opensbi = prev.opensbi.overrideAttrs (super: {
    makeFlags = prev.opensbi.makeFlags ++ ["FW_PIC=y"];
  });
  ubootLicheeRV = prev.callPackage ./uboot.nix { };
  linux_nezha = prev.callPackage ./linux.nix {
    # stdenv = prev.gcc14Stdenv;
  }; 
  linuxPackages_nezha = packagesFor linux_nezha;

  packagesFor = kernel:
    let origin = prev.linuxPackagesFor kernel; in
    origin // {
      rtl8723ds = origin.callPackage ./rtl8723ds.nix { };
    };
}

