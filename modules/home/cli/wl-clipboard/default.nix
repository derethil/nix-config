{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.cli.wl-clipboard;
in {
  options.glace.cli.wl-clipboard = {
    enable = mkBoolOpt false "Whether to enable wl-clipboard.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.wl-clipboard];
    glace.cli.aliases = {
      wcl = "wl-copy";
    };
  };
}
