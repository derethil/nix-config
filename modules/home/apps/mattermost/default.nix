{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
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
  options.apps.mattermost = {
    enable = mkBoolOpt false "Whether to enable Mattermost.";
    package =
      mkOpt types.package
      (
        if pkgs.stdenv.hostPlatform.isLinux
        then mattermost-desktop-x11
        else pkgs.mattermost-desktop
      )
      "Mattermost package to use.";
  };

  config = mkIf config.apps.mattermost.enable {
    home.packages = [config.apps.mattermost.package];
  };
}
