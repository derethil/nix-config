{
  inputs,
  self,
  ...
}: {
  flake-file.inputs = {
    nvim-config.url = "github:derethil/nvim-config";
  };

  flake.modules.generic.neovim-config = {
    programs.nvim-config = {
      enable = true;

      neovim = {
        defaultEditor = true;
        nightly = false;
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
        };
      };
    };
  };

  flake.modules.nixos.neovim = {...}: {
    imports = [
      inputs.nvim-config.nixosModules.nvim-config
      self.modules.generic.neovim-config
    ];
  };

  flake.modules.darwin.neovim = {...}: {
    imports = [
      inputs.nvim-config.darwinModules.nvim-config
      self.modules.generic.neovim-config
    ];
  };

  flake.modules.homeManager.neovim = {config, ...}: {
    imports = [
      inputs.nvim-config.homeManagerModules.nvim-config
      self.modules.generic.neovim-config
      self.modules.homeManager.mimeapps
    ];

    programs.nvim-config = {
      claude = {
        inherit (config.programs.claude-code) enable package;
      };

      sonarlint.connectedMode.projects = {
        "${config.home.homeDirectory}/development/dragonarmy/vigil" = {
          connectionId = "dragonarmy";
          projectKey = "dragon-army_hatchlab-srt_5a7d51c9-c50c-44fa-bd66-3ce24e000515";
        };
      };

      extraSettings = {
        vim.lsp.servers.nixd.settings.nixd = {
          nixpkgs.expr = "import (builtins.getFlake \"${config.internal.flakeRoot}\").inputs.nixpkgs {}";
          options = {
            nixos.expr = "(builtins.getFlake \"${config.internal.flakeRoot}\").nixosConfigurations.feldspar.options";
            "home-manager".expr = "(builtins.getFlake \"${config.internal.flakeRoot}\").homeConfigurations.\"${config.home.username}@feldspar\".options";
          };
        };
      };
    };

    xdg.mimeApps.defaultApplications = self.lib.mkMimeApps "nvim.desktop" [
      "text/plain"
      "text/markdown"
      "application/json"
      "application/yaml"
      "application/toml"
    ];
  };
}
