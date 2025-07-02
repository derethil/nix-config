{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.jira-cli;
in {
  options.tools.jira-cli = {
    enable = mkBoolOpt false "Whether to enable the Jira CLI tool.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jira-cli-go
    ];
  };
}
