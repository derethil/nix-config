{
  flake.modules.homeManager.firefox-ublock-origin = {
    home.file.".mozilla/managed-storage/uBlock0@raymondhill.net.json".text = builtins.toJSON {
      data = {
        adminSettings.userFilters = "";

        toOverwrite.filterLists = [
          "adguard-cookies"
          "easylist"
          "easyprivacy"
          "fanboy-cookiemonster"
          "plowe-0"
          "ublock-badware"
          "ublock-cookies-adguard"
          "ublock-cookies-easylist"
          "ublock-filters"
          "ublock-privacy"
          "ublock-quick-fixes"
          "ublock-unbreak"
          "urlhaus-1"
          "user-filters"
        ];

        userSettings = [
          ["advancedUserEnabled" "true"]
          ["autoUpdate" "true"]
          ["colorBlindFriendly" "true"]
          ["contextMenuEnabled" "true"]
          ["dynamicFilteringEnabled" "false"]
        ];
      };

      description = "_";
      name = "uBlock0@raymondhill.net";
      type = "storage";
    };
  };
}
