{
  flake.modules.homeManager.yazi = {
    lib,
    pkgs,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      programs.yazi = {
        extraPackages = with pkgs; [
          udisks2
          util-linux
        ];

        keymap.mgr.prepend_keymap = [
          {
            desc = "Mount/unmount partitions and disks";
            on = ["M"];
            run = ["plugin mount"];
          }
        ];

        plugins.mount = pkgs.yaziPlugins.mount;
      };
    };
}
