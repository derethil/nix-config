{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.browsers.firefox;
  cfg-lw = config.glace.apps.browsers.librewolf;

  mkBrowserConfig = import ./config.nix {inherit lib pkgs config;};

  mimeTypes = [
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

  mkConfig = cfgBrowser: program: pkg: desktopFile: browserName:
    mkIf cfgBrowser.enable {
      home.sessionVariables = mkIf cfgBrowser.defaultBrowser {BROWSER = browserName;};
      programs.${program} = mkBrowserConfig pkg;
      glace.desktop.xdg.mimeapps.default = mkIf cfgBrowser.defaultBrowser (lib.glace.mkMimeApps desktopFile mimeTypes);
    };
in {
  options.glace.apps.browsers.firefox = {
    enable = mkBoolOpt false "Whether to enable Firefox.";
    defaultBrowser = mkBoolOpt false "Whether to set Firefox as the default browser.";
  };

  options.glace.apps.browsers.librewolf = {
    enable = mkBoolOpt false "Whether to enable LibreWolf.";
    defaultBrowser = mkBoolOpt false "Whether to set LibreWolf as the default browser.";
  };

  config = mkMerge [
    (mkConfig cfg "firefox" (pkgs.firefox.override {nativeMessagingHosts = with pkgs; [tridactyl-native];}) "firefox.desktop" "firefox")
    (mkConfig cfg-lw "librewolf" (pkgs.librewolf.override {nativeMessagingHosts = with pkgs; [tridactyl-native];}) "librewolf.desktop" "librewolf")

    {
      assertions = [
        {
          assertion = !(cfg.defaultBrowser && cfg-lw.defaultBrowser);
          message = "Only one browser can be set as the default browser.";
        }
      ];
    }
  ];
}
