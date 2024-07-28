{ fetchFromGitHub
, lib
, stdenv
, linuxKernel
, writeText
, ubootTools
, overrideCC
, buildPackages
, ...
} @ args:
(
let
  src = fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    # Last git revision from the `riscv/d1-wip` branch:
    rev = "v6.8";
    sha256 = "sha256-rXihZ/3ix36O/HsMlRUmsBmt1M/CEb65+3vMAqEP8fc=";
  };
  version = "6.8.0";
  kernelStdenv = overrideCC stdenv buildPackages.xthead.gcc14;
in

# Not using buildLinux because common-config leads to kernel panic
linuxKernel.manualConfig {
  inherit src version lib;
  stdenv = kernelStdenv.override (prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; });
  modDirVersion = "6.8.0";

  configfile = ./68.config;
  allowImportFromDerivation = true;
  extraMakeFlags = [
    "KCFLAGS+=-march=rv64gc_v0p7_zihintpause"
    "KCFLAGS+=-mcpu=thead-c906"
  ];
}
).overrideAttrs (old: {
  name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel. 
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
