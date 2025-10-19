{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.gtk-icon-browser;
in {
  options.glace.apps.gtk-icon-browser = {
    enable = mkBoolOpt false "Whether to enable GTK Icon Browser";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.inputs.icon-browser.default];
  };
}
