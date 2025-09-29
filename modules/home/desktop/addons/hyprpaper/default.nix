{
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf filter length;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.addons.hyprpaper;
  enabledDisplays = filter (d: d.enabled) config.glace.hardware.displays;
  displaysWithWallpaper = filter (d: d.wallpaper != null) enabledDisplays;
in {
  options.glace.desktop.addons.hyprpaper = {
    enable = mkBoolOpt false "Whether to enable hyprpaper for wallpaper management";
  };

  config = mkIf (cfg.enable && length displaysWithWallpaper > 0) {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = map (d: "${config.glace.desktop.addons.wallpapers.targetDir}/${d.wallpaper}") displaysWithWallpaper;
        wallpaper = map (d: "${d.port},${config.glace.desktop.addons.wallpapers.targetDir}/${d.wallpaper}") displaysWithWallpaper;
        ipc = false;
        splash = false;
      };
    };
  };
}
