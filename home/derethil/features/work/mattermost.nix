{pkgs, ...}: let
  mattermost-desktop = pkgs.writeShellScriptBin "mattermost-desktop" ''
    env ELECTRON_PLATFORM_OZONE_HINT=x11 env QT_QPA_PLATFORM=xcb ${pkgs.mattermost-desktop}/bin/mattermost-desktop --ozone-platform=x11 "$@"
  '';
in {
  home.packages = [
    mattermost-desktop
  ];
}
