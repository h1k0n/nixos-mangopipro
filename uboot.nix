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
    rev = "329e94f16ff84f9cf9341f8dfdff7af1b1e6ee9a";
    sha256 = "sha256-c4yHizDvfRTqnxyKzNrSPCdlesBWuzgyQIEhpR690Vc=";
  };
  patches = [];
  extraPatches = [
    ./uboot.patch
  ]; 

  defconfig = "nezha_defconfig";
  extraMeta.platforms = [ "riscv64-linux" ];
  extraMakeFlags = [
    "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
    "DEVICE_TREE=sun20i-d1-lichee-rv-dock"
  ];

  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
}
