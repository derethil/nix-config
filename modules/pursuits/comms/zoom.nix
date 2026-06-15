{
  self,
  inputs,
  ...
}: {
  flake-file.inputs.nixpak = {
    url = "github:nixpak/nixpak";
    inputs.nixpkgs.follows = "nixpkgs";
  };

  flake.modules.homeManager.zoom = {
    config,
    pkgs,
    lib,
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
              (sloth.env "XDG_CONFIG_HOME")
              (sloth.concat' (sloth.env "XDG_CACHE_HOME") "/zoom")
              (sloth.concat' (sloth.env "HOME") "/.zoom")
            ];

            bind.dev = [
              "/dev/video0"
              "/dev/video1"
              "/dev/snd"
            ];
          };
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

    xdg.mimeApps.defaultApplications = self.lib.mkMimeApps "Zoom.desktop" [
      "x-scheme-handler/zoommtg"
      "x-scheme-handler/zoomus"
    ];

    programs.firefox.profiles.default.settings = lib.mkIf config.programs.firefox.enable {
      "network.protocol-handler.expose.zoommtg" = false;
      "network.protocol-handler.expose.zoomus" = false;
    };
  };
}
