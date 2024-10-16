{ stdenv
, lib
, bc
, bison
, dtc
, fetchFromGitHub
, fetchpatch
, fetchurl
, flex
, gnutls
, installShellFiles
, libuuid
, meson-tools
, ncurses
, openssl
, rkbin
, swig
, which
, python3
, armTrustedFirmwareAllwinner
, armTrustedFirmwareAllwinnerH6
, armTrustedFirmwareAllwinnerH616
, armTrustedFirmwareRK3328
, armTrustedFirmwareRK3399
, armTrustedFirmwareRK3588
, armTrustedFirmwareS905
, buildPackages
, opensbi
}:

let
  defaultVersion = "2024.07";
  defaultSrc = fetchurl {
    url = "https://ftp.denx.de/pub/u-boot/u-boot-${defaultVersion}.tar.bz2";
    hash = "sha256-9ZHamrkO89az0XN2bQ3f+QxO1zMGgIl0hhF985DYPI8=";
  };

  # Dependencies for the tools need to be included as either native or cross,
  # depending on which we're building
  toolsDeps = [
    ncurses # tools/kwboot
    libuuid # tools/mkeficapsule
    gnutls # tools/mkeficapsule
    openssl # tools/mkimage
  ];

  buildUBoot = lib.makeOverridable ({
    version ? null
  , src ? null
  , filesToInstall
  , pythonScriptsToInstall ? { }
  , installDir ? "$out"
  , defconfig
  , extraConfig ? ""
  , extraPatches ? []
  , extraMakeFlags ? []
  , extraMeta ? {}
  , crossTools ? false
  , ... } @ args: stdenv.mkDerivation ({
    pname = "uboot-${defconfig}";

    version = if src == null then defaultVersion else version;

    src = if src == null then defaultSrc else src;

    patches = [
    ] ++ extraPatches;

    postPatch = ''
      ${lib.concatMapStrings (script: ''
        substituteInPlace ${script} \
        --replace "#!/usr/bin/env python3" "#!${pythonScriptsToInstall.${script}}/bin/python3"
      '') (builtins.attrNames pythonScriptsToInstall)}
      patchShebangs tools
      patchShebangs scripts
    '';

    nativeBuildInputs = [
      ncurses # tools/kwboot
      bc
      bison
      flex
      installShellFiles
      (buildPackages.python3.withPackages (p: [
        p.libfdt
        p.setuptools # for pkg_resources
        p.pyelftools
      ]))
      swig
      which # for scripts/dtc-version.sh
    ] ++ lib.optionals (!crossTools) toolsDeps;
    depsBuildBuild = [ buildPackages.stdenv.cc ];
    buildInputs = lib.optionals crossTools toolsDeps;

    hardeningDisable = [ "all" ];

    enableParallelBuilding = true;

    makeFlags = [
      "DTC=${lib.getExe buildPackages.dtc}"
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    ] ++ extraMakeFlags;

    passAsFile = [ "extraConfig" ];

    configurePhase = ''
      runHook preConfigure

      make ${defconfig}

      cat $extraConfigPath >> .config

      runHook postConfigure
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p ${installDir}
      cp ${lib.concatStringsSep " " (filesToInstall ++ builtins.attrNames pythonScriptsToInstall)} ${installDir}

      mkdir -p "$out/nix-support"
      ${lib.concatMapStrings (file: ''
        echo "file binary-dist ${installDir}/${builtins.baseNameOf file}" >> "$out/nix-support/hydra-build-products"
      '') (filesToInstall ++ builtins.attrNames pythonScriptsToInstall)}

      runHook postInstall
    '';

    dontStrip = true;

    meta = with lib; {
      homepage = "https://www.denx.de/wiki/U-Boot/";
      description = "Boot loader for embedded systems";
      license = licenses.gpl2Plus;
      maintainers = with maintainers; [ bartsch dezgeg lopsided98 ];
    } // extraMeta;
  } // removeAttrs args [ "extraMeta" "pythonScriptsToInstall" ]));
in {
  inherit buildUBoot;

  ubootTools = buildUBoot {
    defconfig = "tools-only_defconfig";
    installDir = "$out/bin";
    hardeningDisable = [];
    dontStrip = false;
    extraMeta.platforms = lib.platforms.linux;

    crossTools = true;
    extraMakeFlags = [ "HOST_TOOLS_ALL=y" "NO_SDL=1" "cross_tools" ];

    outputs = [ "out" "man" ];

    postInstall = ''
      installManPage doc/*.1
    '';
    filesToInstall = [
      "tools/dumpimage"
      "tools/fdtgrep"
      "tools/kwboot"
      "tools/mkenvimage"
      "tools/mkimage"
    ];

    pythonScriptsToInstall = {
      "tools/efivar.py" = (python3.withPackages (ps: [ ps.pyopenssl ]));
    };
  };
ubootD1 = buildUBoot {
  version = "d1-wip";

  src = fetchFromGitHub {
    owner = "smaeul";
    repo = "u-boot";
    # Last git revision from the `d1-wip` branch:
    rev = "2e89b706f5c956a70c989cd31665f1429e9a0b48";
    sha256 = "sha256-POjP3PPuluYNTWWo5EUFWT0K3zYFWBFviPOGIhnejCA=";
  };
  patches = [
  ];

  defconfig = "nezha_defconfig";
  extraMeta.platforms = [ "riscv64-linux" ];
  extraMakeFlags = [
    "OPENSBI=${opensbi}/share/opensbi/lp64/generic/firmware/fw_dynamic.bin"
    "DEVICE_TREE=sun20i-d1-lichee-rv-dock"
  ];

  filesToInstall = ["u-boot-sunxi-with-spl.bin"];
};

}
