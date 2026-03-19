{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkNullableOpt;
  cfg = config.glace.services.openrgb;
in {
  options.glace.services.openrgb = {
    enable = mkBoolOpt false "Whether to enable OpenRGB service.";
    startupProfile = mkNullableOpt types.str null "Startup Profile to load.";
  };

  config = mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      package = pkgs.unstable.openrgb-with-all-plugins;
      startupProfile = cfg.startupProfile;
    };

    # Enable i2c devices for RAM / Motherboard detection
    boot.kernelModules = ["i2c-dev"];
    boot.kernelParams = ["acpi_enforce_resources=lax"];

    glace.system.impermanence.extraDirectories = [
      "/var/lib/OpenRGB"
    ];

    systemd.services.openrgb-resume = mkIf (cfg.startupProfile != null) {
      description = "Restore OpenRGB profile after suspend";
      after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
      wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
      serviceConfig = {
        Type = "oneshot";
        WorkingDirectory = "/var/lib/OpenRGB";
        ExecStart = "${pkgs.unstable.openrgb-with-all-plugins}/bin/openrgb --profile ${cfg.startupProfile}";
      };
    };
  };
}
