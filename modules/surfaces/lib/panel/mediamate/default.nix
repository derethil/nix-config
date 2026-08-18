{self, ...}: {
  flake.modules.darwin.mediamate = {
    config,
    pkgs,
    ...
  }: {
    imports = [
      self.modules.darwin.keychain
      self.modules.darwin.secrets
    ];

    environment.systemPackages = [pkgs.internal.mediamate];

    internal.system.keychain.entries = [
      {
        account = "license";
        comment = "MediaMate license key";
        secretFile = config.sops.secrets."surfaces/mediamate/license_key".path;
        service = "com.tweety.MediaMate";
        trustedApp = "/Applications/MediaMate.app";
      }
    ];

    sops.secrets."surfaces/mediamate/license_key" = {};

    system.defaults = {
      CustomUserPreferences."com.tweety.MediaMate" = {
        LSUIElement = true;
        SUAutomaticallyUpdate = true;
        SUEnableAutomaticChecks = true;
        SUSendProfileInfo = false;
        compactHUDVisibilityMode = 1;
        # Launch Settings
        hasLaunchedBefore = true;
        # HUD Settings
        hideNativeHUDsForAudio = "{\"name\":\"Keyboard\"}";
        hideNativeHUDsForBrightness = "{\"name\":\"Keyboard\"}";
        # Volume
        listenToExternalChanges = true;
        # Display Settings
        notchUseMenubarHeightOnNormalDisplays = false;
        # Now Playing Settings
        nowPlayingAlwaysUseNotchScreen = false;
        nowPlayingCaptureKeys = true;
        nowPlayingHideDelay = 3;
        nowPlayingHideSongTitleExtras = false;
        nowPlayingNotchThemeButtons = 7;
        nowPlayingShowCloseButton = false;
        nowPlayingShowOnChange = 2;
        nowPlayingShowOnLockscreen = 0;
        nowPlayingShowOnPause = false;
        nowPlayingShowOnPlay = false;
        nowPlayingShowOnVolumeChange = false;
        nowPlayingTheme = "{\"all\":{\"_0\":{\"notch\":{}}}}";
        nowPlayingUseScriptingBridge = true;
        # UI Settings
        settingsTabSelection = 4;
        showMenuBarIcon = false;
        showOnScreenBehavior = 0;
        styleTabSelection = 1;
        # Theme Settings
        theme = "{\"all\":{\"_0\":\"notch\"}}";
      };

      controlcenter.NowPlaying = false;
    };
  };
}
