{
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.desktop.addons.hyprpaper;
  enabledDisplays = filter (d: d.enabled) config.hardware.displays;
  displaysWithWallpaper = filter (d: d.wallpaper != null) enabledDisplays;
in {
  options.desktop.addons.hyprpaper = {
    enable = mkBoolOpt false "Whether to enable hyprpaper for wallpaper management";
  };

  config = mkIf (cfg.enable && length displaysWithWallpaper > 0) {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload = map (d: "${config.desktop.addons.wallpapers.targetDir}/${d.wallpaper}") displaysWithWallpaper;
        wallpaper = map (d: "${d.port},${config.desktop.addons.wallpapers.targetDir}/${d.wallpaper}") displaysWithWallpaper;
        ipc = false;
        splash = false;
      };
    };
  };
}
