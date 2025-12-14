{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.jump-to-char;
in {
  options.glace.cli.yazi.plugins.jump-to-char = {
    enable = mkBoolOpt true "Whether to enable jump-to-char plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) jump-to-char;
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = ["f"];
            run = ["plugin jump-to-char"];
            desc = "Jump to char";
          }
        ];
      };
    };
  };
}