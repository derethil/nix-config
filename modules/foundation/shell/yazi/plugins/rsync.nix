{
  flake.modules.homeManager.yazi = {pkgs, ...}: {
    programs.yazi = {
      extraPackages = [pkgs.rsync];

      keymap.mgr.prepend_keymap = [
        {
          desc = "rsync";
          on = ["R"];
          run = ["plugin rsync"];
        }
      ];

      plugins.rsync = pkgs.yaziPlugins.rsync;
    };
  };
}
