{ lib
, fetchFromGitHub
, buildUBoot
, opensbi
, writeText
, pkgs
}:

(buildUBoot {
  version = "d1-wip";

  src = fetchFromGitHub {
    owner = "smaeul";
    repo = "u-boot";
    # Last git revision from the `d1-wip` branch:
    rev = "2e89b706f5c956a70c989cd31665f1429e9a0b48";
    sha256 = "sha256-POjP3PPuluYNTWWo5EUFWT0K3zYFWBFviPOGIhnejCA=";
  };

  defconfig = "lichee_rv_dock_defconfig";
  extraMeta.platforms = [ "riscv64-linux" ];
  extraMakeFlags = [
    "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
    "DEVICE_TREE=sun20i-d1-lichee-rv-dock"
  ];

  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
}).overrideAttrs (oldAttrs: {
  patches = [
    ./uboot.patch
  ];  # remove all patches, which is not compatible with thead-u-boot
})
