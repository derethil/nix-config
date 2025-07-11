{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.gtk-icon-browser;
in {
  options.apps.gtk-icon-browser = {
    enable = mkBoolOpt false "Whether to enable GTK Icon Browser";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.inputs.icon-browser];
  };
}
