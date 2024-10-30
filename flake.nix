{
  description = "NixOS running on mangopi pro";

  inputs = {
    # nixpkgs do not provide binary cache for riscv64-linux, we need to build everything from scratch anyway.
    # so we can use the small channel to get updates more quickly.
    #    checkout more details here: https://hydra.nixos.org/jobset/nixos/release-23.05#tabs-jobs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    buildFeatures = {
      config = "riscv64-unknown-linux-gnu";

      # https://nixos.wiki/wiki/Build_flags
      # this option equals to add `-march=rv64gc` into CFLAGS.
      # CFLAGS will be used as the command line arguments for the gcc/clang.
      #
      # Note: CFLAGS is not used by the kernel build system! so this would not work for the kernel build.
      #
      # A little more detail;
      # RISC-V is a modular ISA, meaning that it only has a mandatory base,
      # and everything else is an extension.
      # RV64GC is basically "RISC-V 64-bit, extensions G and C":
      #
      #  G: Shorthand for the IMAFDZicsr_Zifencei base and extensions
      #  C: Standard Extension for Compressed Instructions
      #
      # for more details about the shorthand of RISC-V's extension, see:
      #   https://en.wikipedia.org/wiki/RISC-V#Design
      #
      # LicheePi 4A is a high-performance development board which supports extension G and C.
      # we need to enable them to get revyos's kernel built.
      # gcc.arch = "rv64gc";

      # the same as `-mabi=lp64d` in CFLAGS.
      #
      # Note: CFLAGS is not used by the kernel build system! so this would not work for the kernel build.
      #
      # lp64d: long, pointers are 64-bit. GPRs, 64-bit FPRs, and the stack are used for parameter passing.
      #
      # related docs:
      #  https://github.com/riscv-non-isa/riscv-toolchain-conventions/blob/master/README.mkd#specifying-the-target-abi-with--mabi
      # gcc.abi = "lp64d";
    };
    pkgsKernelCross = import nixpkgs {
      localSystem = "x86_64-linux";
      crossSystem = buildFeatures;

      overlays = [
        (import ./overlay.nix)
      ];
    };
    pkgsKernelNative = import nixpkgs {
      localSystem = "x86_64-linux";

      overlays = [
        (import ./overlay.nix)
      ];
    };
  in {
    # expose this flake's overlay

    # cross-build an sd-image
    nixosConfigurations.mangopipro = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";

      specialArgs = {
        pkgsKernel = pkgsKernelCross;
        pkgsNative = pkgsKernelNative;
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

