{ config, lib, pkgs, modulesPath, pkgsKernel, ... }:

{

  imports = [ "${modulesPath}/installer/sd-card/sd-image.nix" ];

  # Boot0 -> U-Boot
  sdImage = {
    firmwarePartitionOffset = 20;
    postBuildCommands = ''
      dd conv=notrunc if=${pkgsKernel.ubootLicheeRV}/u-boot-sunxi-with-spl.bin of=$img bs=512 seek=16
    '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    # Sun20i_d1_spl doesn't support loading U-Boot from a partition. The line below is a stub
    populateFirmwareCommands = "";
    # compressImage = false;
  };

  # U-Boot -> kernel -> initrd -> init
  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;

    consoleLogLevel = lib.mkDefault 7;
    kernelPackages = pkgsKernel.linuxPackages_nezha;
    kernelParams = [ "console=ttyS0,115200n8" "console=tty0" "earlycon=sbi" ];

    initrd.availableKernelModules = lib.mkForce [ ];

    extraModulePackages = [ pkgsKernel.linuxPackages_nezha.rtl8723ds ];
    # Exclude zfs
    supportedFilesystems = lib.mkForce [ ];
  };
  hardware = {
    deviceTree = {
      name="allwinner/sun20i-d1-lichee-rv-dock.dtb";
      overlays = [];
    };
    firmware = [];
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}

