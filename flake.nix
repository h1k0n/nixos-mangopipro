{
  description = "NixOS running on MangoPi MQ-Pro (RISC-V)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
  };

  outputs =
    { self, nixpkgs, ... }:
    let
      # Cross-compilation pkgs: x86_64 host → riscv64 target (with board-specific overlay)
      pkgsRiscv = import nixpkgs {
        localSystem = "x86_64-linux";
        crossSystem.config = "riscv64-unknown-linux-gnu";
        overlays = [ (import ./overlay.nix) ];
      };

      # Native x86_64 pkgs (with patched btrfs-progs for image building)
      pkgsNative = import nixpkgs {
        localSystem = "x86_64-linux";
        overlays = [
          (_final: prev: {
            btrfs-progs = prev.btrfs-progs.overrideAttrs (_old: {
              patches = [ ./mkfs-btrfs-force-root-ownership-and-time.patch ];
              postPatch = "";
            });
          })
        ];
      };
    in
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-rfc-style;

      nixosConfigurations.mangopipro = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          pkgsKernel = pkgsRiscv;
          inherit pkgsNative;
        };
        modules = [
          { nixpkgs.crossSystem.system = "riscv64-linux"; }
          ./sd-image-licheerv.nix
          ./user-group.nix
        ];
      };
    };
}
