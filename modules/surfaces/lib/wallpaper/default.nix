{self, ...}: {
  flake.modules.homeManager.wallpaper = {
    config,
    lib,
    pkgs,
    ...
  }: let
    inherit (lib) mkOption types pathExists getExe mkIf filter head length flatten;
    sourceDir = ./wallpapers;
    targetDir = "${config.home.homeDirectory}/Pictures/wallpapers";

    isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
    displaysWithWallpaper = filter (d: d.wallpaper != null) config.internal.displays;

    # macOS osascript sets every desktop in one shot — no per-display API.
    # We pick the single wallpaper to apply; the assertion below enforces
    # that at most one display has a wallpaper set on darwin.
    setWallpapers = pkgs.writeShellScriptBin "set-wallpapers" ''
      /usr/bin/osascript -e "tell application \"System Events\" to set the picture of every desktop to \"${targetDir}/${(head displaysWithWallpaper).wallpaper}\""
    '';
  in {
    imports = [self.modules.homeManager.displays];

    options.internal.wallpaper.targetDir = mkOption {
      type = types.str;
      readOnly = true;
      description = "Directory where wallpapers are linked in the user's home.";
    };

    config = {
      internal.wallpaper.targetDir = targetDir;

      home = {
        file.${targetDir}.source = sourceDir;

        activation.setWallpapers = mkIf (isDarwin && displaysWithWallpaper != []) (
          config.lib.dag.entryAfter ["writeBoundary"] ''
            ${getExe setWallpapers}
          ''
        );
      };

      assertions = flatten [
        (
          map (d: {
            assertion = d.wallpaper == null || pathExists "${toString sourceDir}/${d.wallpaper}";
            message = "wallpaper not found: ${toString sourceDir}/${d.wallpaper} for display ${d.name}";
          })
          config.internal.displays
        )
        {
          assertion = !isDarwin || length displaysWithWallpaper <= 1;
          message = "wallpaper: macOS osascript applies one image to every desktop, so at most one display may have a wallpaper set on darwin.";
        }
      ];
    };
  };
}
