{
  flake.modules.homeManager.dankmaterialshell-panel = {config, ...}: {
    programs.dank-material-shell.settings = {
      acLockTimeout = 600;
      acSuspendTimeout = 900;
      animationSpeed = 2;

      appIdSubstitutions = [
        {
          pattern = "Spotify";
          replacement = "spotify";
          type = "exact";
        }
        {
          pattern = "^steam_app_(\\d+)$";
          replacement = "steam_icon_$1";
          type = "regex";
        }
        {
          pattern = "com.mojang.minecraft";
          replacement = "minecraft";
          type = "exact";
        }
        {
          pattern = "com.transmissionbt.transmission";
          replacement = "transmission-gtk";
          type = "contains";
        }
      ];

      appLauncherViewMode = "grid";

      barConfigs = [
        {
          autoHide = false;
          autoHideDelay = 250;
          borderColor = "surfaceText";
          borderEnabled = false;
          borderOpacity = 1;
          borderThickness = 1;
          bottomGap = 0;

          centerWidgets = [
            {
              enabled = true;
              id = "music";
            }
            {
              enabled = true;
              id = "clock";
            }
            {
              enabled = true;
              id = "dankCalendarAgenda";
            }
            {
              enabled = true;
              id = "weather";
            }
          ];

          enabled = true;
          fontScale = 1;
          gothCornerRadiusOverride = false;
          gothCornerRadiusValue = 64;
          gothCornersEnabled = true;
          hoverPopoutDelay = 150;
          hoverPopouts = false;
          id = "default";
          innerPadding = 8;

          leftWidgets = [
            {
              enabled = true;
              id = "launcherButton";
            }
            {
              enabled = true;
              id = "workspaceSwitcher";
            }
            {
              enabled = true;
              id = "hueManager";
            }
            {
              enabled = true;
              id = "privacyIndicator";
            }
            {
              enabled = true;
              id = "dankActions:variant_cast_window";
            }
          ];

          name = "Main Bar";
          noBackground = false;
          openOnOverview = true;
          popupGapsAuto = true;
          popupGapsManual = 50;
          position = 2;

          rightWidgets = [
            {
              enabled = true;
              id = "claudeCodeUsage";
            }
            {
              enabled = true;
              id = "systemMonitorPlus";
            }
            {
              enabled = true;
              id = "easyEffects";
            }
            {
              enabled = true;
              id = "controlCenterButton";
            }
            {
              enabled = true;
              id = "notificationButton";
            }
            {
              enabled = true;
              id = "powerMenuButton";
            }
          ];

          screenPreferences = ["all"];
          shadowIntensity = 0;
          showOnLastDisplay = true;
          spacing = 0;
          squareCorners = true;
          transparency = 1;
          visible = true;
          widgetTransparency = 1;
          attachToScreenEdge = false;
        }
      ];

      barElevationEnabled = false;
      blurBorderOpacity = 0;
      blurWallpaperOnOverview = true;
      builtInPluginSettings.dms_settings_search.trigger = "?";
      clockDateFormat = "ddd MMM d";
      clockFormat = "12h";
      configVersion = 18;
      controlCenterShowVpnIcon = false;

      controlCenterWidgets = [
        {
          enabled = true;
          id = "volumeSlider";
          width = 50;
        }
        {
          enabled = true;
          id = "idleInhibitor";
          width = 25;
        }
        {
          enabled = true;
          id = "doNotDisturb";
          width = 25;
        }
        {
          enabled = true;
          id = "wifi";
          width = 50;
        }
        {
          enabled = true;
          id = "bluetooth";
          width = 50;
        }
        {
          enabled = true;
          id = "audioOutput";
          width = 50;
        }
        {
          enabled = true;
          id = "audioInput";
          width = 50;
        }
        {
          enabled = true;
          id = "plugin_niriScreenshot";
          width = 50;
        }
        {
          enabled = true;
          id = "colorPicker";
          width = 50;
        }
      ];

      cornerRadius = 9;
      currentThemeCategory = "registry";
      currentThemeName = "custom";

      cursorSettings = {
        dwl.cursorHideTimeout = 0;

        hyprland = {
          hideOnKeyPress = false;
          hideOnTouch = false;
          inactiveTimeout = 0;
        };

        niri = {
          hideAfterInactiveMs = 0;
          hideWhenTyping = false;
        };

        size = 24;
        theme = "System Default";
      };

      customThemeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/themes/retrobox/theme.json";
      dankLauncherV2Size = "medium";

      desktopClockCustomColor = {
        a = 1;
        b = 1;
        g = 1;
        hslHue = -1;
        hslLightness = 1;
        hslSaturation = 0;
        hsvHue = -1;
        hsvSaturation = 0;
        hsvValue = 1;
        r = 1;
        valid = true;
      };

      displayNameMode = "model";
      dockAutoHide = true;
      dockBorderOpacity = 0.5;
      dockGroupByApp = true;
      dockIconSize = 48;
      dockIndicatorStyle = "line";
      dockOpenOnOverview = true;
      dockShowTrash = true;
      dockTrashCustomCommand = "xdg-terminal-exec --app-id=yazi yazi ~/.local/share/Trash/files";
      fadeToLockGracePeriod = 15;
      firstDayOfWeek = 0;
      fontFamily = "Inter Medium";
      keyboardLayoutNameCompactMode = true;
      launcherLogoColorOverride = "#00bcd4";
      launcherLogoMode = "os";
      launcherPluginVisibility.dms_settings_search.allowWithoutTrigger = false;
      lockBeforeSuspend = true;
      lockScreenNotificationMode = 2;
      matugenTemplateNeovim = true;
      maxFprintTries = 3;
      monoFontFamily = "GeistMono NF";
      networkPreference = "wifi";
      notepadLastCustomTransparency = 0.5;
      notepadShowLineNumbers = true;
      notificationOverlayEnabled = true;
      notificationPopupPosition = -1;

      notificationRules = [
        {
          action = "ignore";
          enabled = true;
          field = "appName";
          matchType = "contains";
          pattern = "Spotify";
          urgency = "default";
        }
      ];

      osdAlwaysShowValue = true;
      osdMediaPlaybackEnabled = true;
      osdPowerProfileEnabled = true;
      padHours12Hour = true;
      powerActionHoldDuration = 0.75;

      registryThemeVariants = {
        flexoki = "green";
        gruvboxMaterial = "hard";
        petrichor = "green";
      };

      runningAppsCompactMode = false;
      runningAppsCurrentWorkspace = false;
      screenPreferences.wallpaper = ["all"];
      showDock = true;
      showOccupiedWorkspacesOnly = true;
      showWorkspaceApps = true;
      showWorkspacePadding = true;
      spotlightSectionViewModes.apps = "list";

      systemMonitorCustomColor = {
        a = 1;
        b = 1;
        g = 1;
        hslHue = -1;
        hslLightness = 1;
        hslSaturation = 0;
        hsvHue = -1;
        hsvSaturation = 0;
        hsvValue = 1;
        r = 1;
        valid = true;
      };

      useAutoLocation = true;
      useFahrenheit = true;
      workspaceActiveAppHighlightEnabled = true;
    };
  };
}
