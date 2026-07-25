{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      keymap.mgr.prepend_keymap = [
        {
          desc = "Paste into the hovered directory or CWD";
          on = ["p"];
          run = ["plugin smart-paste"];
        }
      ];

      plugins.smart-paste = pkgs.yaziPlugins.smart-paste;
    };
  };
}
