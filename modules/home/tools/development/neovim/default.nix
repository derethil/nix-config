{
  config,
  lib,
  ...
}: let
  inherit (lib) mkIf;
  cfg = config.glace.tools.development.neovim;
in {
  config = mkIf cfg.enable {
    glace.desktop.xdg.mimeapps.default = lib.glace.mkMimeApps "nvim.desktop" [
      "text/plain"
      "text/markdown"
      "application/json"
      "application/yaml"
      "application/toml"
    ];
  };
}