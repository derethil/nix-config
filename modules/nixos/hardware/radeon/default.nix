{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.types) nullOr str;
  inherit (lib.glace) mkBoolOpt mkOpt mkPackageOpt;
  cfg = config.glace.hardware.radeon;
in {
  options.glace.hardware.radeon = {
    enable = mkBoolOpt false "Whether to enable AMD GPU drivers on this system.";

    videoAcceleration = mkBoolOpt true "Whether to enable hardware video acceleration.";

    mesa = {
      package = mkPackageOpt null "Custom Mesa package to use for 64-bit. If null, uses stable or unstable Mesa based on useUnstable.";
      package32 = mkPackageOpt null "Custom Mesa package to use for 32-bit. If null, uses stable or unstable Mesa based on useUnstable.";
      useUnstable = mkBoolOpt false "Whether to use Mesa from nixpkgs-unstable instead of stable.";
    };

    ppfeaturemask = mkOpt (nullOr str) null ''
      AMD GPU ppfeaturemask value with PP_OVERDRIVE_MASK (0x4000) enabled.
      Required for GPU fan control on 7000/9000 series and newer (e.g., CoolerControl)
      To calculate the correct value for your system, run:
        printf 'amdgpu.ppfeaturemask=0x%x\n' "$(($(cat /sys/module/amdgpu/parameters/ppfeaturemask) | 0x4000))"
      Then set this option to the hex value from the output (e.g., "0xfff7ffff").
    '';
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = !(cfg.mesa.useUnstable && (cfg.mesa.package != null || cfg.mesa.package32 != null));
        message = "glace.hardware.radeon.mesa: Cannot use 'useUnstable' when 'package' or 'package32' is set. Either use a custom package or useUnstable, not both.";
      }
    ];

    environment.systemPackages = with pkgs; [
      radeontop
      mesa-demos
      vulkan-tools
    ];

    hardware.graphics = {
      enable = true;
      enable32Bit = true;

      package =
        if cfg.mesa.package != null
        then cfg.mesa.package
        else if cfg.mesa.useUnstable
        then pkgs.unstable.mesa
        else pkgs.mesa;

      package32 =
        if cfg.mesa.package32 != null
        then cfg.mesa.package32
        else if cfg.mesa.useUnstable
        then pkgs.unstable.pkgsi686Linux.mesa
        else pkgs.pkgsi686Linux.mesa;

      extraPackages = mkIf cfg.videoAcceleration (with pkgs; [
        libva-vdpau-driver
        libvdpau-va-gl
      ]);

      extraPackages32 = mkIf cfg.videoAcceleration (with pkgs.driversi686Linux; [
        libva-vdpau-driver
        libvdpau-va-gl
      ]);
    };

    services.xserver.videoDrivers = ["amdgpu"];

    boot.kernelParams = mkIf (cfg.ppfeaturemask != null) [
      "amdgpu.ppfeaturemask=${cfg.ppfeaturemask}"
    ];

    glace.apps.steam.extraEnv = {
      PROTON_FSR4_UPGRADE = "1";
    };
  };
}
