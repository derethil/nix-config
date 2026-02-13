{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.browsers.firefox;
  firefoxPkg = pkgs.firefox.override {nativeMessagingHosts = with pkgs; [tridactyl-native];};
in {
  options.glace.apps.browsers.firefox = {
    enable = mkBoolOpt false "Whether to enable Firefox.";
    defaultBrowser = mkBoolOpt true "Whether to set Firefox as the default browser.";
  };

  config = mkIf cfg.enable {
    home.sessionVariables = mkIf cfg.defaultBrowser {
      BROWSER = "firefox";
    };

    programs.firefox = {
      enable = true;
      package =
        if config.glace.tools.nix.nixgl.enable or false
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
        BlockAboutAddons = false;
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
            "NixOS Options" = {
              urls = [
                {
                  template = "https://searchix.ovh/?query={searchTerms}";
                  params = [
                    {
                      name = "query";
                      value = "{searchTerms}";
                    }
                  ];
                }
              ];
              icon = "https://nixos.wiki/favicon.png";
              definedAliases = ["@no"];
            };
            "NixOS Wiki" = {
              urls = [
                {
                  template = "https://nixos.wiki/index.php?search={searchTerms}";
                }
              ];
              icon = "https://nixos.wiki/favicon.png";
              updateInterval = 24 * 60 * 60 * 1000; # every day
              definedAliases = ["@nw"];
            };
            "ProtonDB" = {
              urls = [
                {
                  template = "https://www.protondb.com/search?q={searchTerms}";
                }
              ];
              icon = "https://www.protondb.com/sites/protondb/images/favicon.ico";
              definedAliases = ["@pd"];
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

        extensions.packages = with pkgs.firefox-addons; [
          # Tools
          tridactyl
          bitwarden
          darkreader

          # Privacy / Enhancements
          sponsorblock
          ublock-origin
          private-relay
          clearurls
          i-dont-care-about-cookies

          # Site-specific
          improved-tube
          augmented-steam
          refined-github

          # Development
          react-devtools
          reduxdevtools
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

          # NOTE: Not needed after NVIDIA drivers are 575.64.5+
          # Wayland screencasting fix
          "widget.dmabuf.force-enabled" = true;

          # Use XDG Desktop Portal (1 = always, 2 = auto/flatpak only, 0 = never)
          "widget.use-xdg-desktop-portal.file-picker" = 1;
          "widget.use-xdg-desktop-portal.mime-handler" = 1;
          "widget.use-xdg-desktop-portal.settings" = 1;
          "widget.use-xdg-desktop-portal.location" = 1;
          "widget.use-xdg-desktop-portal.open-uri" = 1;

          # Make scrollbar bigger (I'm blind lol)
          "widget.non-native-theme.scrollbar.size.override" = 24;
        };
      };
    };

    glace.desktop.xdg.mimeapps.default = lib.glace.mkMimeApps "firefox.desktop" [
      "x-scheme-handler/http"
      "x-scheme-handler/https"
      # Documents
      "text/html"
      "application/xhtml+xml"
      "text/xml"
      "application/xml"
      "application/pdf"
      # Images
      "image/jpeg"
      "image/jpg"
      "image/webp"
      "image/png"
      "image/gif"
      "image/svg+xml"
      "image/bmp"
      "image/avif"
    ];
  };
}
