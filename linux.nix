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
    rev = "v6.6";
    sha256 = "sha256-iUTHPMbELhtRogbrKr3n2FBwj8mbGYGacy2UgjPZZNg=";
  };
  version = "6.6.0";
  kernelStdenv = overrideCC stdenv buildPackages.xthead.gcc14;
in

# Not using buildLinux because common-config leads to kernel panic
linuxKernel.manualConfig {
  inherit src version lib;
  modDirVersion = "6.6.0";
  stdenv = kernelStdenv.override (prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; });

  configfile = ./66.config;
  allowImportFromDerivation = true;
  extraMakeFlags = [
    "KCFLAGS+=-march=rv64gc_xtheadvector_zihintpause"
    "KCFLAGS+=-mcpu=thead-c906"
  ];
}
).overrideAttrs (old: {
  name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel. 
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
