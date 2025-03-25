{
  inputs,
  pkgs,
  ...
}: {
  imports = [
    ./ublock-origin.nix
  ];

  home.packages = with pkgs; [
    tridactyl-native
  ];

  programs.firefox = {
    enable = true;
    package = pkgs.firefox.override {cfg = {enableTridactylNative = true;};};

    policies = {
      # Privacy
      HttpsOnlyMode = "enabled";
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisableFeedbackCommands = true;
      DisableSetDesktopBackground = true;
      EnableTrackingProtection = {
        Locked = true;
        Value = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
      # UI
      DisablePocket = true;
      DisableFormHistory = true;
      PromptForDownlladLocation = false;
      DisplayBookmarksToolbar = "never";
      PsswordManagerEnabled = false;
      # Lock configuration
      BlockAboutAddons = true;
      DisableSystemAddonUpdate = true;
    };

    profiles.derethil = {
      search = {
        force = true;
        default = "google";
        privateDefault = "ddg";
        engines."bing".metaData.hidden = true;
      };

      # Enable extensions on startup
      extraConfig = ''
        user_pref("extensions.autoDisableScopes", 0);
        user_pref("extensions.enabledScopes", 15);
      '';

      # Hide flexible space
      userChrome = builtins.readFile ./userChrome.css;

      bookmarks = {};

      extensions.packages = with inputs.firefox-addons.packages.${pkgs.system}; [
        sponsorblock
        ublock-origin

        bitwarden
        darkreader
        theater-mode-for-youtube
        tridactyl

        react-devtools
        reduxdevtools
        refined-github

        private-relay
      ];

      settings = {
        "browser.startup.homepage" = "about:blank"; # Empty homepage
        "browser.startup.page" = 3; # Restore previous session
        "browser.toolbars.bookmarks.visibility" = "never";

        # Skip download prompt
        "browser.download.useDownloadDir" = false;

        # Enable UserChrome
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

        # Hardware acceleration
        "gfx.webrender.all" = true;
        "media.ffmpeg.vaapi.enabled" = true;
        "media.rdd-ffmpeg.enabled" = true;
        "widget.dmabuf.force-enabled" = true;

        # No location telemetry
        "beacon.enabled" = false;
        "device.sensors.enabled" = false;
        "geo.enabled" = false;

        # Disable useless stuff
        "extensions.pocket.enabled" = false;
        "extensions.abuseReport.enabled" = false;
        "extensions.formautofill.creditCards.enabled" = false;
        "browser.contentblocking.report.lockwise.enabled" = false;
        "browser.uitour.enabled" = false;
        "browser.newtabpage.activity-stream.showSponsored" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

        # Disable some telemetry
        "app.shield.optoutstudies.enabled" = false;
        "browser.discovery.enabled" = false;
        "browser.ping-centre.telemetry" = false;
        "datareporting.healthreport.service.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "datareporting.policy.dataSubmissionEnabled" = false;
        "datareporting.sessions.current.clean" = true;
        "toolkit.telemetry.unified" = false;
        "toolkit.telemetry.server" = "";
        "toolkit.telemetry.enabled" = false;

        # UI
        "sidebar.verticalTabs" = true;
        "extensions.activeThemeID" = "{c161a71c-fb42-4608-b001-5634b3f59a8b}";
        "browser.uiCustomization.state" = builtins.readFile ./ui-state.json;
      };
    };
  };

  xdg.mimeApps.defaultApplications = {
    "text/html" = ["firefox.desktop"];
    "text/xml" = ["firefox.desktop"];
    "x-scheme-handler/http" = ["firefox.desktop"];
    "x-scheme-handler/https" = ["firefox.desktop"];
  };
}
