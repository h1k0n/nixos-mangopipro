{
  config,
  lib,
  pkgs,
  modulesPath,
  pkgsKernel,
  ...
}:

{

  imports = [ ./sd-image-btrfs.nix ];

  # Boot0 -> U-Boot
  sdImage = {
    firmwarePartitionOffset = 20;
    createFirmwarePartition = false;
    postBuildCommands = ''
      dd conv=notrunc if=${pkgsKernel.buildUB.ubootD1}/u-boot-sunxi-with-spl.bin of=$img bs=512 seek=256
    '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    populateFirmwareCommands = "";
    # compressImage = false;
  };

  # U-Boot -> kernel -> initrd -> init
  boot = {
    loader.grub.enable = false;
    loader.generic-extlinux-compatible.enable = true;

    consoleLogLevel = lib.mkDefault 7;
    kernelPackages = pkgsKernel.linuxPackages_nezha;
    kernelParams = [
      "earlycon=sbi"
      "console=ttyS0,115200n8"
      "rootwait"
      "debug"
    ];
    initrd.kernelModules = [
      "dm_mod"
    ];
    initrd.availableKernelModules = lib.mkForce [
      "btrfs"
      "sd_mod"
      "mmc_block"
      "hid"
      "nvme"
      "xhci_hcd"
      "usbhid"
      "hid_generic"
    ];
    initrd.compressor = "gzip";
    initrd.systemd.enable = true;

    extraModulePackages = [ pkgsKernel.linuxPackages_nezha.rtl8723ds ];
    # Exclude zfs
    supportedFilesystems = lib.mkForce [
      "btrfs"
      "vfat"
      "ext4"
    ];
  };
  hardware = {
    deviceTree = {
      enable = false;
    };
  };

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];
  };
}
