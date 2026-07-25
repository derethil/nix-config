{self, ...}: {
  flake.modules.homeManager.yazi = {
    config,
    lib,
    pkgs,
    ...
  }: let
    flavor = "yazi-trash";
  in {
    imports = [
      self.modules.homeManager.mimeapps
    ];

    xdg = lib.mkIf pkgs.stdenv.hostPlatform.isLinux (lib.mkMerge [
      (self.lib.mkYaziApplication {
        inherit config flavor pkgs;
        comment = "Open the trash in Yazi file manager";
        genericName = "Trash";
        icon = "trash";
        mimeType = ["x-scheme-handler/trash"];
        name = "Trash - Yazi";
        openToPath = "${config.xdg.dataHome}/Trash/files";

        yaziConfig = ''
          [mgr]
          ratio = [0, 1, 0]
          sort_dir_first = true
          linemode = "none"
          show_hidden = true
          show_symlink = true
        '';
      }).xdg
      {
        mimeApps.defaultApplications = self.lib.mkMimeApps "${flavor}.desktop" [
          "x-scheme-handler/trash"
        ];
      }
    ]);
  };
}
