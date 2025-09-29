{
  pkgs,
  lib,
  config,
  ...
}:
with lib;
with glace; let
  cfg = config.glace.tools.qemu;
in {
  options.glace.tools.qemu = {
    enable = mkBoolOpt false "Whether to enable QEMU virtualization.";
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      qemu
    ];
  };
}