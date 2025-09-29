{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.glace.desktop.addons.cliphist;
in {
  options.glace.desktop.addons.cliphist = with types; {
    enable = mkEnableOption "Enable cliphist clipboard manager";
  };

  config = mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      systemdTargets = ["graphical-session.target"];
    };
  };
}
