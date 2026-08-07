{
  flake.modules.homeManager.dankmaterialshell-panel = {config, ...}: {
    programs.dank-material-shell.settings = {
      acLockTimeout = 600;
      acMonitorTimeout = 0;
      acPostLockMonitorTimeout = 0;
      acProfileName = "";
      acSuspendBehavior = 0;
      acSuspendTimeout = 900;
      activeDisplayProfile = {};
      animationSpeed = 2;
      animationVariant = 0;
      appDrawerSectionViewModes = {};

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
          pattern = "com.stremio.stremio";
          replacement = "stremio";
          type = "exact";
        }
        {
          pattern = "com.transmissionbt.transmission";
          replacement = "transmission-gtk";
          type = "contains";
        }
      ];

      appLauncherGridColumns = 4;
      appLauncherViewMode = "grid";
      appPickerViewMode = "grid";
      appsDockActiveColorMode = "primary";
      appsDockColorizeActive = false;
      appsDockEnlargeOnHover = false;
      appsDockEnlargePercentage = 125;
      appsDockHideIndicators = false;
      appsDockIconSizePercentage = 100;
      audioInputDevicePins = {};
      audioOutputDevicePins.preferredOutput = "bluez_output.80_C3_BA_52_7A_F4.1";
      audioScrollMode = "volume";
      audioVisualizerEnabled = true;
      audioWheelScrollAmount = 5;

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
        }
      ];

      barElevationEnabled = false;
      barInsetPaddingShared = -1;
      barInsetPaddingSyncAll = false;
      barMaxVisibleApps = 0;
      barMaxVisibleRunningApps = 0;
      barShowOverflowBadge = true;
      batteryChargeLimit = 100;
      batteryLockTimeout = 0;
      batteryMonitorTimeout = 0;
      batteryPostLockMonitorTimeout = 0;
      batteryProfileName = "";
      batterySuspendBehavior = 0;
      batterySuspendTimeout = 0;

      bluetoothDevicePins.preferredDevice = [
        "70:AE:D5:C2:D1:B1"
        "9C:AA:1B:F2:60:13"
      ];

      blurBorderColor = "outline";
      blurBorderCustomColor = "#ffffff";
      blurBorderOpacity = 0;
      blurEnabled = false;
      blurForegroundLayers = true;
      blurLayerOutlineOpacity = 0.12;
      blurWallpaperOnOverview = true;
      blurredWallpaperLayer = false;
      brightnessDevicePins = {};
      browserPickerViewMode = "grid";
      browserUsageHistory = {};
      builtInPluginSettings.dms_settings_search.trigger = "?";
      buttonColorMode = "primary";
      centeringMode = "index";
      clipboardClickToPaste = false;
      clipboardEnterToPaste = false;
      clockCompactMode = false;
      clockDateFormat = "ddd MMM d";
      configVersion = 12;
      connectedFrameBarStyleBackups = {};
      controlCenterShowAudioIcon = true;
      controlCenterShowAudioPercent = false;
      controlCenterShowBatteryIcon = false;
      controlCenterShowBluetoothIcon = true;
      controlCenterShowBrightnessIcon = false;
      controlCenterShowBrightnessPercent = false;
      controlCenterShowDoNotDisturbIcon = false;
      controlCenterShowIdleInhibitorIcon = false;
      controlCenterShowMicIcon = false;
      controlCenterShowMicPercent = false;
      controlCenterShowNetworkIcon = true;
      controlCenterShowPrinterIcon = false;
      controlCenterShowScreenSharingIcon = true;
      controlCenterShowVpnIcon = false;
      controlCenterTileColorMode = "primary";

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

      customAnimationDuration = 500;
      customPowerActionHibernate = "";
      customPowerActionLock = "";
      customPowerActionLogout = "";
      customPowerActionPowerOff = "";
      customPowerActionReboot = "";
      customPowerActionSuspend = "";
      customThemeFile = "${config.home.homeDirectory}/.config/DankMaterialShell/themes/retrobox/theme.json";
      dankLauncherV2BorderColor = "primary";
      dankLauncherV2BorderEnabled = false;
      dankLauncherV2BorderThickness = 2;
      dankLauncherV2IncludeFilesInAll = false;
      dankLauncherV2IncludeFoldersInAll = false;
      dankLauncherV2ShowFooter = true;
      dankLauncherV2ShowSourceBadges = true;
      dankLauncherV2Size = "medium";
      dankLauncherV2UnloadOnClose = false;

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
          id = "settings";
        }
      ];

      desktopClockColorMode = "primary";

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

      desktopClockDisplayPreferences = ["all"];
      desktopClockEnabled = false;
      desktopClockHeight = 180;
      desktopClockShowAnalogNumbers = false;
      desktopClockShowAnalogSeconds = true;
      desktopClockShowDate = true;
      desktopClockStyle = "analog";
      desktopClockTransparency = 0.8;
      desktopClockWidth = 280;
      desktopClockX = -1;
      desktopClockY = -1;
      desktopWidgetGridSettings = {};
      desktopWidgetGroups = [];
      desktopWidgetInstances = [];
      desktopWidgetPositions = {};
      displayNameMode = "model";
      displayProfileAutoSelect = false;
      displayProfiles = {};
      displayShowDisconnected = false;
      displaySnapToEdge = true;
      dockAutoHide = true;
      dockBorderColor = "surfaceText";
      dockBorderEnabled = false;
      dockBorderOpacity = 0.5;
      dockBorderThickness = 1;
      dockBottomGap = 0;
      dockGroupByApp = true;
      dockIconSize = 48;
      dockIndicatorStyle = "line";
      dockIsolateDisplays = false;
      dockLauncherEnabled = false;
      dockLauncherLogoBrightness = 0.5;
      dockLauncherLogoColorOverride = "";
      dockLauncherLogoContrast = 1;
      dockLauncherLogoCustomPath = "";
      dockLauncherLogoMode = "apps";
      dockLauncherLogoSizeOffset = 0;
      dockMargin = 0;
      dockMaxVisibleApps = 0;
      dockMaxVisibleRunningApps = 0;
      dockOpenOnOverview = true;
      dockPosition = 1;
      dockRestoreSpecialWorkspaceOnClick = false;
      dockShowOverflowBadge = true;
      dockShowTrash = true;
      dockSmartAutoHide = false;
      dockSpacing = 4;
      dockTransparency = 1;
      dockTrashCustomCommand = "xdg-terminal-exec --app-id=yazi yazi ~/.local/share/Trash/files";
      dockTrashFileManager = "default";
      dockUseOverlayLayer = false;
      dwlShowAllTags = false;
      enableFprint = false;
      enableRippleEffects = true;
      enableU2f = false;
      enabledGpuPciIds = [];
      fadeToDpmsEnabled = true;
      fadeToDpmsGracePeriod = 5;
      fadeToLockEnabled = true;
      fadeToLockGracePeriod = 15;
      filePickerUsageHistory = {};
      firstDayOfWeek = 0;
      focusedWindowCompactMode = false;
      focusedWindowSize = 1;
      fontFamily = "Inter Medium";
      fontScale = 1;
      fontWeight = 400;
      frameBarInsetPadding = -1;
      frameBarSize = 40;
      frameBlurEnabled = true;
      frameCloseGaps = true;
      frameColor = "";
      frameEnabled = false;
      frameLauncherArcExtender = false;
      frameLauncherEdgeHover = false;
      frameLauncherEmergeSide = "bottom";
      frameMode = "connected";
      frameOpacity = 1;
      frameRounding = 23;
      frameScreenPreferences = ["all"];
      frameShowOnOverview = false;
      frameThickness = 16;
      greeterAutoLogin = false;
      greeterEnableFprint = false;
      greeterEnableU2f = false;
      greeterFontFamily = "";
      greeterLockDateFormat = "";
      greeterPadHours12Hour = false;
      greeterRememberLastSession = true;
      greeterRememberLastUser = true;
      greeterShowSeconds = false;
      greeterSyncBaseline = {};
      greeterSyncPending = false;
      greeterUse24HourClock = false;
      greeterWallpaperFillMode = "";
      greeterWallpaperPath = "";
      groupActiveWorkspaceApps = false;
      groupWorkspaceApps = true;
      gtkThemingEnabled = false;
      hideBrightnessSlider = false;
      hyprlandLayoutBorderSize = -1;
      hyprlandLayoutGapsOutOverride = -1;
      hyprlandLayoutGapsOverride = -1;
      hyprlandLayoutRadiusOverride = -1;
      hyprlandOutputSettings = {};
      hyprlandResizeOnBorder = false;
      iconThemeDark = "System Default";
      iconThemeLight = "System Default";
      iconThemePerMode = false;
      keyboardLayoutNameCompactMode = true;
      keyboardLayoutNameShowIcon = false;
      lastAppliedIconTheme = "";
      launchPrefix = "";
      launcherLogoBrightness = 0.5;
      launcherLogoColorInvertOnMode = false;
      launcherLogoColorOverride = "#00bcd4";
      launcherLogoContrast = 1;
      launcherLogoCustomPath = "";
      launcherLogoMode = "os";
      launcherLogoSizeOffset = 0;
      launcherPluginOrder = [];
      launcherPluginVisibility.dms_settings_search.allowWithoutTrigger = false;
      launcherStyle = "full";
      launcherUseOverlayLayer = false;
      lockAtStartup = false;
      lockBeforeSuspend = true;
      lockDateFormat = "";
      lockScreenActiveMonitor = "all";
      lockScreenFontFamily = "";
      lockScreenInactiveColor = "#000000";
      lockScreenNotificationMode = 2;
      lockScreenPowerOffMonitorsOnLock = false;
      lockScreenShowDate = true;
      lockScreenShowMediaPlayer = true;
      lockScreenShowPasswordField = true;
      lockScreenShowPowerActions = true;
      lockScreenShowProfileImage = true;
      lockScreenShowSystemIcons = true;
      lockScreenShowTime = true;
      lockScreenVideoCycling = false;
      lockScreenVideoEnabled = false;
      lockScreenVideoPath = "";
      lockScreenWallpaperFillMode = "";
      lockScreenWallpaperPath = "";
      loginctlLockIntegration = true;
      m3ElevationColorMode = "default";
      m3ElevationCustomColor = "#000000";
      m3ElevationEnabled = true;
      m3ElevationIntensity = 12;
      m3ElevationLightDirection = "top";
      m3ElevationOpacity = 30;
      mangoLayoutBorderSize = -1;
      mangoLayoutGapsOutOverride = -1;
      mangoLayoutGapsOverride = -1;
      mangoLayoutRadiusOverride = -1;
      mangoTrackpadNaturalScrolling = true;
      matugenContrast = 0;
      matugenScheme = "scheme-tonal-spot";
      matugenTargetMonitor = "";
      matugenTemplateAlacritty = true;
      matugenTemplateDgop = true;
      matugenTemplateEmacs = true;
      matugenTemplateEquibop = true;
      matugenTemplateFirefox = true;
      matugenTemplateFoot = true;
      matugenTemplateGhostty = true;
      matugenTemplateGtk = true;
      matugenTemplateHyprland = true;
      matugenTemplateKcolorscheme = true;
      matugenTemplateKitty = true;
      matugenTemplateMangowc = true;
      matugenTemplateNeovim = true;
      matugenTemplateNeovimSetBackground = true;

      matugenTemplateNeovimSettings = {
        dark = {
          baseTheme = "github_dark";
          harmony = 0.5;
        };

        light = {
          baseTheme = "github_light";
          harmony = 0.5;
        };
      };

      matugenTemplateNiri = true;
      matugenTemplatePywalfox = true;
      matugenTemplateQt5ct = true;
      matugenTemplateQt6ct = true;
      matugenTemplateVencord = true;
      matugenTemplateVesktop = true;
      matugenTemplateVscode = true;
      matugenTemplateWezterm = true;
      matugenTemplateZed = true;
      matugenTemplateZenBrowser = true;
      maxFprintTries = 3;
      maxWorkspaceIcons = 3;
      mediaAdaptiveWidthEnabled = true;
      mediaExcludePlayers = [];
      mediaSize = 1;
      modalAnimationSpeed = 1;
      modalCustomAnimationDuration = 150;
      modalDarkenBackground = true;
      modalElevationEnabled = true;
      monoFontFamily = "GeistMono NF";
      motionEffect = 0;
      muxCustomCommand = "";
      muxSessionFilter = "";
      muxType = "tmux";
      muxUseCustomCommand = false;
      networkPreference = "wifi";
      nightModeEnabled = false;
      niriLayoutBorderSize = -1;
      niriLayoutGapsOverride = -1;
      niriLayoutRadiusOverride = -1;
      niriOutputSettings = {};
      niriOverviewOverlayEnabled = true;
      notepadFontFamily = "";
      notepadFontSize = 14;
      notepadLastCustomTransparency = 0.5;
      notepadShowLineNumbers = true;
      notepadTransparencyOverride = -1;
      notepadUseMonospace = true;
      notificationAnimationSpeed = 1;
      notificationCompactMode = false;
      notificationCustomAnimationDuration = 400;
      notificationDedupeEnabled = true;
      notificationFocusedMonitor = false;
      notificationHistoryEnabled = true;
      notificationHistoryMaxAgeDays = 7;
      notificationHistoryMaxCount = 50;
      notificationHistorySaveCritical = true;
      notificationHistorySaveLow = true;
      notificationHistorySaveNormal = true;
      notificationOverlayEnabled = true;
      notificationPopupPosition = -1;
      notificationPopupPrivacyMode = false;
      notificationPopupShadowEnabled = true;

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

      notificationTimeoutCritical = 0;
      notificationTimeoutLow = 5000;
      notificationTimeoutNormal = 5000;
      osdAlwaysShowValue = true;
      osdAudioOutputEnabled = true;
      osdBrightnessEnabled = true;
      osdCapsLockEnabled = true;
      osdIdleInhibitorEnabled = true;
      osdMediaPlaybackEnabled = true;
      osdMediaVolumeEnabled = true;
      osdMicMuteEnabled = true;
      osdPosition = 5;
      osdPowerProfileEnabled = true;
      osdVolumeEnabled = true;
      padHours12Hour = true;
      popoutAnimationSpeed = 1;
      popoutCustomAnimationDuration = 150;
      popoutElevationEnabled = true;
      popupTransparency = 1;
      powerActionConfirm = true;
      powerActionHoldDuration = 0.75;

      powerMenuActions = [
        "reboot"
        "logout"
        "poweroff"
        "lock"
        "suspend"
        "restart"
      ];

      powerMenuDefaultAction = "logout";
      powerMenuGridLayout = false;
      privacyShowCameraIcon = false;
      privacyShowMicIcon = false;
      privacyShowScreenShareIcon = false;
      qtThemingEnabled = false;

      registryThemeVariants = {
        flexoki = "green";
        gruvboxMaterial = "hard";
        petrichor = "green";
      };

      rememberLastMode = true;
      rememberLastQuery = false;
      reverseScrolling = false;
      runDmsMatugenTemplates = true;
      runUserMatugenTemplates = true;
      runningAppsCompactMode = false;
      runningAppsCurrentMonitor = false;
      runningAppsCurrentWorkspace = false;
      runningAppsGroupByApp = false;
      screenPreferences.wallpaper = ["all"];
      scrollTitleEnabled = true;
      selectedGpuIndex = 0;
      showBattery = true;
      showBatteryPercent = true;
      showBatteryPercentOnlyOnBattery = false;
      showBatteryTime = false;
      showBatteryTimeOnlyOnBattery = false;
      showCapsLockIndicator = true;
      showClipboard = true;
      showClock = true;
      showControlCenterButton = true;
      showCpuTemp = true;
      showCpuUsage = true;
      showDock = true;
      showFocusedWindow = true;
      showGpuTemp = true;
      showLauncherButton = true;
      showMemUsage = true;
      showMusic = true;
      showNotificationButton = true;
      showOccupiedWorkspacesOnly = true;
      showOnLastDisplay = {};
      showPrivacyButton = true;
      showSeconds = false;
      showSystemTray = true;
      showWeather = true;
      showWeekNumber = false;
      showWorkspaceApps = true;
      showWorkspaceIndex = false;
      showWorkspaceName = false;
      showWorkspacePadding = true;
      showWorkspaceSwitcher = true;
      sortAppsAlphabetically = false;
      soundLogin = false;
      soundNewNotification = true;
      soundPluggedIn = true;
      soundVolumeChanged = true;
      soundsEnabled = true;
      spotlightBarShowModeChips = false;
      spotlightCloseNiriOverview = true;
      spotlightModalViewMode = "list";
      spotlightSectionViewModes.apps = "list";
      syncComponentAnimationSpeeds = true;
      syncModeWithPortal = true;
      systemMonitorColorMode = "primary";

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

      systemMonitorDisplayPreferences = ["all"];
      systemMonitorEnabled = false;
      systemMonitorGpuPciId = "";
      systemMonitorGraphInterval = 60;
      systemMonitorHeight = 480;
      systemMonitorLayoutMode = "auto";
      systemMonitorShowCpu = true;
      systemMonitorShowCpuGraph = true;
      systemMonitorShowCpuTemp = true;
      systemMonitorShowDisk = true;
      systemMonitorShowGpuTemp = false;
      systemMonitorShowHeader = true;
      systemMonitorShowMemory = true;
      systemMonitorShowMemoryGraph = true;
      systemMonitorShowNetwork = true;
      systemMonitorShowNetworkGraph = true;
      systemMonitorShowTopProcesses = false;
      systemMonitorTopProcessCount = 3;
      systemMonitorTopProcessSortBy = "cpu";
      systemMonitorTransparency = 0.8;
      systemMonitorVariants = [];
      systemMonitorWidth = 320;
      systemMonitorX = -1;
      systemMonitorY = -1;
      systemTrayIconTintMode = "none";
      systemTrayIconTintSaturation = 50;
      systemTrayIconTintStrength = 135;
      terminalsAlwaysDark = false;
      textRenderQuality = 0;
      textRenderType = 0;
      u2fMode = "or";
      updaterAllowAUR = true;
      updaterCheckOnStart = false;
      updaterCustomCommand = "";
      updaterHideWidget = false;
      updaterIncludeFlatpak = true;
      updaterIntervalSeconds = 1800;
      updaterTerminalAdditionalParams = "";
      updaterUseCustomCommand = false;
      use24HourClock = false;
      useAutoLocation = true;
      useFahrenheit = true;
      useSystemSoundTheme = false;
      wallpaperBackgroundColorMode = "black";
      wallpaperBackgroundCustomColor = "#000000";
      wallpaperFillMode = "Fill";
      waveProgressEnabled = true;
      weatherEnabled = true;
      widgetBackgroundColor = "sch";
      widgetColorMode = "default";
      wifiNetworkPins.preferredWifi = "HP-Print-50-Laserjet";
      windSpeedUnit = "kmh";
      workspaceActiveAppHighlightEnabled = true;
      workspaceAppIconSizeOffset = 0;
      workspaceColorMode = "default";
      workspaceDragReorder = true;
      workspaceFocusedBorderColor = "primary";
      workspaceFocusedBorderEnabled = false;
      workspaceFocusedBorderThickness = 2;
      workspaceFollowFocus = false;
      workspaceNameIcons = {};
      workspaceOccupiedColorMode = "none";
      workspaceScrolling = false;
      workspaceUnfocusedColorMode = "default";
      workspaceUnfocusedMonitorBorderColor = "primary";
      workspaceUnfocusedMonitorBorderCustomColor = "#6750A4";
      workspaceUnfocusedMonitorBorderEnabled = false;
      workspaceUnfocusedMonitorBorderThickness = 2;
      workspaceUnfocusedMonitorColorMode = "default";
      workspaceUnfocusedMonitorFocusedCustomColor = "#6750A4";
      workspaceUnfocusedMonitorOccupiedColorMode = "none";
      workspaceUnfocusedMonitorOccupiedCustomColor = "#625B71";
      workspaceUnfocusedMonitorSeparateAppearance = false;
      workspaceUnfocusedMonitorUnfocusedColorMode = "default";
      workspaceUnfocusedMonitorUnfocusedCustomColor = "#49454E";
      workspaceUnfocusedMonitorUrgentColorMode = "default";
      workspaceUnfocusedMonitorUrgentCustomColor = "#B3261E";
      workspaceUrgentColorMode = "default";
    };
  };
}
