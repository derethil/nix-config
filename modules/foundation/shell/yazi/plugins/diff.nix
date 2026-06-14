{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.diff = pkgs.yaziPlugins.diff;

      keymap.mgr.prepend_keymap = [
        {
          on = ["<Ctrl+h>"];
          run = ["plugin diff"];
          desc = "Diff the selected with the hovered file";
        }
      ];
    };
  };
}
