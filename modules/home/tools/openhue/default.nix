{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
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

    programs.fish.interactiveShellInit = ''
      ${getExe pkgs.openhue-cli} completion fish | source
    '';
  };
}
