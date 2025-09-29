{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.homerow;
in {
  options.glace.desktop.homerow = {
    enable = mkBoolOpt false "Whether to enable Homerow, the MacOS keyboard shortcut utility.";
  };

  config = mkIf cfg.enable {
    tools.homebrew.casks = ["homerow"];

    system.defaults.CustomUserPreferences = {
      "com.superultra.Homerow" = {
        "NSStatusItem Visible Item-0" = 0;
        SUEnableAutomaticChecks = 0;
        SUHasLaunchedBefore = 1;
        check-for-updates-automatically = 0;
        launch-at-login = 1;
        map-arrow-keys-to-scroll = 0;
        non-search-shortcut = "\\U2303F";
        show-menubar-icon = 0;
        theme-id = "original";
      };
    };
  };
}
