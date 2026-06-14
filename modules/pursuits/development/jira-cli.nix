{self, ...}: {
  flake.modules.homeManager.jira-cli = {
    config,
    pkgs,
    lib,
    ...
  }: {
    imports = [
      self.modules.homeManager.secrets
    ];

    sops.secrets."applications/jira_cli/api_token" = {};

    home.packages = [
      pkgs.jira-cli-go
    ];

    home.sessionVariables = {
      JIRA_API_TOKEN = "$(${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."applications/jira_cli/api_token".path})";
    };
  };
}
