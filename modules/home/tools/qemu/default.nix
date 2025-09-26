{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with internal; let
  cfg = config.tools.qemu;
in {
  options.tools.qemu = {
    enable = mkBoolOpt false "Whether to enable QEMU virtualization.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qemu
    ];
  };
}