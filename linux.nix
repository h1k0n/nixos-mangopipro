{ fetchurl
, lib
, stdenv
, linuxKernel
, writeText
, buildUB 
, overrideCC
, buildPackages
, ...
} @ args:
(
let
  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.12.1.tar.gz";
    sha256 = "sha256-q4Nv10gk+lKFnY57xaYI9oS06AJpudztEQkHj9joVVA=";
  };
  version = "6.12.1";
  kernelStdenv = overrideCC stdenv buildPackages.gcc14;
in

# Not using buildLinux because common-config leads to kernel panic
linuxKernel.manualConfig {
  inherit src version lib;
  stdenv = kernelStdenv.override (prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; });
  modDirVersion = "6.12.1";

  configfile = ./xtheadvector-btrfs.config;
  allowImportFromDerivation = true;
}
).overrideAttrs (old: {
  name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel. 
  nativeBuildInputs = old.nativeBuildInputs ++ [buildUB.ubootTools];
})
