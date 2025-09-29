{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf getExe;
  inherit (lib.glace) mkBoolOpt;

  cfg = config.glace.desktop.addons.osascript-wallpaper;

  displays = config.glace.hardware.displays;
  wallpapersDir = config.glace.desktop.addons.wallpapers.targetDir;

  setWallpaper = pkgs.writeShellScriptBin "set-wallpapers" ''
    ${lib.concatMapStringsSep "\n" (
        display:
          if display.wallpaper != null
          then "/usr/bin/osascript -e \"tell application \\\"System Events\\\" to set the picture of every desktop to \\\"${wallpapersDir}/${display.wallpaper}\\\"\""
          else ""
      )
      displays}
  '';
in {
  options.glace.desktop.addons.osascript-wallpaper = {
    enable = mkBoolOpt false "Enable osascript wallpaper management for macOS";
  };

  config = mkIf cfg.enable {
    home.activation.setWallpapers = config.lib.dag.entryAfter ["writeBoundary"] ''
      ${getExe setWallpaper}
    '';
  };
}
