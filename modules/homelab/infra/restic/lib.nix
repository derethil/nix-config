{
  self,
  lib,
  ...
}: let
  inherit (lib) getExe';
  inherit (self.lib.podman) asUser;
in {
  flake.lib.restic.runners = {
    config,
    pkgs,
  }: {
    podmanExec = asUser pkgs "${getExe' pkgs.podman "podman"} exec";
    systemctl = asUser pkgs "${getExe' config.systemd.package "systemctl"} --user";
  };
}
