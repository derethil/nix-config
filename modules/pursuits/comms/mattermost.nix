{self, ...}: {
  flake.modules.homeManager.mattermost = {
    pkgs,
    lib,
    ...
  }: let
    mattermost-desktop-x11 = pkgs.mattermost-desktop.overrideAttrs (oldAttrs: {
      postFixup =
        (oldAttrs.postFixup or "")
        + ''
          wrapProgram $out/bin/mattermost-desktop \
            --add-flags "--ozone-platform=x11" \
            --set ELECTRON_PLATFORM_OZONE_HINT x11 \
            --set QT_QPA_PLATFORM xcb
        '';
    });
  in {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
      mattermost-desktop-x11
    ];
  };

  flake.modules.darwin.mattermost = {
    imports = [self.modules.darwin.homebrew];
    homebrew.masApps."Mattermost Desktop" = 1614666244;
  };
}
