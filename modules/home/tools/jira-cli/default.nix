{
  lib,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.jira-cli;
in {
  options.tools.jira-cli = {
    enabled = mkBoolOpt false "Whether to enable the Jira CLI tool.";
  };

  config = mkIf cfg.enabled {
    home.packages = with pkgs; [
      jira-cli-go
    ];
  };
}
