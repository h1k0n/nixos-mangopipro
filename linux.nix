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
  src = fetchTarball {
    url = "https://git.kernel.org/pub/scm/linux/kernel/git/palmer/linux.git/snapshot/linux-b3f835cd7339919561866252a11831ead72e7073.tar.gz";
    sha256 = "1icab8ly0ksmw0h72cq7c9wwyfz78s9qk7nsgbrpkq810lr8v2nc";
  };
  version = "6.11.0";
  kernelStdenv = overrideCC stdenv buildPackages.gcc14;
in

# Not using buildLinux because common-config leads to kernel panic
linuxKernel.manualConfig {
  inherit src version lib;
  stdenv = kernelStdenv.override (prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; });
  modDirVersion = "6.11.0-rc2";
  kernelPatches = [
    {
    name = "xthead";
    patch = ./xtheadvector-v9.patch;
    }
    {
    name = "plic";
    patch = ./v3-irqchip-sifive-plic-Probe-plic-driver-early-for-Allwinner-D1-platform.patch;
    }
  ];

  configfile = ./6.11.config;
  allowImportFromDerivation = true;
}
).overrideAttrs (old: {
  name = "k"; # shorten the kernel name, dodge uboot length limits, otherwise it will make uboot fail to load kernel. 
  nativeBuildInputs = old.nativeBuildInputs ++ [ubootTools];
})
