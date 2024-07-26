{ fetchFromGitHub
, lib
, stdenv
, linuxKernel
, writeText
, ubootTools
, ...
} @ args:
(
let
  src = fetchFromGitHub {
    owner = "torvalds";
    repo = "linux";
    # Last git revision from the `riscv/d1-wip` branch:
    rev = "v6.8";
    sha256 = "";
  };
  version = "6.8.0";
in

# Not using buildLinux because common-config leads to kernel panic
linuxKernel.manualConfig {
  inherit src version lib;
  stdenv = stdenv.override (prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; });
  modDirVersion = "6.8.0";

  configfile = ./68.config;
  allowImportFromDerivation = true;
}
).overrideAttrs (old: {
  name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel. 
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
