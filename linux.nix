{ fetchFromGitHub
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
  src = fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    # Last git revision from the `riscv/d1-wip` branch:
    rev = "v6.11";
    sha256 = "sha256-QIbHTLWI5CaStQmuoJ1k7odQUDRLsWNGY10ek0eKo8M=";
  };
  version = "6.11.0";
  kernelStdenv = overrideCC stdenv buildPackages.gcc14;
in

# Not using buildLinux because common-config leads to kernel panic
linuxKernel.manualConfig {
  inherit src version lib;
  stdenv = kernelStdenv.override (prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; });
  modDirVersion = "6.11.0";

  configfile = ./6.11-final.config;
  allowImportFromDerivation = true;
}
).overrideAttrs (old: {
  name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel. 
  nativeBuildInputs = old.nativeBuildInputs ++ [buildUB.ubootTools];
})
