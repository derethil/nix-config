{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.tools.nixgl;
  nvidia = config.glace.hardware.nvidia.enable or false;
  isNonNixOS = config.distro or "nixos" != "nixos";
in {
  options.glace.tools.nixgl = with types; {
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
