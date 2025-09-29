{
  lib,
  pkgs,
  config,
  ...
}:
with lib;
with glace; let
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
