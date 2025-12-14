{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.piper;
in {
  options.glace.cli.yazi.plugins.piper = {
    enable = mkBoolOpt true "Whether to enable piper plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) piper;
      };

      settings.plugin.prepend_previewers = [
        {
          name = "*/";
          run = ''piper -- eza -TL=1 --color=always --icons=always --group-directories-first --no-quotes "$1"'';
        }
        {
          name = "*.csv,*.json";
          run = ''piper -- bat -p --color=always "$1"'';
        }
        {
          name = "*.md";
          run = ''piper -- CLICOLOR_FORCE=1 glow -w=$w -s=dark "$1"'';
        }
      ];

      extraPackages = [
        pkgs.eza
        pkgs.bat
        pkgs.glow
      ];
    };
  };
}
