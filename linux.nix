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
    version = "6.14-rc6";
    src = fetchurl {
      url = "https://github.com/torvalds/linux/archive/refs/tags/v6.14-rc6.tar.gz";
      sha256 = "sha256-wPR5uEM1knyl+FsXu/s/aFcsEtpYJJ2b2VFC/iuhOV0=";
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

    configfile = ./6.14rc6.config;
    allowImportFromDerivation = true;
  }
).overrideAttrs
  (old: {
    name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel.
    nativeBuildInputs = old.nativeBuildInputs ++ [ buildUB.ubootTools ];
  })
