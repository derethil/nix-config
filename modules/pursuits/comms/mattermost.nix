{self, ...}: {
  flake.modules.homeManager.mattermost = {
    pkgs,
    lib,
    ...
  }: let
    mattermost-desktop = pkgs.symlinkJoin {
      name = "mattermost-desktop";
      paths = [pkgs.mattermost-desktop];
      postBuild = ''
        # desktop file has no StartupWMClass, so the filename must match the wayland app_id to resolve icon
        mv $out/share/applications/Mattermost.desktop \
          $out/share/applications/Mattermost.Desktop.desktop
      '';
    };
  in {
    home.packages = lib.mkIf pkgs.stdenv.hostPlatform.isLinux [
      mattermost-desktop
    ];
  };

  flake.modules.darwin.mattermost = {
    imports = [self.modules.darwin.homebrew];
    homebrew.masApps."Mattermost Desktop" = 1614666244;
  };
}
