{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      plugins.rsync = pkgs.yaziPlugins.rsync;

      keymap.mgr.prepend_keymap = [
        {
          on = ["R"];
          run = ["plugin rsync"];
          desc = "rsync";
        }
      ];

      extraPackages = [pkgs.rsync];
    };
  };
}
