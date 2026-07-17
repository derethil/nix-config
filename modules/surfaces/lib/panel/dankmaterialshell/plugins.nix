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
        settings = {
          showPacing = false;
        };
      };

      niriScreenshot = {
        inherit (config.wayland.windowManager.niri) enable;
      };

      dankActions = {
        inherit (config.wayland.windowManager.niri) enable;
        settings = {
          variants = [
            {
              id = "variant_cast_window";
              name = "Cast Window";
              icon = "cast";
              showText = false;
              clickCommand = "niri msg action set-dynamic-cast-window --id $(niri msg --json pick-window | ${getExe pkgs.jq} -r .id)";
              visibilityCommand = "niri msg --json casts | ${getExe pkgs.jq} -e 'any(.is_dynamic_target == true)'";
              visibilityInterval = 1;
            }
          ];
        };
      };

      easyEffects = {
        enable = config.services.easyeffects.enable || (self.lib.hasPackage config.home.packages "easyeffects");
      };

      nixPackageRunner = {
        enable = true;
        settings = {
          terminal = concatStrings config.terminal.commands.base;
          execFlag = "-e";
        };
      };

      webSearch = {
        enable = true;
        settings = {
          trigger = "?";
          searchEngines = [];
          disabledEngines = [
            "aur"
            "archlinux"
            "bing"
            "kagi"
            "brave"
            "duckduckgo"
          ];
        };
      };

      emojiLauncher = {
        enable = true;
      };

      systemMonitorPlus = {
        enable = true;
        settings = {
          resourceOrder = "cpuTemp,gpuTemp,ramUsage,cpuUsage,diskPartitionUsage,networkSpeed";
          cpuUsageEnabled = false;

          cpuTempEnabled = true;
          cpuTempVisualStyle = "gauge";
          cpuTempIconName = "memory";
          cpuTempWarningThreshold = 60;
          cpuTempDangerThreshold = 75;
          cpuTempProgressMaxValue = 100;

          gpuTempEnabled = true;
          gpuTempVisualStyle = "gauge";
          gpuTempWarningThreshold = 60;
          gpuTempDangerThreshold = 75;
          gpuTempProgressMaxValue = 100;

          ramUsageEnabled = true;
          ramUsageVisualStyle = "gauge";
        };
      };

      hueManager = {
        enable = true;
        settings = {
          openHuePath = "openhue";
          useDeviceIcons = true;
          syncRoomIds = [
            "ee53b611-782f-435a-bec0-a3135cae771a"
            "bbc69f6f-f959-4efd-a46d-a9996de111f0"
            "96fee890-6752-4ff3-a6a6-e3a8781db180"
            "ce9dc0c6-a60e-447d-bde4-ce09b035893c"
          ];
          autoSyncAccent = false;
        };
      };
    };
  };
}
