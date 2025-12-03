{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.openhue;
in {
  options.glace.tools.openhue = {
    enable = mkBoolOpt false "Whether to enable openhue-cli.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      openhue-cli
    ];
  };
}

