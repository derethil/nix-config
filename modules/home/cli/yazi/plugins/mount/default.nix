{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.mount;
in {
  options.glace.cli.yazi.plugins.mount = {
    enable = mkBoolOpt true "Whether to enable mount plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) mount;
      };

      keymap.mgr.prepend_keymap = [
        {
          on = ["M"];
          run = ["plugin mount"];
          desc = "Mount/unmount partitions and disks";
        }
      ];

      extraPackages = [
        pkgs.util-linux
        pkgs.udisks2
      ];
    };
  };
}

