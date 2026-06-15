{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.jump-to-char = pkgs.yaziPlugins.jump-to-char;

      keymap.mgr.prepend_keymap = [
        {
          on = ["f"];
          run = ["plugin jump-to-char"];
          desc = "Jump to char";
        }
      ];
    };
  };
}
