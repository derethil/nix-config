{
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkIf;
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.apps.social.zoom;
  cfg-firefox = config.glace.apps.browsers.firefox;
  cfg-librewolf = config.glace.apps.browsers.librewolf;

  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
  };

  protocol-handler-settings = {
    "network.protocol-handler.expose.zoommtg" = false;
    "network.protocol-handler.expose.zoomus" = false;
  };
in {
  options.glace.apps.social.zoom = {
    enable = mkBoolOpt false "Whether to enable Zoom (sandboxed with nixpak)";
  };

  config = mkIf cfg.enable {
    home.packages = [
      (mkNixPak {
        config = {sloth, ...}: {
          app.package = pkgs.zoom-us;
          flatpak.appId = "us.zoom.Zoom";

          dbus.policies = {
            "org.freedesktop.portal.*" = "talk";
            "org.freedesktop.secrets" = "talk";
          };

          gpu.enable = true;

          bubblewrap = {
            network = true;

            sockets = {
              wayland = true;
              pipewire = true;
              pulse = true;
            };

            tmpfs = ["/tmp"];

            bind = {
              rw = [
                (sloth.env "XDG_CONFIG_HOME")
                (sloth.concat' (sloth.env "XDG_CACHE_HOME") "/zoom")
                (sloth.concat' (sloth.env "HOME") "/.zoom")
              ];

              # allow webcam and audio device access
              dev = [
                "/dev/video0"
                "/dev/video1"
                "/dev/snd"
              ];
            };
          };
        };
      }).config.env
    ];

    glace.desktop.xdg.mimeapps.default = lib.glace.mkMimeApps "Zoom.desktop" [
      "x-scheme-handler/zoommtg"
      "x-scheme-handler/zoomus"
    ];

    programs.firefox.profiles.default.settings = mkIf cfg-firefox.enable protocol-handler-settings;
    programs.librewolf.profiles.default.settings = mkIf cfg-librewolf.enable protocol-handler-settings;
  };
}
