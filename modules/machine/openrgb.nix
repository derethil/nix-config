{lib, ...}: {
  flake.modules.nixos.openrgb = {
    config,
    pkgs,
    ...
  }: let
    inherit (lib) getExe mkIf mkOption types;
    cfg = config.internal.services.openrgb;
    pkg = pkgs.unstable.openrgb-with-all-plugins;
  in {
    options.internal.services.openrgb.startupProfile = mkOption {
      default = null;
      description = "Startup profile to load on service start.";
      type = types.nullOr types.str;
    };

    config = {
      boot = {
        # Required for RAM / motherboard detection
        kernelModules = ["i2c-dev"];
        kernelParams = ["acpi_enforce_resources=lax"];
      };

      internal.boot.impermanence.extraDirectories = ["/var/lib/OpenRGB"];

      services.hardware.openrgb = {
        inherit (cfg) startupProfile;
        enable = true;
        package = pkg;
      };

      systemd.services = {
        openrgb-resume = mkIf (cfg.startupProfile != null) {
          after = ["hibernate.target" "hybrid-sleep.target" "suspend.target"];
          description = "Restore OpenRGB profile after suspend";

          serviceConfig = {
            ExecStart = pkgs.writeShellScript "openrgb-resume" ''
              systemctl restart openrgb.service
              sleep 1
              ${getExe pkg} --profile ${cfg.startupProfile}
            '';

            Type = "oneshot";
            WorkingDirectory = "/var/lib/OpenRGB";
          };

          wantedBy = ["hibernate.target" "hybrid-sleep.target" "suspend.target"];
        };

        openrgb-suspend-prep = {
          before = ["systemd-hibernate.service" "systemd-suspend.service"];
          description = "Turn off OpenRGB devices before sleep";

          serviceConfig = {
            ExecStart = "${getExe pkg} --color 000000";
            Type = "oneshot";
          };

          wantedBy = ["hibernate.target" "suspend.target"];
        };
      };
    };
  };
}
