{
  self,
  lib,
  ...
}: let
  inherit (lib) concatStrings getExe;
in {
  flake.modules.homeManager.dankmaterialshell-panel = {
    config,
    pkgs,
    ...
  }: {
    imports = [self.modules.homeManager.openhue];

    programs.dank-material-shell.plugins = {
      claudeCodeUsage = {
        inherit (config.programs.claude-code) enable;
        settings.showPacing = false;
      };

      dankActions = {
        inherit (config.wayland.windowManager.niri) enable;

        settings.variants = [
          {
            clickCommand = "niri msg action set-dynamic-cast-window --id $(niri msg --json pick-window | ${getExe pkgs.jq} -r .id)";
            icon = "cast";
            id = "variant_cast_window";
            name = "Cast Window";
            showText = false;
            visibilityCommand = "niri msg --json casts | ${getExe pkgs.jq} -e 'any(.is_dynamic_target == true)'";
            visibilityInterval = 1;
          }
        ];
      };

      easyEffects.enable = config.services.easyeffects.enable || (self.lib.hasPackage config.home.packages "easyeffects");
      emojiLauncher.enable = true;

      hueManager = {
        enable = true;

        settings = {
          autoSyncAccent = false;
          openHuePath = "openhue";

          syncRoomIds = [
            "96fee890-6752-4ff3-a6a6-e3a8781db180"
            "bbc69f6f-f959-4efd-a46d-a9996de111f0"
            "ce9dc0c6-a60e-447d-bde4-ce09b035893c"
            "ee53b611-782f-435a-bec0-a3135cae771a"
          ];

          useDeviceIcons = true;
        };
      };

      niriScreenshot = {
        inherit (config.wayland.windowManager.niri) enable;
      };

      nixPackageRunner = {
        enable = true;

        settings = {
          execFlag = "-e";
          terminal = concatStrings config.terminal.commands.base;
        };
      };

      systemMonitorPlus = {
        enable = true;

        settings = {
          cpuTempDangerThreshold = 75;
          cpuTempEnabled = true;
          cpuTempIconName = "memory";
          cpuTempProgressMaxValue = 100;
          cpuTempVisualStyle = "gauge";
          cpuTempWarningThreshold = 60;
          cpuUsageEnabled = false;
          gpuTempDangerThreshold = 75;
          gpuTempEnabled = true;
          gpuTempProgressMaxValue = 100;
          gpuTempVisualStyle = "gauge";
          gpuTempWarningThreshold = 60;
          ramUsageEnabled = true;
          ramUsageVisualStyle = "gauge";
          resourceOrder = "cpuTemp,gpuTemp,ramUsage,cpuUsage,diskPartitionUsage,networkSpeed";
        };
      };

      webSearch = {
        enable = true;

        settings = {
          disabledEngines = [
            "archlinux"
            "aur"
            "bing"
            "brave"
            "duckduckgo"
            "kagi"
          ];

          searchEngines = [];
          trigger = "?";
        };
      };
    };
  };
}
