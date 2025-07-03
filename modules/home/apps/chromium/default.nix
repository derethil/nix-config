{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; {
  options.apps.chromium = {
    enable = mkBoolOpt false "Whether to enable Chromium";
  };

  config = mkIf config.apps.chromium.enable {
    programs.chromium = {
      enable = true;
      package =
        if config.tools.nixgl.enable
        then config.lib.nixGL.wrap pkgs.chromium
        else pkgs.chromium;
    };
  };
}
