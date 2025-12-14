{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.rich-preview;
in {
  options.glace.cli.yazi.plugins.rich-preview = {
    enable = mkBoolOpt false "Whether to enable rich-preview plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) rich-preview;
      };

      settings.plugin.prepend_previewers = [
      ];

      extraPackages = [
        pkgs.rich-cli
      ];
    };
  };
}

