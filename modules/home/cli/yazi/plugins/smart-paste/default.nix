{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.smart-paste;
in {
  options.glace.cli.yazi.plugins.smart-paste = {
    enable = mkBoolOpt true "Whether to enable smart-paste plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) smart-paste;
      };

      keymap.mgr.prepend_keymap = [
        {
          on = ["p"];
          run = ["plugin smart-paste"];
          desc = "Paste into the hovered directory or CWD";
        }
      ];
    };
  };
}