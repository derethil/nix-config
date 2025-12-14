{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.rsync;
in {
  options.glace.cli.yazi.plugins.rsync = {
    enable = mkBoolOpt true "Whether to enable rsync plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) rsync;
      };

      keymap.mgr.prepend_keymap = [
        {
          on = ["R"];
          run = ["plugin rsync"];
          desc = "rsync";
        }
      ];

      extraPackages = [
        pkgs.rsync
      ];
    };
  };
}
