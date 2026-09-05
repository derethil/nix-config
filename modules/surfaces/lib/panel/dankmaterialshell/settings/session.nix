{self, ...}: {
  flake.modules.homeManager.dankmaterialshell-panel = {config, ...}: let
    wallpaperPath = "${config.internal.wallpaper.targetDir}/${config.internal.primaryDisplay.wallpaper}";
  in {
    imports = [self.modules.homeManager.wallpaper];

    programs.dank-material-shell.session = {
      inherit wallpaperPath;
      configVersion = 4;

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

      lastPlayerIdentity = "Mozilla firefox";
      launcherQueryHistory = ["stea" "fir" ""];
      nightModeAutoEnabled = true;
      nightModeAutoMode = "location";
      nightModeTemperature = 3000;
      nightModeUseIPLocation = true;

      pinnedApps = [
        "footclient"
        "firefox"
        "vesktop"
        "Mattermost.Desktop"
        "bruno"
        "obsidian"
        "steam"
        "prismlauncher"
        "Spotify"
        "com.stremio.Stremio"
      ];

      recentColors = ["#d0bcff"];
      settingsSidebarCollapsedIds = "";
      settingsSidebarExpandedIds = "";
      showThirdPartyPlugins = true;
      wallpaperPathDark = wallpaperPath;
      wallpaperPathLight = wallpaperPath;
      wallpaperTransition = "iris bloom";
      weatherCoordinates = "";
      weatherLocation = "";
    };
  };
}
