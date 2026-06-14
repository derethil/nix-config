{lib, ...}: {
  flake.modules.nixos.openrgb = {
    pkgs,
    config,
    ...
  }: let
    inherit (lib) mkOption mkIf types getExe;
    cfg = config.internal.services.openrgb;
    pkg = pkgs.unstable.openrgb-with-all-plugins;
  in {
    options.internal.services.openrgb.startupProfile = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Startup profile to load on service start.";
    };

    config = {
      services.hardware.openrgb = {
        enable = true;
        package = pkg;
        startupProfile = cfg.startupProfile;
      };

      # Required for RAM / motherboard detection
      boot.kernelModules = ["i2c-dev"];
      boot.kernelParams = ["acpi_enforce_resources=lax"];

      internal.boot.impermanence.extraDirectories = ["/var/lib/OpenRGB"];

      systemd.services.openrgb-suspend-prep = {
        description = "Turn off OpenRGB devices before sleep";
        before = ["systemd-suspend.service" "systemd-hibernate.service"];
        wantedBy = ["suspend.target" "hibernate.target"];
        serviceConfig = {
          Type = "oneshot";
          ExecStart = "${getExe pkg} --color 000000";
        };
      };

      systemd.services.openrgb-resume = mkIf (cfg.startupProfile != null) {
        description = "Restore OpenRGB profile after suspend";
        after = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
        wantedBy = ["suspend.target" "hibernate.target" "hybrid-sleep.target"];
        serviceConfig = {
          Type = "oneshot";
          WorkingDirectory = "/var/lib/OpenRGB";
          ExecStart = pkgs.writeShellScript "openrgb-resume" ''
            systemctl restart openrgb.service
            sleep 1
            ${getExe pkg} --profile ${cfg.startupProfile}
          '';
        };
      };
    };
  };
}
