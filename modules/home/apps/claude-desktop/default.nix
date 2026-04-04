{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.claude-desktop;
in {
  options.glace.apps.claude-desktop = {
    enable = mkBoolOpt false "Whether to enable Claude Desktop";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.inputs.claude-desktop.claude-desktop-with-fhs];
  };
}
