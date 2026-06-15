{self, ...}: {
  flake.modules.homeManager.dankmaterialshell-panel = {config, ...}: let
    wallpaperPath = "${config.internal.wallpaper.targetDir}/${config.internal.primaryDisplay.wallpaper}";
  in {
    imports = [self.modules.homeManager.wallpaper];

    programs.dank-material-shell.session = {
      isLightMode = false;
      doNotDisturb = false;
      doNotDisturbUntil = 0;
      terminalOverride = "";
      wallpaperPath = wallpaperPath;
      perMonitorWallpaper = false;
      monitorWallpapers = {};
      perModeWallpaper = false;
      wallpaperPathLight = wallpaperPath;
      wallpaperPathDark = wallpaperPath;
      monitorWallpapersLight = {};
      monitorWallpapersDark = {};
      monitorWallpaperFillModes = {};
      wallpaperTransition = "iris bloom";
      includedTransitions = [
        "fade"
        "disc"
        "stripes"
        "iris bloom"
        "pixelate"
        "portal"
        "wipe"
      ];
      wallpaperCyclingEnabled = false;
      wallpaperCyclingMode = "interval";
      wallpaperCyclingInterval = 300;
      wallpaperCyclingTime = "06:00";
      monitorCyclingSettings = {};
      nightModeEnabled = false;
      nightModeTemperature = 3000;
      nightModeHighTemperature = 6500;
      nightModeAutoEnabled = true;
      nightModeAutoMode = "location";
      nightModeStartHour = 18;
      nightModeStartMinute = 0;
      nightModeEndHour = 6;
      nightModeEndMinute = 0;
      latitude = 0;
      longitude = 0;
      nightModeUseIPLocation = true;
      nightModeLocationProvider = "";
      themeModeAutoEnabled = false;
      themeModeAutoMode = "time";
      themeModeStartHour = 18;
      themeModeStartMinute = 0;
      themeModeEndHour = 6;
      themeModeEndMinute = 0;
      themeModeShareGammaSettings = true;
      weatherLocation = "Denver, Colorado";
      weatherCoordinates = "39.7392364,-104.9848620";
      pinnedApps = [
        "footclient"
        "firefox"
        "vesktop"
        "Mattermost"
        "bruno"
        "obsidian"
        "steam"
        "prismlauncher"
        "Spotify"
        "stremio"
      ];
      barPinnedApps = [];
      dockLauncherPosition = 0;
      hiddenTrayIds = [
        "easyeffects"
        "spotify-client"
        ".openrgb-wrapped::OpenRGB"
        "easyeffects::Easy Effects"
      ];
      trayItemOrder = [];
      recentColors = ["#d0bcff"];
      showThirdPartyPlugins = true;
      pluginBrowserInstalledFirst = false;
      pluginBrowserSortMode = "default";
      launchPrefix = "";
      lastBrightnessDevice = "";
      brightnessExponentialDevices = {};
      brightnessUserSetValues = {};
      brightnessExponentValues = {};
      selectedGpuIndex = 0;
      nvidiaGpuTempEnabled = false;
      nonNvidiaGpuTempEnabled = false;
      enabledGpuPciIds = [];
      wifiDeviceOverride = "";
      weatherHourlyDetailed = true;
      hiddenApps = [];
      appOverrides = {};
      searchAppActions = true;
      vpnLastConnected = "";
      lastPlayerIdentity = "Spotify";
      deviceMaxVolumes = {};
      hiddenOutputDeviceNames = [];
      hiddenInputDeviceNames = [];
      locale = "";
      timeLocale = "";
      launcherLastMode = "all";
      launcherLastFileSearchType = "all";
      launcherLastQuery = "";
      launcherQueryHistory = [];
      appDrawerLastMode = "apps";
      niriOverviewLastMode = "apps";
      settingsSidebarExpandedIds = ",dock_launcher,";
      settingsSidebarCollapsedIds = ",";
      configVersion = 3;
    };
  };
}
