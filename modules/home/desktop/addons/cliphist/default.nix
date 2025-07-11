{
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.desktop.addons.cliphist;
in {
  options.desktop.addons.cliphist = with types; {
    enable = mkEnableOption "Enable cliphist clipboard manager";
  };

  config = mkIf cfg.enable {
    services.cliphist = {
      enable = true;
      systemdTargets = ["graphical-session.target"];
    };
  };
}
