{ pkgs, ... }:

let
  username = "nixos";
  hostname = "mangopipro";
  # To generate a hashed password run `mkpasswd`.
  # This is the hash of the password "lp4a"
  hashedPassword = "$y$j9T$SVH.lGVv9kZ8Pk4ohgOgB.$7yZ7YqG0ReSIHTT15ZKifcsC/j3GVes3hY9Z0x0Ohb3";
in
{
  # ── Networking ──────────────────────────────────────────────────────────
  networking = {
    hostName = hostname;
    wireless = {
      enable = true;
      secretsFile = "/var/lib/secrets/wireless.conf";
      networks.CMCC-EHG4.pskRaw = "ext:psk_cmcc_ehg4";
    };
  };

  systemd.tmpfiles.rules = [
    "d /var/lib/secrets 0750 root wpa_supplicant -"
  ];

  # ── SSH ─────────────────────────────────────────────────────────────────
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "yes";
  };

  # ── Services ────────────────────────────────────────────────────────────
  services.lvm.dmeventd.enable = true;
  services.journald = {
    storage = "volatile";
    rateLimitBurst = 300;
    extraConfig = "MaxLevelStore=info\nMaxLevelSyslog=info\nMaxLevelKMsg=notice\nMaxLevelConsole=info\nMaxLevelWall=emerg";
  };

  # ── Users & Groups ─────────────────────────────────────────────────────
  users.users.${username} = {
    inherit hashedPassword;
    isNormalUser = true;
    home = "/home/${username}";
    extraGroups = [ "users" "networkmanager" "wheel" ];
  };

  users.groups = {
    ${username} = { };
  };

  # ── System Packages ────────────────────────────────────────────────────
  environment.systemPackages = with pkgs; [
    # Development
    git
    curl
    gdb
    gcc14
    file
    vim

    # System monitoring
    tree
    fastfetch
    iotop
    ioping
    fio
    sysstat

    # Networking
    mtr
    iperf3
    nmap
    ldns     # provides `drill` (dig replacement)
    socat
    tcpdump

    # Archives
    zip
    xz
    unzip
    p7zip
    zstd
    gnutar
  ];
  networking.firewall.enable=false;
systemd.packages = [
  (pkgs.runCommand "dev-ttyS0-device-override" {} ''
    mkdir -p $out/etc/systemd/system/dev-ttyS0.device.d
    cat > $out/etc/systemd/system/dev-ttyS0.device.d/override.conf << EOF
[Unit]
JobTimeoutSec=0
EOF
  '')
];
  services.getty.autologinUser = "nixos";
}
