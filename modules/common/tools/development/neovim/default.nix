{
  config,
  lib,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.tools.development.neovim;
in {
  options.glace.tools.development.neovim = {
    enable = mkBoolOpt false "Whether to enable Neovim.";
  };

  config = mkIf cfg.enable {
    programs.nvim-config = {
      enable = true;
      neovim = {
        defaultEditor = true;
        nightly = false;
      };
      claude = {
        enable = true;
        package = pkgs.claude-code;
      };
      sonarlint = {
        enable = true;
        connectedMode = {
          enable = true;
          connections.sonarqube = [
            {
              connectionId = "dragonarmy";
              serverUrl = "https://sonarqube.dragonarmy.rocks";
              disableNotifications = false;
            }
          ];
          projects = {
            "${config.glace.user.home or config.home.homeDirectory}/development/dragonarmy/vigil" = {
              connectionId = "dragonarmy";
              projectKey = "dragon-army_hatchlab-srt_5a7d51c9-c50c-44fa-bd66-3ce24e000515";
            };
          };
        };
      };
    };

    glace.desktop.xdg.mimeapps.default = lib.glace.mkMimeApps "nvim.desktop" [
      "text/plain"
      "text/markdown"
      "application/json"
      "application/yaml"
      "application/toml"
    ];
  };
}
