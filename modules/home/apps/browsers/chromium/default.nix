{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.browsers.chromium;
in {
  options.glace.apps.browsers.chromium = {
    enable = mkBoolOpt false "Whether to enable Chromium";
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package =
        if config.glace.tools.nix.nixgl.enable
        then config.lib.nixGL.wrap pkgs.chromium
        else pkgs.chromium;
    };
  };
}
