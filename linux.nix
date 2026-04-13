{
  fetchurl,
  lib,
  stdenv,
  linuxKernel,
  ubootPackages,
  buildPackages,
  ...
}:

let
  version = "6.19.11";
  src = fetchurl {
    url = "https://cdn.kernel.org/pub/linux/kernel/v6.x/linux-${version}.tar.xz";
    sha256 = "sha256-IAOde2slbAi+L4+sQ8P/mmIDCMcDxkPPL4DDkQub1Zs=";
  };
in
(linuxKernel.manualConfig {
  inherit src version lib;
  stdenv = stdenv.override (
    prev: lib.recursiveUpdate prev { hostPlatform.linux-kernel.DTB = false; }
  );
  modDirVersion = version;
  configfile = ./6.14rc6.config;
  allowImportFromDerivation = true;
}).overrideAttrs (old: {
  # Shorten kernel name to dodge U-Boot length limits
  name = "k";
  nativeBuildInputs = old.nativeBuildInputs ++ [ ubootPackages.ubootTools ];
})
