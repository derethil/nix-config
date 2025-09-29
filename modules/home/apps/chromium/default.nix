{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with lib.glace; {
  options.glace.apps.chromium = {
    enable = mkBoolOpt false "Whether to enable Chromium";
  };

  config = mkIf config.glace.apps.chromium.enable {
    programs.chromium = {
      enable = true;
      package =
        if config.glace.tools.nixgl.enable
        then config.lib.nixGL.wrap pkgs.chromium
        else pkgs.chromium;
    };
  };
}
