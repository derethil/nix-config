{
  lib,
  pkgs,
  config,
  ...
}: let
  inherit (lib) mkIf getExe';
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.development.jira-cli;
in {
  options.glace.tools.development.jira-cli = {
    enable = mkBoolOpt false "Whether to enable the Jira CLI tool.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      jira-cli-go
    ];

    secrets."home/tools/jira_cli/api_token" = {};

    home.sessionVariables.JIRA_API_TOKEN = "$(${getExe' pkgs.coreutils "cat"} ${config.sops.secrets."home/tools/jira_cli/api_token".path})";
  };
}
