{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.wl-clipboard = pkgs.yaziPlugins.wl-clipboard;

      keymap.mgr.prepend_keymap = [
        {
          on = ["y"];
          run = ["plugin wl-clipboard"];
          desc = "Yank to system clipboard";
        }
      ];
    };
  };
}
