{self, ...}: {
  flake.modules.nixos.yazi = {pkgs, ...}: let
    # Patch termfilechooser to add niri to its UseIn list
    termfilechooser-patched = pkgs.xdg-desktop-portal-termfilechooser.overrideAttrs (old: {
      postInstall =
        (old.postInstall or "")
        + ''
          substituteInPlace $out/share/xdg-desktop-portal/portals/termfilechooser.portal \
            --replace "UseIn=" "UseIn=niri;"
        '';
    });
  in {
    imports = [self.modules.nixos.portals];

    xdg.portal = {
      extraPortals = [termfilechooser-patched];
      config = {
        common."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        niri."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
        hyprland."org.freedesktop.impl.portal.FileChooser" = "termfilechooser";
      };
    };
  };
}
