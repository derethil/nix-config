{
  config,
  lib,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.cli.wl-clipboard;
in {
  options.cli.wl-clipboard = {
    enable = mkBoolOpt false "Whether to enable wl-clipboard.";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.wl-clipboard];
    cli.aliases = {
      wcl = "wl-copy";
    };
  };
}
