{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.smart-enter;
in {
  options.glace.cli.yazi.plugins.smart-enter = {
    enable = mkBoolOpt false "Whether to enable smart-enter plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) smart-enter;
      };

      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = ["l"];
              run = ["plugin smart-enter"];
              desc = "Enter the child directory, or open the file";
            }
          ];
        };
      };

      initLua = mkAfter ''
        require("smart-enter"):setup({
          open_multi = true,
        })
      '';
    };
  };
}
