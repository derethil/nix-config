{
  lib,
  config,
  pkgs,
  ...
}:
with lib;
with internal; let
  cfg = config.apps.firefox;
  firefoxPkg = pkgs.firefox.override {nativeMessagingHosts = with pkgs; [tridactyl-native];};
in {
  options.apps.firefox = {
    enable = mkBoolOpt false "Whether to enable Firefox.";
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package =
        if config.nixGL.enable or false
        then config.lib.nixGL.wrap firefoxPkg
        else firefoxPkg;
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
        PromptForDownloadLocation = false;
        DisplayBookmarksToolbar = "never";
        PasswordManagerEnabled = false;
        # Lock configuration
        BlockAboutAddons = true;
        DisableSystemAddonUpdate = true;
      };

      profiles.default = {
        id = 0;
        isDefault = true;
        search = {
          force = true;
          default = "google";
          privateDefault = "ddg";
          engines = {
            "Nix Packages" = {
              urls = [
                {
                  template = "https://search.nixos.org/packages";
                  params = [
                    {
                      name = "type";
                      value = "packages";
                    }
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "https://nixos.wiki/favicon.png";
              definedAliases = ["@np"];
            };
            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://nixos.wiki/index.php?search={searchTerms}";
                }
              ];
              iconUpdateURL = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@nw"];
            };
            "bing".metaData.hidden = true;
          };
        };

        # Enable extensions on startup
        extraConfig = ''
          user_pref("extensions.autoDisableScopes", 0);
          user_pref("extensions.enabledScopes", 15);
        '';

        # Hide flexible space
        userChrome = builtins.readFile ./userChrome.css;

        bookmarks = {};

        extensions.packages = with pkgs.inputs.firefox-addons; [
          sponsorblock
          ublock-origin
          private-relay

          bitwarden
          darkreader
          theater-mode-for-youtube
          tridactyl

          react-devtools
          reduxdevtools
          refined-github

          augmented-steam
        ];

        settings = {
          "browser.startup.homepage" = "about:blank"; # Empty homepage
          "browser.startup.page" = 3; # Restore previous session
          "browser.toolbars.bookmarks.visibility" = "never";

          # Only sync browser history and tabs
          "services.sync.engine.addons" = false;
          "services.sync.engine.addresses" = false;
          "services.sync.engine.bookmarks" = false;
          "services.sync.engine.creditcards" = false;
          "services.sync.engine.history" = true;
          "services.sync.engine.passwords" = false;
          "services.sync.engine.prefs" = false;
          "services.sync.engine.tabs" = true;

          # Skip download prompt
          "browser.download.useDownloadDir" = false;

          # Enable UserChrome
          "toolkit.legacyUserProfileCustomizations.stylesheets" = true;

          # No location telemetry
          "beacon.enabled" = false;
          "device.sensors.enabled" = false;
          "geo.enabled" = false;

          # Request not to track
          "privacy.globalprivacycontrol.functionality.enabled" = true;
          "privacy.globalprivacycontrol.enabled" = true;

          # Disable useless stuff
          "extensions.pocket.enabled" = false;
          "extensions.abuseReport.enabled" = false;
          "extensions.formautofill.creditCards.enabled" = false;
          "extensions.formautofill.addresses.enabled" = false;
          "browser.contentblocking.report.lockwise.enabled" = false;
          "browser.uitour.enabled" = false;
          "browser.newtabpage.activity-stream.showSponsored" = false;
          "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;

          # Disable some telemetry
          "app.shield.optoutstudies.enabled" = false;
          "browser.discovery.enabled" = false;
          "browser.newtabpage.activity-stream.feeds.telemetry" = false;
          "browser.newtabpage.activity-stream.telemetry" = false;
          "browser.ping-centre.telemetry" = false;
          "datareporting.healthreport.service.enabled" = false;
          "datareporting.healthreport.uploadEnabled" = false;
          "datareporting.policy.dataSubmissionEnabled" = false;
          "datareporting.sessions.current.clean" = true;
          "devtools.onboarding.telemetry.logged" = false;
          "toolkit.telemetry.archive.enabled" = false;
          "toolkit.telemetry.bhrPing.enabled" = false;
          "toolkit.telemetry.enabled" = false;
          "toolkit.telemetry.firstShutdownPing.enabled" = false;
          "toolkit.telemetry.hybridContent.enabled" = false;
          "toolkit.telemetry.newProfilePing.enabled" = false;
          "toolkit.telemetry.prompted" = 2;
          "toolkit.telemetry.rejected" = true;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "toolkit.telemetry.server" = "";
          "toolkit.telemetry.shutdownPingSender.enabled" = false;
          "toolkit.telemetry.unified" = false;
          "toolkit.telemetry.unifiedIsOptIn" = false;
          "toolkit.telemetry.updatePing.enabled" = false;

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
  };
}
