{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.starship;
in {
  options.glace.cli.yazi.plugins.starship = {
    enable = mkBoolOpt true "Whether to enable starship plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) starship;
      };

      initLua = mkAfter ''
        require("starship"):setup({
          config_file = "${config.programs.starship.configPath}"
        })
      '';
    };

    assertions = [
      {
        assertion = config.glace.cli.starship.enable;
        message = "The yazi starship plugin requires starship to be enabled in your configuration.";
      }
    ];
  };
}
