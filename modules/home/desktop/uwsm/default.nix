{
  lib,
  config,
  pkgs,
  ...
}: let
  inherit (lib) mkIf mkMerge getExe getExe';
  inherit (lib.glace) mkBoolOpt;
  cfg = config.glace.desktop.uwsm;
in {
  options.glace.desktop.uwsm = {
    enable = mkBoolOpt false "Whether to enable uwsm (Universal Wayland Session Manager).";
  };

  # This module only exposes the enable option for home-manager modules to check
  # The actual uwsm configuration is handled by the NixOS module
}