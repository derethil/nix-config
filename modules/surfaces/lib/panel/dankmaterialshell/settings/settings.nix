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
              clockCompactMode = true;
              clockDateOrder = "timeFirst";
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
          followInterfaceStyle = true;
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
              showOccupiedWorkspacesOnly = true;
              showWorkspaceApps = true;
              showWorkspacePadding = true;
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
        }
      ];

      barElevationEnabled = false;
      blurBorderOpacity = 0;
      blurWallpaperOnOverview = true;

      builtInPluginSettings = {
        dms_clipboard_search.trigger = "cb";
        dms_power.trigger = "pw";
        dms_qr_generator.trigger = "qrg";
        dms_settings_search.trigger = "?";
      };

      clockDateFormat = "ddd MMM d";
      configVersion = 28;

      controlCenterWidgets = [
        {
          enabled = true;
          h = 1;
          id = "volumeSlider";
          w = 4;
        }
        {
          enabled = true;
          h = 1;
          id = "idleInhibitor";
          w = 2;
        }
        {
          enabled = true;
          h = 1;
          id = "doNotDisturb";
          w = 2;
        }
        {
          enabled = true;
          h = 1;
          id = "wifi";
          w = 4;
        }
        {
          enabled = true;
          h = 1;
          id = "bluetooth";
          w = 4;
        }
        {
          enabled = true;
          h = 1;
          id = "audioOutput";
          w = 4;
        }
        {
          enabled = true;
          h = 1;
          id = "audioInput";
          w = 4;
        }
        {
          enabled = true;
          h = 1;
          id = "plugin_niriScreenshot";
          w = 4;
        }
        {
          enabled = true;
          h = 1;
          id = "colorPicker";
          w = 4;
        }
      ];

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
          enabled = true;
          id = "overview";
        }
        {
          enabled = true;
          id = "media";
        }
        {
          enabled = true;
          id = "wallpaper";
        }
        {
          enabled = true;
          id = "weather";
        }
        {
          enabled = true;
          id = "notifications";
        }
      ];

      displayNameMode = "model";

      dockConfigs = [
        {
          autoHide = false;
          borderColor = "surfaceText";
          borderEnabled = false;
          borderOpacity = 0.5;
          borderThickness = 1;
          bottomGap = 0;
          editOnRightClick = false;
          enabled = true;
          followInterfaceStyle = true;
          groupByApp = true;
          iconSize = 48;
          id = "dock";
          indicatorStyle = "line";
          isolateDisplays = false;
          itemSpacing = 4;
          launcherEnabled = false;
          launcherLogoBrightness = 0.5;
          launcherLogoColorOverride = "";
          launcherLogoContrast = 1;
          launcherLogoCustomPath = "";
          launcherLogoMode = "apps";
          launcherLogoSizeOffset = 0;
          margin = 0;
          maxVisibleApps = 0;
          maxVisibleRunningApps = 0;
          mode = "compact";
          name = "Dock";
          openOnOverview = true;
          order = [];
          position = 1;
          restoreSpecialWorkspaceOnClick = false;
          screenPreferences = ["all"];
          separatePinnedAndRunningApps = false;
          showOnFullscreen = false;
          showOnLastDisplay = true;
          showOverflowBadge = true;
          showTrash = true;
          smartAutoHide = true;
          spacing = 4;
          taskbarAlign = "center";
          transparency = 1;
          trashCustomCommand = "xdg-terminal-exec --app-id=yazi yazi ~/.local/share/Trash/files";
          trashFileManager = "default";
          useOverlayLayer = false;
          widgetExpansion = "popout";

          widgets = [
            {
              enabled = true;
              id = "dock_launcher";
              widgetId = "dockLauncher";
            }
            {
              enabled = true;
              id = "dock_apps";
              widgetId = "appsDock";
            }
            {
              enabled = true;
              id = "dock_trash";
              widgetId = "dockTrash";
            }
          ];
        }
      ];

      fadeToLockGracePeriod = 15;
      firstDayOfWeek = 0;
      fontFamily = "Inter Medium";
      launcherLogoColorOverride = "#00bcd4";
      launcherLogoMode = "os";
      launcherPluginVisibility.dms_settings_search.allowWithoutTrigger = false;
      launcherStyle = "spotlight";
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
      radiusStrength = 28;

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
