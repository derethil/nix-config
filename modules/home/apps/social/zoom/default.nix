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
  firefoxCfg = config.glace.apps.browsers.firefox;

  mkNixPak = inputs.nixpak.lib.nixpak {
    inherit (pkgs) lib;
    inherit pkgs;
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

            bind.rw = [
              (sloth.env "XDG_DOWNLOAD_DIR")
              (sloth.env "XDG_DOCUMENTS_DIR")
              [
                (sloth.concat' (sloth.env "XDG_CONFIG_HOME") "/zoomus.conf")
                (sloth.concat' (sloth.env "XDG_CONFIG_HOME") "/zoom.conf")
              ]
            ];
          };
        };
      }).config.env
    ];

    glace.desktop.xdg.mimeapps.default = lib.glace.mkMimeApps "Zoom.desktop" [
      "x-scheme-handler/zoommtg"
      "x-scheme-handler/zoomus"
    ];

    programs.firefox.profiles.default.settings = mkIf firefoxCfg.enable {
      "network.protocol-handler.expose.zoommtg" = false;
      "network.protocol-handler.expose.zoomus" = false;
    };
  };
}
