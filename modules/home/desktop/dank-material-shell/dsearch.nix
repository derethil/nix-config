{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.dank-material-shell.dsearch;
in {
  options.glace.desktop.dank-material-shell.dsearch = {
    enable = mkBoolOpt false "Whether to enable DankSearch";
  };

  config = mkIf cfg.enable {
    programs.dsearch = {
      enable = true;
      config = {
        auto_reindex = true;
        index_paths = [
          {
            path = config.home.homeDirectory;
            max_depth = 8;
            exclude_hidden = false;
          }
        ];
      };
    };
  };
}
