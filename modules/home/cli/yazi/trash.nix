{
  config,
  lib,
  ...
}: let
  inherit (lib.glace) mkYaziApplication;
  inherit (lib) mkMerge mkIf;
  cfg = config.glace.cli.yazi;
  flavor = "yazi-trash";
in
  mkIf (cfg.enable && cfg.trash.enable) (mkMerge [
    (mkYaziApplication {
      inherit config flavor;
      icon = "trash";
      name = "Trash - Yazi";
      genericName = "Trash";
      comment = "Open the trash in Yazi file manager";
      mimeType = ["x-scheme-handler/trash"];
      openToPath = "${config.xdg.dataHome}/Trash/files";
      yaziConfig = ''
        [mgr]
        ratio = [0, 1, 0]
        sort_dir_first = true
        linemode = "none"
        show_hidden = true
        show_symlink = true
      '';
    })
    {
      glace.desktop.xdg.mimeapps.default."x-scheme-handler/trash" = ["${flavor}.desktop"];
    }
  ])
