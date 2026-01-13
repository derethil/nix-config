{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.bypass;
in {
  options.glace.cli.yazi.plugins.bypass = {
    enable = mkBoolOpt false "Whether to enable bypass plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) bypass;
      };

      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = ["l"];
              run = ["plugin bypass smart-enter"];
              desc = "Enter child directory with bypass or open file";
            }
            {
              on = ["h"];
              run = ["plugin bypass reverse"];
              desc = "Go to parent directory with bypass";
            }
          ];
        };
      };
    };
  };
}
