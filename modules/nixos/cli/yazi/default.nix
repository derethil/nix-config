{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.cli.yazi;

  # Patch termfilechooser to add niri to UseIn list
  termfilechooser-patched = pkgs.xdg-desktop-portal-termfilechooser.overrideAttrs (old: {
    postInstall =
      (old.postInstall or "")
      + ''
        substituteInPlace $out/share/xdg-desktop-portal/portals/termfilechooser.portal \
          --replace "UseIn=" "UseIn=niri;"
      '';
  });
in {
  options.glace.cli.yazi = {
    portal.enable = mkBoolOpt false "Whether to use yazi as the system file picker portal.";
  };

  config = mkIf cfg.portal.enable {
    glace.services.portals = {
      portals = [termfilechooser-patched];
      config = {
        common."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        niri."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        hyprland."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
    };
  };
}
