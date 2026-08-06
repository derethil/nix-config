{self, ...}: {
  flake.modules.homeManager.jira-cli = {
    config,
    lib,
    pkgs,
    ...
  }: {
    imports = [
      self.modules.homeManager.secrets
    ];

    home = {
      packages = [
        pkgs.jira-cli-go
      ];

      sessionVariables.JIRA_API_TOKEN = "$(${lib.getExe' pkgs.coreutils "cat"} ${config.sops.secrets."pursuits/development/jira_cli/api_token".path})";
    };

    sops.secrets."pursuits/development/jira_cli/api_token" = {};
  };
}
