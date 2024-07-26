{ config, lib, pkgs, modulesPath, pkgsKernel, ... }:

let
  rootPartitionUUID = "14e19a7b-0ae0-484d-9d54-43bd6fdc20c7";
in
{

  imports = [ "${modulesPath}/installer/sd-card/sd-image.nix" ];

  # Boot0 -> U-Boot
  sdImage = {
    inherit rootPartitionUUID;
    firmwarePartitionOffset = 40;
    firmwareSize = 984;
    postBuildCommands = ''
      dd conv=notrunc if=${pkgsKernel.ubootLicheeRV}/u-boot-sunxi-with-spl.bin of=$img bs=512 seek=256
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
    kernelParams = [ "earlycon=sbi" "root=/dev/mmcblk0p2" "rootfstype=ext4" "console=ttyS0,115200n8" "rootwait" "cma=96M" "debug" ];

    initrd.availableKernelModules = lib.mkForce [
      "ext4" "sd_mod" "mmc_block"
      "xhci_hcd"
      "usbhid" "hid_generic"
    ];

    extraModulePackages = [ pkgsKernel.linuxPackages_nezha.rtl8723ds ];
    # Exclude zfs
    supportedFilesystems = lib.mkForce [
      "vfat"
      "ext4"
      "btrfs"
    ];
  };
  hardware = {
    deviceTree = {
      enable = false;
    };
  };

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
  };
}

