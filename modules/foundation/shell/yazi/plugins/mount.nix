{
  flake.modules.homeManager.yazi = {
    pkgs,
    lib,
    ...
  }:
    lib.mkIf pkgs.stdenv.isLinux {
      programs.yazi = {
        plugins.mount = pkgs.yaziPlugins.mount;

        keymap.mgr.prepend_keymap = [
          {
            on = ["M"];
            run = ["plugin mount"];
            desc = "Mount/unmount partitions and disks";
          }
        ];

        extraPackages = with pkgs; [
          util-linux
          udisks2
        ];
      };
    };
}
