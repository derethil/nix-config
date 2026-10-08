{
  flake.modules.homeManager.noctalia-panel = {pkgs, ...}: {
    home.packages = [
      pkgs.avahi
      pkgs.bitwarden-cli
    ];

    programs.noctalia.settings = {
      plugin_settings = {
        "derethil/hue-manager" = {
          auto_sync_accent = false;
          bridge_ip = "";
          sync_rooms = [];
          use_device_icons = true;
        };

        "felipeartur/ai-usagebar".panel_open_near_click = true;

        "kenn/keybind-cheatsheet" = {
          cheatsheet_open_near_click = false;
          cheatsheet_placement = "attached";
          cheatsheet_position = "auto";
        };

        "liamwh/emoji-picker".paste_command = "wl-paste";
        "nightwatch75/todo".sound_on_complete = true;

        "noctalia/bitwarden" = {
          gen_special = true;
          hide_actions_when_searching = true;
        };
      };

      plugins = {
        auto_update = "all";

        enabled = [
          "noctalia/bitwarden"
          "notfinaldev/web-search"
          "liamwh/emoji-picker"
          "kenn/keybind-cheatsheet"
          "nightwatch75/todo"
          "tordex/processes"
          "radimous/prismlauncher-instances"
          "felipeartur/ai-usagebar"
          "derethil/cast-window"
          "derethil/hue-manager"
        ];

        source = [
          {
            enabled = true;
            kind = "git";
            location = "https://github.com/noctalia-dev/official-plugins";
            name = "official";
          }
          {
            enabled = true;
            kind = "git";
            location = "https://github.com/noctalia-dev/community-plugins";
            name = "community";
          }
          {
            enabled = true;
            kind = "git";
            location = "https://github.com/derethil/noctalia-plugins";
            name = "derethil";
          }
        ];
      };
    };
  };
}
