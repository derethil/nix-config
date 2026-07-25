{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      keymap.mgr.prepend_keymap = [
        {
          desc = "Jump to char";
          on = ["f"];
          run = ["plugin jump-to-char"];
        }
      ];

      plugins.jump-to-char = pkgs.yaziPlugins.jump-to-char;
    };
  };
}
