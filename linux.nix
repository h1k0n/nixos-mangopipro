{
  fetchurl,
  lib,
  stdenv,
  linuxKernel,
  writeText,
  buildUB,
  overrideCC,
  buildPackages,
  ...
}@args:
(
  let
    version = "6.13.2";
    src = fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.13.2.tar.gz";
      sha256 = "sha256-K1TlUFR+K9v7Rstjz7AYOYPSs/DzZ4li9lN5XvReERw=";
    };
  in
  # kernelStdenv = overrideCC stdenv buildPackages.gcc14;

  # Not using buildLinux because common-config leads to kernel panic
  linuxKernel.manualConfig {
    inherit src version lib;
    stdenv = stdenv.override (
      prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; }
    );
    modDirVersion = version;
    kernelPatches = [
      {
        name = "xthead";
        patch = ./xtheadvector-6.13-new.patch;
      }
    ];

    configfile = ./6.13.config;
    allowImportFromDerivation = true;
  }
).overrideAttrs
  (old: {
    name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel.
    nativeBuildInputs = old.nativeBuildInputs ++ [ buildUB.ubootTools ];
  })
