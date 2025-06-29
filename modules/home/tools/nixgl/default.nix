{
  config,
  pkgs,
  lib,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.nixgl;
  nvidia = config.hardware.nvidia.enable or false;
in {
  options.tools.nixgl = with types; {
    enable = mkBoolOpt false "Whether to enable nixGL.";
    defaultWrapper = mkOpt str "" "Explicitly set default wrapper to use for NixGL-enabled applications.";
  };

  # TODO: this needs to be moved to a nixos module once I'm off Arch
  options.hardware.nvidia.enable = mkBoolOpt false "Whether to enable NVIDIA support (for use with nixGL).";

  config = lib.mkIf cfg.enable {
    nixGL.packages = pkgs.inputs.nixgl;
    nixGL.defaultWrapper = lib.mkIf nvidia "nvidia";
  };
}
