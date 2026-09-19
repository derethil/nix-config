{
  flake.modules.homeManager.noctalia-panel = {pkgs, ...}: {
    home.packages = [pkgs.bitwarden-cli];

    programs.noctalia.settings = {
      plugin_settings = {
        "felipeartur/ai-usagebar".panel_open_near_click = true;

        "kenn/keybind-cheatsheet" = {
          cheatsheet_open_near_click = false;
          cheatsheet_placement = "attached";
          cheatsheet_position = "auto";
        };

        "liamwh/emoji-picker".paste_command = "wl-paste";
        "nightwatch75/todo".sound_on_complete = true;
        "noctalia/bitwarden".gen_special = true;
      };

      plugins.enabled = [
        "noctalia/bitwarden"
        "notfinaldev/web-search"
        "liamwh/emoji-picker"
        "kenn/keybind-cheatsheet"
        "nightwatch75/todo"
        "tordex/processes"
        "radimous/prismlauncher-instances"
        "apex077/eyecare"
        "felipeartur/ai-usagebar"
      ];
    };
  };
}
