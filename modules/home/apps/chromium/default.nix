{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.chromium;
in {
  options.glace.apps.chromium = {
    enable = mkBoolOpt false "Whether to enable Chromium";
  };

  config = mkIf cfg.enable {
    programs.chromium = {
      enable = true;
      package =
        if config.glace.tools.nixgl.enable
        then config.lib.nixGL.wrap pkgs.chromium
        else pkgs.chromium;
    };
  };
}
