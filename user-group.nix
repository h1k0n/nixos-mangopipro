{pkgs, ...}:
let
  username = "nixos";
  hostname = "mangopipro";
  # To generate a hashed password run `mkpasswd`.
  # this is the hash of the password "lp4a"
  hashedPassword = "$y$j9T$SVH.lGVv9kZ8Pk4ohgOgB.$7yZ7YqG0ReSIHTT15ZKifcsC/j3GVes3hY9Z0x0Ohb3";
in {
  # =========================================================================
  #      Users & Groups NixOS Configuration
  # =========================================================================

  networking.hostName = hostname;
  networking.wireless.enable = true;
  networking.wireless.networks = {
    CMCC-Tc75 = {
      psk = "tm0uxtt2";
    };
  };
  services.openssh.enable = true;
  services.openssh.settings.PermitRootLogin = "yes";

  # TODO Define a user account. Don't forget to update this!
  users.users."${username}" = {
    inherit hashedPassword;

    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = ["users" "networkmanager" "wheel" "docker"];
  };
  environment.systemPackages = with pkgs; [
    git # used by nix flakes
    curl
    gdb
  ];


  users.groups = {
    "${username}" = {};
    docker = {};
  };
}
