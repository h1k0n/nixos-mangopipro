{
  description = "NixOS running on mangopi pro";

  inputs = {
    # nixpkgs do not provide binary cache for riscv64-linux, we need to build everything from scratch anyway.
    # so we can use the small channel to get updates more quickly.
    #    checkout more details here: https://hydra.nixos.org/jobset/nixos/release-23.05#tabs-jobs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      ...
    }:
    let
      buildFeatures = {
        config = "riscv64-unknown-linux-gnu";
      };
      pkgsKernelCross = import nixpkgs {
        localSystem = "x86_64-linux";
        crossSystem = buildFeatures;

        overlays = [
          (import ./overlay.nix)
        ];
      };
      pkgNative = import nixpkgs {
        localSystem = "x86_64-linux";

        overlays = [
          (
            final: prev:

            rec {
              btrfs-progs = prev.btrfs-progs.overrideAttrs (oldAttrs: {
                src = prev.fetchFromGitHub {
                  owner = "kdave";
                  repo = "btrfs-progs";
                  rev = "85ca0a6d60c14eefda509970a26616ff16115612";
                  hash = "sha256-iMFGrQ0B5/HsxHT+XtlsD7qGB3HXy3gMwLoRP64CWTY=";
                };

                patches = [
                  ./mkfs-btrfs-force-root-ownership.patch
                ];
                postPatch = "";
                nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [
                  prev.autoconf
                  prev.automake
                ];

                preConfigure = "./autogen.sh";

                version = "6.13.0";
              });
            })
        ];
      };
    in
    {
      # expose this flake's overlay

      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;
      # cross-build an sd-image
      nixosConfigurations.mangopipro = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        specialArgs = {
          pkgsKernel = pkgsKernelCross;
          pkgsNative = pkgNative;
        };
        modules = [
          {
            # cross-compilation this flake.
            nixpkgs.crossSystem = {
              system = "riscv64-linux";
            };
          }

          ./sd-image-licheerv.nix
          ./user-group.nix
        ];
      };

    };
}
