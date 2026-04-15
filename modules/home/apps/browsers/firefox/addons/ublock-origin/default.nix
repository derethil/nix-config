{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.apps.browsers.firefox;
  cfg-lw = config.glace.apps.browsers.librewolf;
in {
  config = mkIf (cfg.enable || cfg-lw.enable) {
    home.file.".mozilla/managed-storage/uBlock0@raymondhill.net.json".text = builtins.toJSON {
      name = "uBlock0@raymondhill.net";
      description = "_";
      type = "storage";
      data = {
        adminSettings = {
          userFilters = "";
        };
        userSettings = [
          ["advancedUserEnabled" "true"]
          ["autoUpdate" "true"]
          ["colorBlindFriendly" "true"]
          ["contextMenuEnabled" "true"]
          ["dynamicFilteringEnabled" "false"]
        ];
        toOverwrite = {
          filterLists = [
            "user-filters"
            "ublock-filters"
            "ublock-badware"
            "ublock-privacy"
            "ublock-quick-fixes"
            "ublock-unbreak"
            "easylist"
            "easyprivacy"
            "urlhaus-1"
            "plowe-0"
            "fanboy-cookiemonster"
            "ublock-cookies-easylist"
            "adguard-cookies"
            "ublock-cookies-adguard"
          ];
        };
      };
    };
  };
}
