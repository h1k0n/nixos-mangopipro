final: prev:

rec {
          btrfs-progs = prev.btrfs-progs.overrideAttrs (oldAttrs: {
            src = prev.fetchFromGitHub {
              owner = "kdave";
              repo = "btrfs-progs";
              # devel 2024.09.10; Remove v6.11 release.
              rev = "c75b2f2c77c9fdace08a57fe4515b45a4616fa21";
              hash = "sha256-PgispmDnulTDeNnuEDdFO8FGWlGx/e4cP8MQMd9opFw=";
            };

            patches = [
              ./mkfs-btrfs-force-root-ownership.patch
            ];
            postPatch = "";
            nativeBuildInputs =
              oldAttrs.nativeBuildInputs
              ++ [
                prev.autoconf
                prev.automake
              ];

            preConfigure = "./autogen.sh";

            version = "6.11.0.pre";
          });
  buildUB = prev.callPackage ./uboot-default.nix {
    stdenv = final.gcc14Stdenv;
  };
  linux_nezha = prev.callPackage ./linux.nix {
  };
  linuxPackages_nezha = packagesFor linux_nezha;

  packagesFor = kernel:
    let origin = prev.linuxPackagesFor kernel; in
    origin // {
      rtl8723ds = origin.callPackage ./rtl8723ds.nix { };
    };
}

