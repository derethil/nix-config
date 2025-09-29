{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.addons.cliphist;
in {
  options.glace.desktop.addons.cliphist = {
    enable = mkBoolOpt false "Enable cliphist clipboard manager";
  };

  config = mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      systemdTargets = ["graphical-session.target"];
    };
  };
}
