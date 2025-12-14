{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) mkIf mkAfter;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;
  pluginCfg = config.glace.cli.yazi.plugins.git;
in {
  options.glace.cli.yazi.plugins.git = {
    enable = mkBoolOpt true "Whether to enable git plugin for yazi file manager.";
  };

  config = mkIf (cfg.enable && pluginCfg.enable) {
    programs.yazi = {
      plugins = {
        inherit (pkgs.yaziPlugins) git;
      };

      settings = {
        plugin = {
          prepend_fetchers = [
            {
              id = "git";
              name = "*";
              run = "git";
            }
            {
              id = "git";
              name = "*/";
              run = "git";
            }
          ];
        };
      };

      initLua = mkAfter ''
        th.git = th.git or {}
        th.git.updated_sign = ""
        th.git.modified_sign = ""
        th.git.added_sign = ""
        th.git.deleted_sign = ""
        th.git.ignored_sign = "󰊠"
        th.git.untracked_sign = ""
        require("git"):setup()
      '';
    };
  };
}
