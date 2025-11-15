{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (lib.glace) mkBoolOpt;

  cfg = config.glace.desktop.addons.wlsunset;

  wlsunset-auto = pkgs.writeShellApplication {
    name = "wlsunset-auto";

    runtimeInputs = with pkgs; [
      wlsunset
      curl
      jq
    ];

    text = ''
      location=$(curl -s http://ip-api.com/json?fields=lat,lon)
      lat=$(echo "$location" | jq -r '.lat')
      lon=$(echo "$location" | jq -r '.lon')

      exec wlsunset -l "$lat" -L "$lon" "$@"
    '';
  };
in {
  options.glace.desktop.addons.wlsunset = {
    enable = mkBoolOpt false "Whether to enable wlsunset.";

    systemdTarget = lib.mkOption {
      type = lib.types.str;
      default = "graphical-session.target";
      description = "Systemd target to bind the wlsunset service to.";
    };

    temperature = {
      day = lib.mkOption {
        type = lib.types.int;
        default = 6500;
        description = "Colour temperature to use during the day.";
      };

      night = lib.mkOption {
        type = lib.types.int;
        default = 3000;
        description = "Colour temperature to use during the night.";
      };
    };

    gamma = lib.mkOption {
      type = lib.types.float;
      default = 1.0;
      description = "Gamma value to use.";
    };

    output = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "Name of output to use, by default all outputs are used.";
    };
  };

  config = mkIf cfg.enable {
    systemd.user.services.wlsunset = {
      Unit = {
        Description = "Day/night gamma adjustments for Wayland compositors";
        After = [cfg.systemdTarget];
        PartOf = [cfg.systemdTarget];
      };

      Service = {
        Type = "simple";
        Restart = "on-failure";
        RestartSec = 1;
        ExecStart = let
          args = lib.cli.toGNUCommandLineShell {} {
            t = cfg.temperature.night;
            T = cfg.temperature.day;
            g = cfg.gamma;
            o = cfg.output;
          };
        in "${getExe wlsunset-auto} ${args}";
      };

      Install.WantedBy = [cfg.systemdTarget];
    };
  };
}
