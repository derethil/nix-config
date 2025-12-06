{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkOption types;
  inherit (lib.glace) mkBoolOpt mkPackageOpt;
  cfg = config.glace.hardware.nvidia;
in {
  options.glace.hardware.nvidia = {
    enable = mkBoolOpt false "Whether to enable Nvidia drivers on this system.";
    channel = mkOption {
      type = types.enum [
        "stable"
        "beta"
        "production"
        "latest"
        "vulkan_beta"
        "legacy_535"
        "legacy_470"
        "legacy_390"
        "legacy_340"
        "custom"
      ];
      default = "stable";
      description = "The NVIDIA driver channel to use. Specify 'custom' to use a custom driver package.";
    };
    package = mkPackageOpt null "Custom NVIDIA driver package to use. This option is used when 'channel' is set to 'custom'";
    useUnstable = mkBoolOpt false "Whether to use nvidia packages from nixpkgs-unstable instead of stable.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      pciutils
    ];

    # Enable OpenGL
    hardware.graphics.enable = true;

    # Load NVIDIA driver
    services.xserver.videoDrivers = ["nvidia"];

    # Disable Nouveau
    boot.blacklistedKernelModules = ["nouveau"];

    # Configure NVIDIA
    hardware.nvidia = {
      modesetting.enable = true;

      #  Power management can cause issues with sleep/suspend
      powerManagement.enable = false;
      powerManagement.finegrained = false;

      # Use opensource kernel module
      open = true;

      nvidiaSettings = false;

      package =
        if cfg.channel == "custom"
        then cfg.package.override { kernelPackages = config.boot.kernelPackages; }
        else if cfg.useUnstable
        then (pkgs.unstable.linuxKernel.packagesFor config.boot.kernelPackages.kernel).nvidiaPackages.${cfg.channel}
        else config.boot.kernelPackages.nvidiaPackages.${cfg.channel};
    };
  };
}
