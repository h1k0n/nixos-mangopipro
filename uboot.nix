{ lib
, fetchFromGitHub
, buildUBoot
, opensbi
, writeText
}:

buildUBoot {
  version = "d1-2022-10-31";

  src = fetchFromGitHub {
    owner = "smaeul";
    repo = "u-boot";
    # Last git revision from the `d1-wip` branch:
    rev = "2e89b706f5c956a70c989cd31665f1429e9a0b48";
    sha256 = "sha256-POjP3PPuluYNTWWo5EUFWT0K3zYFWBFviPOGIhnejCA=";
  };
  patches = [];

  defconfig = "nezha_defconfig";
  extraMeta.platforms = [ "riscv64-linux" ];
  extraMakeFlags = [
    "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
    "DEVICE_TREE=sun20i-d1-lichee-rv-dock"
  ];

  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
}
