{self, ...}: {
  flake.modules.homeManager.firefox = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkForce mkMerge;

    firefoxPkg = pkgs.firefox.override {nativeMessagingHosts = [pkgs.tridactyl-native];};
  in {
    imports = [
      self.modules.homeManager.displays
      self.modules.homeManager.firefox-tridactyl
      self.modules.homeManager.firefox-ublock-origin
      self.modules.homeManager.mimeapps
    ];

    home.sessionVariables.BROWSER =
      if pkgs.stdenv.hostPlatform.isDarwin
      then "open"
      else "firefox";

    programs.firefox = {
      enable = true;
      package = firefoxPkg;
      configPath = lib.mkIf (!pkgs.stdenv.isDarwin) "${config.xdg.configHome}/mozilla/firefox";

      policies = {
        # Lock configuration
        BlockAboutAddons = false;
        DisableFeedbackCommands = true;
        DisableFirefoxStudies = true;
        DisableFormHistory = true;
        # UI
        DisablePocket = true;
        DisableSetDesktopBackground = true;
        DisableSystemAddonUpdate = true;
        DisableTelemetry = true;
        DisplayBookmarksToolbar = "never";

        EnableTrackingProtection = {
          Cryptomining = true;
          EmailTracking = true;
          Fingerprinting = true;
          Locked = true;
          Value = true;
        };

        # Privacy
        HttpsOnlyMode = "enabled";
        PasswordManagerEnabled = false;
        PromptForDownloadLocation = false;
      };

      profiles = rec {
        default = {
          bookmarks = {};

          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            augmented-steam
            bitwarden
            clearurls
            darkreader
            i-dont-care-about-cookies
            # Site-specific
            improved-tube
            private-relay
            # Development
            react-devtools
            reduxdevtools
            refined-github
            # Privacy / Enhancements
            sponsorblock
            # Tools
            tridactyl
            ublock-origin
          ];

          extraConfig = ''
            user_pref("extensions.autoDisableScopes", 0);
            user_pref("extensions.enabledScopes", 15);
          '';

          id = 0;
          isDefault = true;

          search = {
            default = "google";

            engines = {
              "Nix Packages" = {
                definedAliases = ["@np"];
                icon = "https://nixos.wiki/favicon.png";

                urls = [
                  {
                    params = [
                      {
                        name = "query";
                        value = "{searchTerms}";
                      }
                      {
                        name = "type";
                        value = "packages";
                      }
                    ];

                    template = "https://search.nixos.org/packages";
                  }
                ];
              };

              "NixOS Options" = {
                definedAliases = ["@no"];
                icon = "https://nixos.wiki/favicon.png";
                urls = [{template = "https://search.nixos.org/options?query={searchTerms}";}];
              };

              "NixOS Wiki" = {
                definedAliases = ["@nw"];
                icon = "https://nixos.wiki/favicon.png";
                updateInterval = 24 * 60 * 60 * 1000;
                urls = [{template = "https://nixos.wiki/index.php?search={searchTerms}";}];
              };

              "ProtonDB" = {
                definedAliases = ["@pd"];
                icon = "https://www.protondb.com/sites/protondb/images/favicon.ico";
                urls = [{template = "https://www.protondb.com/search?q={searchTerms}";}];
              };

              "bing".metaData.hidden = true;
            };

            force = true;
            privateDefault = "ddg";
          };

          settings = {
            # Disable some telemetry
            "app.shield.optoutstudies.enabled" = false;
            "browser.contentblocking.report.lockwise.enabled" = false;
            "browser.discovery.enabled" = false;
            "browser.download.useDownloadDir" = false;
            "browser.newtabpage.activity-stream.feeds.telemetry" = false;
            "browser.newtabpage.activity-stream.showSponsored" = false;
            "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
            "browser.newtabpage.activity-stream.telemetry" = false;
            "browser.ping-centre.telemetry" = false;
            "browser.startup.homepage" = "about:blank";
            "browser.startup.page" = 3;
            "browser.toolbars.bookmarks.visibility" = "never";
            "browser.uiCustomization.state" = builtins.readFile ./_ui-state.json;
            "browser.uitour.enabled" = false;
            "datareporting.healthreport.service.enabled" = false;
            "datareporting.healthreport.uploadEnabled" = false;
            "datareporting.policy.dataSubmissionEnabled" = false;
            "datareporting.sessions.current.clean" = true;
            # No location telemetry
            "device.sensors.enabled" = false;
            "devtools.onboarding.telemetry.logged" = false;
            "extensions.abuseReport.enabled" = false;
            "extensions.activeThemeID" = "{c161a71c-fb42-4608-b001-5634b3f59a8b}";
            "extensions.formautofill.addresses.enabled" = false;
            "extensions.formautofill.creditCards.enabled" = false;
            # Disable useless stuff
            "extensions.pocket.enabled" = false;
            "geo.enabled" = false;
            "layout.frame_rate" = config.internal.primaryDisplay.framerate;
            "privacy.globalprivacycontrol.enabled" = true;
            # Request not to track
            "privacy.globalprivacycontrol.functionality.enabled" = true;
            # Only sync browser history and tabs
            "services.sync.engine.addons" = false;
            "services.sync.engine.addresses" = false;
            "services.sync.engine.bookmarks" = false;
            "services.sync.engine.creditcards" = false;
            "services.sync.engine.history" = true;
            "services.sync.engine.passwords" = false;
            "services.sync.engine.prefs" = false;
            "services.sync.engine.tabs" = true;
            # UI
            "sidebar.verticalTabs" = true;
            "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
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
            # NOTE: Not needed after NVIDIA drivers are 575.64.5+
            # Wayland screencasting fix
            "widget.dmabuf.force-enabled" = true;
            # Make scrollbar bigger (I'm blind lol)
            "widget.non-native-theme.scrollbar.size.override" = 24;
            # Use XDG Desktop Portal (1 = always, 2 = auto/flatpak only, 0 = never)
            "widget.use-xdg-desktop-portal.file-picker" = 1;
            "widget.use-xdg-desktop-portal.location" = 1;
            "widget.use-xdg-desktop-portal.mime-handler" = 1;
            "widget.use-xdg-desktop-portal.open-uri" = 1;
            "widget.use-xdg-desktop-portal.settings" = 1;
          };

          userChrome = builtins.readFile ./_userChrome.css;
        };

        demos = {
          inherit (default) extraConfig;
          inherit (default) userChrome;

          extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
            bitwarden
            darkreader
            tridactyl
            ublock-origin
          ];

          id = 1;
          isDefault = false;

          settings = mkMerge [
            default.settings
            {
              "browser.startup.homepage" = mkForce "about:blank";
              "browser.startup.page" = mkForce 1;
            }
          ];
        };
      };
    };

    xdg.mimeApps.defaultApplications = self.lib.mkMimeApps "firefox.desktop" [
      "application/pdf"
      "application/xhtml+xml"
      "application/xml"
      "image/avif"
      "image/bmp"
      "image/gif"
      # Images
      "image/jpeg"
      "image/jpg"
      "image/png"
      "image/svg+xml"
      "image/webp"
      # Documents
      "text/html"
      "text/xml"
      "x-scheme-handler/http"
      "x-scheme-handler/https"
    ];
  };
}
