{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.diff;
in {
  options.glace.cli.yazi.plugins.diff = {
    enable = mkBoolOpt true "Whether to enable diff plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) diff;
      };

      keymap.mgr.prepend_keymap = [
        {
          on = ["<Ctrl+h>"];
          run = ["plugin diff"];
          desc = "Diff the selected with the hovered file";
        }
      ];
    };
  };
}

