{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf types;
  inherit (lib.glace) mkBoolOpt mkOpt;
  cfg = config.glace.tools.nh;
in {
  options.glace.tools.nh = {
    enable = mkBoolOpt false "Whether to enable nh (Nix helper) configuration.";
    clean.enable = mkBoolOpt true "Whether to enable automatic nh clean service.";
    flake = mkOpt types.str "${config.glace.user.home}/.config/nix-config" "Path to the flake directory.";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = [pkgs.nh];
      variables = {
        NH_FLAKE = cfg.flake;
      };
    };

    launchd.daemons.nh-clean = mkIf cfg.clean.enable {
      script = "${lib.getExe pkgs.nh} clean all --keep-since 7d --keep 3";
      serviceConfig = {
        Label = "nh-clean";
        ProcessType = "Background";
        StartCalendarInterval = [
          {
            Weekday = 0;
            Hour = 0;
            Minute = 0;
          }
        ];
        StartOnMount = true;
        LowPriorityIO = true;
        LowPriorityBackgroundIO = true;
        StandardOutPath = "/var/log/nh-clean.log";
        StandardErrorPath = "/var/log/nh-clean.log";
      };
    };
  };
}
