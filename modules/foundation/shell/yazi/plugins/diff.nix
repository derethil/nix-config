{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      keymap.mgr.prepend_keymap = [
        {
          desc = "Diff the selected with the hovered file";
          on = ["<Ctrl+h>"];
          run = ["plugin diff"];
        }
      ];

      plugins.diff = pkgs.yaziPlugins.diff;
    };
  };
}
