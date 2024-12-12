{pkgs, pkgsGcc14, ...}:
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
    pkgsGcc14.pkgsCross.riscv64.gcc14
    file
    tree
    neofetch
    vim

    # networking
    mtr      # A network diagnostic tool
    iperf3   # A tool for measuring TCP and UDP bandwidth performance
    nmap     # A utility for network discovery and security auditing
    ldns     # replacement of dig, it provide the command `drill`
    socat    # replacement of openbsd-netcat
    tcpdump  # A powerful command-line packet analyzer

    # archives
    zip
    xz
    unzip
    p7zip
    zstd
    gnutar
    iotop
  ];
  services.journald.storage = "volatile";
  services.journald.rateLimitBurst = 300;
  services.journald.extraConfig = "MaxLevelStore=info\nMaxLevelSyslog=info\nMaxLevelKMsg=notice\nMaxLevelConsole=info\nMaxLevelWall=emerg"



  users.groups = {
    "${username}" = {};
    docker = {};
  };
}
