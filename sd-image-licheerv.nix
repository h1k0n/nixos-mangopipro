{
  config,
  lib,
  pkgs,
  pkgsKernel,
  ...
}:

{
  imports = [ ./sd-image-btrfs.nix ];

  sdImage = {
    firmwarePartitionOffset = 20;
    createFirmwarePartition = false;
    postBuildCommands = ''
      dd conv=notrunc if=${pkgsKernel.ubootPackages.ubootD1}/u-boot-sunxi-with-spl.bin of=$img bs=512 seek=256
    '';
    populateRootCommands = ''
      mkdir -p ./files/boot
      ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
    '';
    populateFirmwareCommands = "";
  };

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

    initrd = {
      kernelModules = [ "dm_mod" ];
      availableKernelModules = lib.mkForce [
        "btrfs"
        "sd_mod"
        "mmc_block"
        "hid"
        "nvme"
        "xhci_hcd"
        "usbhid"
        "hid_generic"
      ];
      compressor = "gzip";
      systemd.enable = true;
    };

    extraModulePackages = [ pkgsKernel.linuxPackages_nezha.rtl8723ds ];
    supportedFilesystems = lib.mkForce [ "btrfs" "vfat" "ext4" ];
  };

  hardware.deviceTree.enable = false;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];
}
