{
  flake.modules.homeManager.dankmaterialshell-panel = {config, ...}: {
    programs.dank-material-shell.settings = {
      acLockTimeout = 600;
      acSuspendTimeout = 900;
      animationDuration = 500;

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

      barConfigs = [
        {
          attachToScreenEdge = false;
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
              clockDateOrder = "timeFirst";
              clockCompactMode = true;
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
              showWorkspacePadding = true;
              showWorkspaceApps = true;
              showOccupiedWorkspacesOnly = true;
              workspaceActiveAppHighlightEnabled = true;
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
              id = "aiOverviewControl";
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
              showVpnIcon = false;
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
          followInterfaceStyle = true;
        }
      ];

      barElevationEnabled = false;
      blurBorderOpacity = 0;
      blurWallpaperOnOverview = true;
      builtInPluginSettings = {
        dms_settings_search.trigger = "?";
        dms_clipboard_search.trigger = "cb";
        dms_power.trigger = "pw";
        dms_qr_generator.trigger = "qrg";
      };
      clockDateFormat = "ddd MMM d";
      configVersion = 28;

      controlCenterWidgets = [
        {
          enabled = true;
          id = "volumeSlider";
          w = 4;
          h = 1;
        }
        {
          enabled = true;
          id = "idleInhibitor";
          w = 2;
          h = 1;
        }
        {
          enabled = true;
          id = "doNotDisturb";
          w = 2;
          h = 1;
        }
        {
          enabled = true;
          id = "wifi";
          w = 4;
          h = 1;
        }
        {
          enabled = true;
          id = "bluetooth";
          w = 4;
          h = 1;
        }
        {
          enabled = true;
          id = "audioOutput";
          w = 4;
          h = 1;
        }
        {
          enabled = true;
          id = "audioInput";
          w = 4;
          h = 1;
        }
        {
          enabled = true;
          id = "plugin_niriScreenshot";
          w = 4;
          h = 1;
        }
        {
          enabled = true;
          id = "colorPicker";
          w = 4;
          h = 1;
        }
      ];

      radiusStrength = 28;
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

      dashTabs = [
        {
          id = "overview";
          enabled = true;
        }
        {
          id = "media";
          enabled = true;
        }
        {
          id = "wallpaper";
          enabled = true;
        }
        {
          id = "weather";
          enabled = true;
        }
        {
          id = "notifications";
          enabled = true;
        }
      ];

      displayNameMode = "model";
      dockConfigs = [
        {
          id = "dock";
          name = "Dock";
          enabled = true;
          screenPreferences = ["all"];
          showOnLastDisplay = true;
          position = 1;
          mode = "compact";
          taskbarAlign = "center";
          widgetExpansion = "popout";
          iconSize = 48;
          spacing = 4;
          itemSpacing = 4;
          margin = 0;
          bottomGap = 0;
          transparency = 1;
          followInterfaceStyle = true;
          autoHide = false;
          smartAutoHide = true;
          useOverlayLayer = false;
          editOnRightClick = false;
          showOnFullscreen = false;
          openOnOverview = true;
          groupByApp = true;
          separatePinnedAndRunningApps = false;
          restoreSpecialWorkspaceOnClick = false;
          isolateDisplays = false;
          indicatorStyle = "line";
          borderEnabled = false;
          borderColor = "surfaceText";
          borderOpacity = 0.5;
          borderThickness = 1;
          launcherEnabled = false;
          launcherLogoMode = "apps";
          launcherLogoCustomPath = "";
          launcherLogoColorOverride = "";
          launcherLogoSizeOffset = 0;
          launcherLogoBrightness = 0.5;
          launcherLogoContrast = 1;
          maxVisibleApps = 0;
          maxVisibleRunningApps = 0;
          showOverflowBadge = true;
          showTrash = true;
          trashFileManager = "default";
          trashCustomCommand = "xdg-terminal-exec --app-id=yazi yazi ~/.local/share/Trash/files";
          order = [];

          widgets = [
            {
              id = "dock_launcher";
              widgetId = "dockLauncher";
              enabled = true;
            }
            {
              id = "dock_apps";
              widgetId = "appsDock";
              enabled = true;
            }
            {
              id = "dock_trash";
              widgetId = "dockTrash";
              enabled = true;
            }
          ];
        }
      ];
      fadeToLockGracePeriod = 15;
      firstDayOfWeek = 0;
      fontFamily = "Inter Medium";
      launcherLogoColorOverride = "#00bcd4";
      launcherLogoMode = "os";
      launcherStyle = "spotlight";
      launcherPluginVisibility.dms_settings_search.allowWithoutTrigger = false;
      lockBeforeSuspend = true;
      lockScreenNotificationMode = 2;
      lockScreenShowPowerActions = true;
      matugenTemplateNeovim = true;
      maxFprintTries = 3;
      monoFontFamily = "GeistMono NF";
      networkPreference = "wifi";
      niriOverviewLauncherStyle = "spotlight";
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

      screenPreferences.wallpaper = ["all"];
      spotlightSectionViewModes.apps = "list";

      useAutoLocation = true;
      useFahrenheit = true;
    };
  };
}
