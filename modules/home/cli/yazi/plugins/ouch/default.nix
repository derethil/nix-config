{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.ouch;
in {
  options.glace.cli.yazi.plugins.ouch = {
    enable = mkBoolOpt true "Whether to enable ouch plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) ouch;
      };

      settings = {
        plugin.prepend_previewers = [
          {
            mime = "application/{*zip,tar,bzip2,7z*,rar,xz,zstd,java-archive}";
            run = "ouch --archive-icon=''";
          }
        ];
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = ["C"];
            run = ["plugin ouch"];
            desc = "Compress with ouch";
          }
        ];
      };

      extraPackages = [
        pkgs.ouch
      ];
    };
  };
}

