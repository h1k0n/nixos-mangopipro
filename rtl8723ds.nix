{
  lib,
  stdenv,
  fetchFromGitHub,
  kernel,
  bc,
}:

stdenv.mkDerivation {
  pname = "rtl8723ds";
  version = "${kernel.version}-unstable-2023-11-15";

  src = fetchFromGitHub {
    owner = "Benetti-Engineering";
    repo = "rtl8723ds";
    rev = "122a574f780da32bb0de760bf089a3a9ec1e8f87";
    sha256 = "sha256-9dLrQW2qlUR4rdy2uH08gYSJPQFfW2hIp3aDcQPxfFI=";
  };

  hardeningDisable = [ "pic" ];

  nativeBuildInputs = [ bc ] ++ kernel.moduleBuildDependencies;
  makeFlags =
    [
  #    "USER_EXTRA_CFLAGS=-Wno-error=incompatible-pointer-types -Wno-error=-Wmissing-prototypes"
      "ARCH=${stdenv.hostPlatform.linuxArch}"
    ]
    ++ lib.optionals (stdenv.hostPlatform != stdenv.buildPlatform) [
      "CROSS_COMPILE=${stdenv.cc.targetPrefix}"
    ];

  prePatch = ''
    substituteInPlace ./Makefile \
      --replace /lib/modules/ "${kernel.dev}/lib/modules/" \
      --replace '$(shell uname -r)' "${kernel.modDirVersion}" \
      --replace /sbin/depmod \# \
      --replace '$(MODDESTDIR)' "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/" \
      --replace EXTRA_CFLAGS ccflags-y
  '';

  preInstall = ''
    mkdir -p "$out/lib/modules/${kernel.modDirVersion}/kernel/net/wireless/"
  '';

  enableParallelBuilding = true;

  meta = {
    description = "Linux driver for RTL8723DS.";
    homepage = "https://github.com/Benetti-Engineering/rtl8723ds";
    license = lib.licenses.gpl2Only;
    platforms = lib.platforms.linux;
    maintainers = with lib.maintainers; [ chuangzhu ];
  };
}
