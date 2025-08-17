{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt;
  cfg = config.tools.neovim;
in {
  options.tools.neovim = {
    enable = mkBoolOpt false "Whether to enable Neovim.";
  };

  config = mkIf cfg.enable {
    secrets = {
      "neovim/sonar_token" = {};
    };
    programs.nvim-config = {
      enable = true;
      defaultEditor = true;
      claude = {
        enable = true;
        package = pkgs.claude-code;
      };
      sonarlint = {
        enable = true;
        enabledPaths = ["${config.home.homeDirectory}/development/dragonarmy/"];
        connectedMode = {
          enable = true;
          tokenFile = config.sops.secrets."neovim/sonar_token".path;
          sonarqubeConnections = [
            {
              connectionId = "dragonarmy";
              serverUrl = "https://sonarqube.dragonarmy.rocks";
              disableNotifications = false;
            }
          ];
          projects = {
            "${config.home.homeDirectory}/development/dragonarmy/hatchlab-srt" = {
              connectionId = "dragonarmy";
              projectKey = "dragon-army_hatchlab-srt_5a7d51c9-c50c-44fa-bd66-3ce24e000515";
            };
            "${config.home.homeDirectory}/development/dragonarmy/hatchlab-rift" = {
              connectionId = "dragonarmy";
              projectKey = "dragon-army_deep-pnt-dashboard_2e16c7bd-9b52-477e-a99d-3fabaa212a08";
            };
          };
        };
      };
    };
  };
}
