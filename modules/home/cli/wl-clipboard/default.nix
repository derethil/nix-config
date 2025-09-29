{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
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
