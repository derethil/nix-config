{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.jira-cli;
in {
  options.glace.tools.jira-cli = {
    enable = mkBoolOpt false "Whether to enable the Jira CLI tool.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jira-cli-go
    ];
  };
}
