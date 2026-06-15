{self, ...}: {
  flake.modules.darwin.mediamate = {config, ...}: {
    imports = [
      self.modules.darwin.secrets
      self.modules.darwin.keychain
    ];

    system.defaults.controlcenter.NowPlaying = false;

    sops.secrets."applications/mediamate/license_key" = {};

    internal.system.keychain.entries = [
      {
        secretFile = config.sops.secrets."applications/mediamate/license_key".path;
        service = "com.tweety.MediaMate";
        account = "license";
        comment = "MediaMate license key";
        trustedApp = "/Applications/MediaMate.app";
      }
    ];

    system.defaults.CustomUserPreferences = {
      "com.tweety.MediaMate" = {
        LSUIElement = true;
        SUAutomaticallyUpdate = true;
        SUEnableAutomaticChecks = true;
        SUSendProfileInfo = false;

        # Volume
        listenToExternalChanges = true;

        # HUD Settings
        hideNativeHUDsForAudio = "{\"name\":\"Lunar\"}";
        hideNativeHUDsForBrightness = "{\"name\":\"Lunar\"}";
        compactHUDVisibilityMode = 1;
        showOnScreenBehavior = 0;

        # Now Playing Settings
        nowPlayingAlwaysUseNotchScreen = false;
        nowPlayingCaptureKeys = true;
        nowPlayingHideSongTitleExtras = false;
        nowPlayingNotchThemeButtons = 7;
        nowPlayingShowCloseButton = false;
        nowPlayingShowOnChange = 2;
        nowPlayingShowOnLockscreen = 0;
        nowPlayingShowOnPause = false;
        nowPlayingShowOnPlay = false;
        nowPlayingShowOnVolumeChange = false;
        nowPlayingHideDelay = 3;
        nowPlayingTheme = "{\"all\":{\"_0\":{\"notch\":{}}}}";
        nowPlayingUseScriptingBridge = true;

        # Display Settings
        notchUseMenubarHeightOnNormalDisplays = false;

        # Theme Settings
        theme = "{\"all\":{\"_0\":\"notch\"}}";

        # UI Settings
        settingsTabSelection = 4;
        styleTabSelection = 1;
        showMenuBarIcon = false;

        # Launch Settings
        hasLaunchedBefore = true;
      };
    };
  };
}
