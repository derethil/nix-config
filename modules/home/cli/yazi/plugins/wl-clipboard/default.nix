{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.wl-clipboard;
in {
  options.glace.cli.yazi.plugins.wl-clipboard = {
    enable = mkBoolOpt true "Whether to enable wl-clipboard plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      keymap = {
        mgr = {
          prepend_keymap = [
            {
              on = ["y"];
              run = ["plugin wl-clipboard"];
              desc = "Yank to system clipboard";
            }
          ];
        };
      };

      plugins = {
        inherit (pkgs.yaziPlugins) wl-clipboard;
      };
    };

    assertions = [
      {
        assertion = config.glace.cli.wl-clipboard.enable;
        message = "The yazi wl-clipboard plugin requires wl-clipboard to be enabled in your configuration.";
      }
    ];
  };
}
