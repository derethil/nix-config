{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.nixpak = {
    inputs.nixpkgs.follows = "nixpkgs";
    url = "github:nixpak/nixpak";
  };

  flake.modules.homeManager.zoom = {
    config,
    lib,
    pkgs,
    ...
  }: let
    mkNixPak = inputs.nixpak.lib.nixpak {
      inherit (pkgs) lib;
      inherit pkgs;
    };

    sandboxed-zoom =
      (mkNixPak {
        config = {sloth, ...}: {
          app.package = pkgs.zoom-us;

          bubblewrap = {
            bind = {
              dev = [
                "/dev/snd"
                "/dev/video0"
                "/dev/video1"
              ];

              rw = [
                (sloth.concat' (sloth.env "HOME") "/.zoom")
                (sloth.concat' (sloth.env "XDG_CACHE_HOME") "/zoom")
                (sloth.env "XDG_CONFIG_HOME")
              ];
            };

            network = true;

            sockets = {
              pipewire = true;
              pulse = true;
              wayland = true;
            };

            tmpfs = ["/tmp"];
          };

          dbus.policies = {
            "org.freedesktop.portal.*" = "talk";
            "org.freedesktop.secrets" = "talk";
          };

          flatpak.appId = "us.zoom.Zoom";
          gpu.enable = true;
        };
      }).config.env;
  in {
    imports = [
      self.modules.homeManager.mimeapps
    ];

    home.packages = [
      (
        if pkgs.stdenv.hostPlatform.isLinux
        then sandboxed-zoom
        else pkgs.zoom-us
      )
    ];

    programs.firefox.profiles.default.settings = lib.mkIf config.programs.firefox.enable {
      "network.protocol-handler.expose.zoommtg" = false;
      "network.protocol-handler.expose.zoomus" = false;
    };

    xdg.mimeApps.defaultApplications = self.lib.mkMimeApps "Zoom.desktop" [
      "x-scheme-handler/zoommtg"
      "x-scheme-handler/zoomus"
    ];
  };
}
