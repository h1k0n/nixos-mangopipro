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
    version = "6.14.1";
    modVersion = "6.14.1";
    src = fetchurl {
      url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-6.17.7.tar.gz";
      sha256 = "sha256-bdczqkWtayA7hTHBaly8UMycC27HShDoLrU2gSWCjr0=";
    };
  in
  # kernelStdenv = overrideCC stdenv buildPackages.gcc14;

  # Not using buildLinux because common-config leads to kernel panic
  linuxKernel.manualConfig {
    inherit src version lib;
    stdenv = stdenv.override (
      prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; }
    );
    modDirVersion = modVersion;

    configfile = ./6.14rc6.config;
    allowImportFromDerivation = true;
  }
).overrideAttrs
  (old: {
    name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel.
    nativeBuildInputs = old.nativeBuildInputs ++ [ buildUB.ubootTools ];
  })
