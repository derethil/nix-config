{
  config,
  pkgs,
  lib,
  ...
}: let
  inherit (lib) types mkIf;
  inherit (lib.glace) mkOpt mkBoolOpt;
  cfg = config.glace.tools.nix.nixgl;
  nvidia = config.glace.hardware.nvidia.enable or false;
  isNonNixOS = config.glace.distro or "nixos" != "nixos";
in {
  options.glace.tools.nix.nixgl = with types; {
    enable = mkBoolOpt (isNonNixOS && pkgs.stdenv.hostPlatform.isLinux) "Whether to enable nixGL.";
    defaultWrapper = mkOpt str "" "Explicitly set default wrapper to use for NixGL-enabled applications.";
  };

  # TODO: this needs to be moved to a nixos module once I'm off Arch
  options.glace.hardware.nvidia-drivers.enable = mkBoolOpt false "Whether to enable NVIDIA support (for use with nixGL).";

  config = mkIf cfg.enable {
    nixGL.packages = pkgs.inputs.nixgl;
    nixGL.defaultWrapper = mkIf nvidia "nvidia";
  };
}
