{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.relative-motions;

  generateRelativeMotionKeymaps = count:
    map (n: {
      on = ["${toString n}"];
      run = ["plugin relative-motions ${toString n}"];
      desc = "Move in relative steps";
    }) (lib.range 1 count);
in {
  options.glace.cli.yazi.plugins.relative-motions = {
    enable = mkBoolOpt true "Whether to enable relative-motions plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) relative-motions;
      };

      keymap = {
        mgr.prepend_keymap = generateRelativeMotionKeymaps 9;
      };

      initLua = mkAfter ''
        require("relative-motions"):setup({
          show_numbers = "relative",
          show_motion = true,
          only_motions = false,
        })
      '';
    };
  };
}

