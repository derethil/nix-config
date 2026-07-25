{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      keymap.mgr.prepend_keymap = [
        {
          desc = "Yank to system clipboard";
          on = ["y"];
          run = ["plugin wl-clipboard"];
        }
      ];

      plugins.wl-clipboard = pkgs.yaziPlugins.wl-clipboard;
    };
  };
}
