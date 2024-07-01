{ lib
, fetchFromGitHub
, buildUBoot
, opensbi
, writeText
}:

buildUBoot {
  version = "unstable-2023-10-31";

  src = fetchFromGitHub {
    owner = "smaeul";
    repo = "u-boot";
    # Last git revision from the `d1-wip` branch:
    rev = "2e89b706f5c956a70c989cd31665f1429e9a0b48";
    sha256 = "sha256-POjP3PPuluYNTWWo5EUFWT0K3zYFWBFviPOGIhnejCA=";
  };
  patches = [];

  defconfig = "lichee_rv_dock_defconfig";
  extraMeta.platforms = [ "riscv64-linux" ];
  extraMakeFlags = [
    "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
  ];

  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
}
