{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.internal) mkBoolOpt mkOpt;
  cfg = config.system.settings;
in {
  options.system.settings = {
    enable = mkBoolOpt false "Whether or not to manage system settings.";
    dock-apps = mkOpt (lib.types.listOf lib.types.attrs) [] "Default persistent items to show on the dock.";
  };

  config = mkIf cfg.enable {
    system = {
      primaryUser = config.user.name;

      defaults = {
        controlcenter = {
          AirDrop = true;
          BatteryShowPercentage = true;
          Bluetooth = false;
          Display = false;
          FocusModes = true;
          NowPlaying = !config.apps.mediamate.enable;
          Sound = true;
        };

        dock = {
          appswitcher-all-displays = true;
          show-recents = false;
          static-only = false;
          show-process-indicators = true;
          launchanim = true;
          scroll-to-open = true;

          mineffect = "scale";
          minimize-to-application = true;

          autohide = true;
          autohide-delay = 0.24;
          autohide-time-modifier = 1.0;

          # When dragging a file, hover over icon to open
          enable-spring-load-actions-on-all-items = true;
          expose-animation-duration = 0.8;

          # Mission Control
          expose-group-apps = true;
          mru-spaces = false;

          # Folder shortcuts on dock
          persistent-others = [];
          persistent-apps = cfg.dock-apps;
        };

        finder = {
          _FXSortFoldersFirst = true;
          AppleShowAllFiles = true;
          AppleShowAllExtensions = true;
          CreateDesktop = false;
          FXEnableExtensionChangeWarning = false;
          FXPreferredViewStyle = "Nlsv";
          FXRemoveOldTrashItems = true;
          ShowPathbar = true;
        };

        hitoolbox = {
          AppleFnUsageType = "Show Emoji & Symbols";
        };

        iCal = {
          "TimeZone support enabled" = true;
          CalendarSidebarShown = true;
        };

        menuExtraClock = {
          ShowAMPM = true;
        };

        NSGlobalDomain = {
          "com.apple.swipescrolldirection" = true; # natural scrolling
          "com.apple.sound.beep.feedback" = 0; # no beep on volume change

          "AppleInterfaceStyle" = "Dark";
          "AppleInterfaceStyleSwitchesAutomatically" = false;

          "AppleShowScrollBars" = "Automatic";
          "NSScrollAnimationEnabled" = true;
          "AppleSpacesSwitchOnActivate" = true;

          "NSAutomaticCapitalizationEnabled" = true;
          "NSAutomaticDashSubstitutionEnabled" = true;
          "NSAutomaticInlinePredictionEnabled" = false;
          "NSAutomaticPeriodSubstitutionEnabled" = true;
          "NSAutomaticQuoteSubstitutionEnabled" = true;
          "NSAutomaticSpellingCorrectionEnabled" = true;

          "NSAutomaticWindowAnimationsEnabled" = true;
          "NSDisableAutomaticTermination" = true;
          "NSDocumentSaveNewDocumentsToCloud" = false;

          "NSWindowShouldDragOnGesture" = true;
        };

        screencapture = {
          include-date = true;
          target = "preview";
        };

        screensaver = {
          askForPassword = true;
          askForPasswordDelay = 15;
        };

        SoftwareUpdate = {
          AutomaticallyInstallMacOSUpdates = false;
        };

        loginwindow = {
          GuestEnabled = false;
          SHOWFULLNAME = false;
        };

        spaces = {
          spans-displays = false;
        };

        trackpad = {
          Clicking = true;
          TrackpadRightClick = true;
          TrackpadThreeFingerDrag = false;
        };

        WindowManager = {
          AutoHide = true; # auto hide recent apps in stage
          EnableStandardClickToShowDesktop = false;
          EnableTilingOptionAccelerator = true;
          EnableTopTilingByEdgeDrag = true;
          StandardHideDesktopIcons = false;
        };
      };

      keyboard = {
        enableKeyMapping = true;
        remapCapsLockToEscape = true;
      };
    };
  };
}
