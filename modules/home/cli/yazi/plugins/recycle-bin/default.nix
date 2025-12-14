{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.recycle-bin;
in {
  options.glace.cli.yazi.plugins.recycle-bin = {
    enable = mkBoolOpt true "Whether to enable recycle-bin plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) recycle-bin;
      };

      initLua = mkAfter ''
        require("recycle-bin"):setup()
      '';

      keymap.mgr.prepend_keymap = [
        {
          on = ["T"];
          run = ["plugin recycle-bin"];
          desc = "Open Trash menu";
        }
      ];

      extraPackages = [
        pkgs.trash-cli
      ];
    };
  };
}

