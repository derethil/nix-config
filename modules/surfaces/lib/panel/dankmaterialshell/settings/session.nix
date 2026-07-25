{self, ...}: {
  flake.modules.homeManager.dankmaterialshell-panel = {config, ...}: let
    wallpaperPath = "${config.internal.wallpaper.targetDir}/${config.internal.primaryDisplay.wallpaper}";
  in {
    imports = [self.modules.homeManager.wallpaper];

    programs.dank-material-shell.session = {
      inherit wallpaperPath;
      appDrawerLastMode = "apps";
      appOverrides = {};
      barPinnedApps = [];
      brightnessExponentValues = {};
      brightnessExponentialDevices = {};
      brightnessUserSetValues = {};
      configVersion = 3;
      deviceMaxVolumes = {};
      doNotDisturb = false;
      doNotDisturbUntil = 0;
      dockLauncherPosition = 0;
      enabledGpuPciIds = [];
      hiddenApps = [];
      hiddenInputDeviceNames = [];
      hiddenOutputDeviceNames = [];

      hiddenTrayIds = [
        ".openrgb-wrapped::OpenRGB"
        "easyeffects"
        "easyeffects::Easy Effects"
        "spotify-client"
      ];

      includedTransitions = [
        "disc"
        "fade"
        "iris bloom"
        "pixelate"
        "portal"
        "stripes"
        "wipe"
      ];

      isLightMode = false;
      lastBrightnessDevice = "";
      lastPlayerIdentity = "Spotify";
      latitude = 0;
      launchPrefix = "";
      launcherLastFileSearchType = "all";
      launcherLastMode = "all";
      launcherLastQuery = "";
      launcherQueryHistory = [""];
      locale = "";
      longitude = 0;
      monitorCyclingSettings = {};
      monitorWallpaperFillModes = {};
      monitorWallpapers = {};
      monitorWallpapersDark = {};
      monitorWallpapersLight = {};
      nightModeAutoEnabled = true;
      nightModeAutoMode = "location";
      nightModeEnabled = false;
      nightModeEndHour = 6;
      nightModeEndMinute = 0;
      nightModeHighTemperature = 6500;
      nightModeLocationProvider = "";
      nightModeStartHour = 18;
      nightModeStartMinute = 0;
      nightModeTemperature = 3000;
      nightModeUseIPLocation = true;
      niriOverviewLastMode = "apps";
      nonNvidiaGpuTempEnabled = false;
      notepadLastMode = "";
      nvidiaGpuTempEnabled = false;
      perModeWallpaper = false;
      perMonitorWallpaper = false;

      pinnedApps = [
        "Mattermost"
        "Spotify"
        "bruno"
        "firefox"
        "footclient"
        "obsidian"
        "prismlauncher"
        "steam"
        "stremio"
        "vesktop"
      ];

      pluginBrowserInstalledFirst = false;
      pluginBrowserSortMode = "default";
      recentColors = ["#d0bcff"];
      searchAppActions = true;
      selectedGpuIndex = 0;
      settingsSidebarCollapsedIds = "";
      settingsSidebarExpandedIds = "";
      showThirdPartyPlugins = true;
      terminalOverride = "";
      themeModeAutoEnabled = false;
      themeModeAutoMode = "time";
      themeModeEndHour = 6;
      themeModeEndMinute = 0;
      themeModeShareGammaSettings = true;
      themeModeStartHour = 18;
      themeModeStartMinute = 0;
      timeLocale = "";
      trayItemOrder = [];
      vpnLastConnected = "";
      wallpaperCyclingEnabled = false;
      wallpaperCyclingInterval = 300;
      wallpaperCyclingMode = "interval";
      wallpaperCyclingTime = "06:00";
      wallpaperPathDark = wallpaperPath;
      wallpaperPathLight = wallpaperPath;
      wallpaperTransition = "iris bloom";
      weatherCoordinates = "";
      weatherHourlyDetailed = true;
      weatherLocation = "";
      wifiDeviceOverride = "";
    };
  };
}
